<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">


    <!--- ################## --->
    <!--- #   LOGIN USER   # --->
    <!--- ################## --->

    <cffunction name="loginUser" access="remote" returnFormat="JSON">

        <!--- handle CORS preflight --->
        <cfif lcase(cgi.request_method) EQ "options">
            <cfheader statuscode="200" statustext="OK">
            <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
            <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
            <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">
            <cfcontent type="application/json">
            <cfexit method="exit">
        </cfif>

        <!--- set CORS headers before return --->
        <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
        <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">

        <!--- init --->
        <cfset var rawBody = getHttpRequestData().content>
        <cfset var requestData = {}>
        <cfset var response = {}>
        <cfif len(trim(rawBody)) EQ 0>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = "Request body is empty. Expected JSON.">
            <cfreturn response>
        </cfif>
        <cftry>
            <cfset requestData = deserializeJSON(rawBody)>
            <cfif NOT isStruct(requestData)>
                <cfset errorMsg = "Request body is not valid JSON object. Received: " & rawBody>
                <cfthrow message="#errorMsg#">
            </cfif>
        <cfcatch>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = "Request body is not valid JSON.">
            <cfset response['errorDetail'] = rawBody>
            <cfreturn response>
        </cfcatch>
        </cftry>

        <!--- authenticate user --->
        <cfset authInfo = authenticateUser(user=requestData)>

        <!--- validate --->
        <cfif authInfo.authenticated>
            <!--- send back to client --->
            <cfheader statuscode="200" statustext="OK">
            <!--- generate JWT --->
            <cfset response['jwt'] = generateJWT(authInfo.user)>
            <cfset response['success'] = true>
            <cfset response['message'] = "Successfully logged in">
            <cfset response['id'] = authInfo['user']['id']>
            <cfset response['entity_id'] = authInfo['user']['entity_id']>
            <cfreturn response>
        <cfelse>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Invalid username or password">
            <cfreturn response>
        </cfif>

    </cffunction>



    <!--- ########################### --->
    <!--- #   JWT VERIFY ENDPOINT   # --->
    <!--- ########################### --->

    <cffunction name="verifyJWTToken" access="remote" returnFormat="JSON">
        <!--- handle CORS preflight --->
        <cfif lcase(cgi.request_method) EQ "options">
            <cfheader statuscode="200" statustext="OK">
            <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
            <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
            <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">
            <cfcontent type="application/json">
            <cfexit method="exit">
        </cfif>

        <!--- set CORS headers before return --->
        <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
        <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">

        <!--- get JWT from Authorization header or request body --->
        <cfset var response = {}>
        <cfset var jwtToken = "">
        <cfset var authHeader = "">
        <cfset var requestData = {}>

        <!--- Try to get Authorization header --->
        <cfif StructKeyExists(cgi, "http_authorization")>
            <cfset authHeader = cgi.http_authorization>
        <cfelseif StructKeyExists(cgi, "authorization")>
            <cfset authHeader = cgi.authorization>
        </cfif>

        <!--- If header exists and starts with Bearer, extract token --->
        <cfif len(authHeader) GT 0 AND left(authHeader, 7) EQ "Bearer ">
            <cfset jwtToken = trim(mid(authHeader, 8, len(authHeader)-7))>
        <cfelse>
            <!--- Fallback to request body --->
            <cfset requestData = deserializeJSON(getHttpRequestData().content)>
            <cfif StructKeyExists(requestData, "jwt")>
                <cfset jwtToken = requestData.jwt>
            </cfif>
        </cfif>

        <cfif len(jwtToken) EQ 0>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response["success"] = false>
            <cfset response["message"] = "Missing JWT token in Authorization header or request body.">
            <cfreturn response>
        </cfif>

        <!--- verify JWT --->
        <cfset var verifyResult = verifyJWT(jwtToken)>

        <cfif verifyResult.valid>
            <cfheader statuscode="200" statustext="OK">
            <cfset response["success"] = true>
            <cfset response["message"] = "JWT is valid.">
            <cfset response["payload"] = verifyResult.payload>
        <cfelse>
            <cfheader statuscode="401" statustext="Unauthorized">
            <cfset response["success"] = false>
            <cfset response["message"] = "JWT is invalid.">
        </cfif>

        <cfreturn response>
    </cffunction>


    <!--- ######################### --->
    <!--- #   AUTHENTICATE USER   # --->
    <!--- ######################### --->

    <cffunction name="authenticateUser" access="private" returntype="struct">
        <!--- argument --->
        <cfargument name="user" type="struct" required="yes">    

        <!--- init --->
        <cfset var info = {}>
        <cfset info['user'] = {}>
        <cfset info['errors'] = []>
        <cfset info['hasErrors'] = false>
        <cfset info['authenticated'] = false>

        <!--- validate data --->
        <cfif StructKeyExists(user, 'identifier') AND StructKeyExists(user, 'password') AND StructKeyExists(user, 'user_role')>
            <!--- fetch corresponding user --->
            <cfquery name="selectUser" datasource="#getConfig('DSN')#">
                SELECT id, kb_username AS username, kb_email AS email, kb_password AS password
                FROM kb_user
                WHERE kb_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['identifier']#"> OR kb_email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['identifier']#">;
            </cfquery>

            <!--- check for user --->
            <cfif selectUser.recordCount NEQ 1>
                <cfset ArrayAppend(info['errors'], "User does not exist.")>
                <cfset info['hasErrors'] = true>
                <cfset info['authenticated'] = false>
                <cfreturn info>
            </cfif>

            <!--- verify password --->
            <cfif selectUser.password NEQ user['password']>
                <cfset ArrayAppend(info['errors'], "Incorrect password.")>
                <cfset info['hasErrors'] = true>
                <cfset info['authenticated'] = false>
                <cfreturn info>
            </cfif>

            <cfset entityID = 0>

            <!--- verify role --->
            <cfif user['user_role'] EQ 'artist'>
                <cfquery name="verifyRole" datasource="#getConfig('DSN')#">
                    SELECT id
                    FROM kb_artist
                    WHERE user_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#selectUser['id']#">
                </cfquery>
                <cfif verifyRole.recordCount NEQ 1>
                    <cfset ArrayAppend(info['errors'], "User exists but tried to login for wrong role.")>
                    <cfset info['hasErrors'] = true>
                    <cfset info['authenticated'] = false>
                    <cfreturn info>
                </cfif>
                <cfset entityID = verifyRole.id>
            <cfelseif user['user_role'] EQ 'organizer'>
                <cfquery name="verifyRole" datasource="#getConfig('DSN')#">
                    SELECT id
                    FROM kb_organizer
                    WHERE user_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#selectUser['id']#">
                </cfquery>
                <cfif verifyRole.recordCount NEQ 1>
                    <cfset ArrayAppend(info['errors'], "User exists but tried to login for wrong role.")>
                    <cfset info['hasErrors'] = true>
                    <cfset info['authenticated'] = false>
                    <cfreturn info>
                </cfif>
                <cfset entityID = verifyRole.id>
            <cfelseif user['user_role'] EQ 'jury'>
                <cfquery name="verifyRole" datasource="#getConfig('DSN')#">
                    SELECT id
                    FROM kb_jury
                    WHERE user_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#selectUser['id']#">
                </cfquery>
                <cfif verifyRole.recordCount NEQ 1>
                    <cfset ArrayAppend(info['errors'], "User exists but tried to login for wrong role.")>
                    <cfset info['hasErrors'] = true>
                    <cfset info['authenticated'] = false>
                    <cfreturn info>
                </cfif>
                <cfset entityID = verifyRole.id>
            <cfelse>
                <cfset ArrayAppend(info['errors'], "Invalid user_role")>
                <cfset info['hasErrors'] = true>
                <cfset info['authenticated'] = false>
                <cfreturn info>
            </cfif>

            <!--- construct user --->
            <cfset info['user']['entity_id'] = entityID>
            <cfset info['user']['id'] = selectUser.id>
            <cfset info['user']['username'] = selectUser.username>
            <cfset info['user']['email'] = selectUser.email>
            <cfset info['authenticated'] = true>
            <cfreturn info>
        <cfelse>
            <cfset ArrayAppend(info['errors'], "Bad Request")>
            <cfset info['hasErrors'] = true>
            <cfset info['authenticated'] = false>
            <cfreturn info>
        </cfif>

    </cffunction>


    <!--- helper for base64url encoding --->
    <cffunction name="base64UrlEncodeCF" access="private" returntype="string">
        <cfargument name="input" type="string" required="true">
        <cfset var encoded = toBase64(arguments.input)>
        <cfset encoded = Replace(encoded, "+", "-", "all")>
        <cfset encoded = Replace(encoded, "/", "_", "all")>
        <cfset encoded = Replace(encoded, "=", "", "all")>
        <cfreturn encoded>
    </cffunction>


    <!--- ############################### --->
    <!--- #   GENERATE JSON WEB TOKEN   # --->
    <!--- ############################### --->

    <cffunction name="generateJWT" access="private" returntype="string">
        <!--- user data to use for the payload --->
        <cfargument name="user" type="struct" required="true"> 

        <!--- construct JWT header (contains information about the token) --->
        <cfset header = {}>
        <cfset header['alg'] = "HS256">
        <cfset header['typ'] = "JWT">
        <cfset jwtHeader = base64UrlEncodeCF(serializeJSON(header))>

        <!--- construct JWT payload (contains information about the user [NOT SENSITIVE DATA THO]) --->
        <cfset payload = duplicate(user)>
        <cfset payload['iat'] = getTickCount()>
        <cfset jwtPayload = base64UrlEncodeCF(serializeJSON(payload))>

        <!--- generate token in format <header>.<payload> --->
        <cfset token = jwtHeader & "." & jwtPayload>

        <!--- generate signature (consisting token) --->
        <cfset signature = base64UrlEncodeCF(binaryEncode(hmac(token, getConfig('jwt.secret'), "HMACSHA256"), "hex"))>

        <!--- generate JWT --->
        <cfset jwt = token & "." & signature>

        <cfreturn jwt>
    </cffunction>

    <cffunction name="verifyJWT" access="private" returntype="struct">
        <cfargument name="token" type="string" required="true">
        <cfset var result = {valid=false, payload={}}>
        <cfset var secret = getConfig('jwt.secret')>
        <cfset var parts = ListToArray(arguments.token, ".")>
        <cfif ArrayLen(parts) EQ 3>
            <cfset var header = parts[1]>
            <cfset var payload = parts[2]>
            <cfset var signature = parts[3]>
            <cfset var unsignedToken = header & "." & payload>
            <cfset var expectedSignature = base64UrlEncodeCF(binaryEncode(hmac(unsignedToken, secret, "HMACSHA256"), "hex"))>
            <cfif signature EQ expectedSignature>
                <cfset result.valid = true>
                <!--- decode base64url payload to string --->
                <cfset var payloadStr = Replace(payload, "-", "+", "all")>
                <cfset payloadStr = Replace(payloadStr, "_", "/", "all")>
                <!--- pad with = to make length a multiple of 4 --->
                <cfset var padLen = (4 - (Len(payloadStr) mod 4)) mod 4>
                <cfif padLen GT 0>
                    <cfset payloadStr = payloadStr & RepeatString("=", padLen)>
                </cfif>
                <cfset var decodedBinary = "">
                <cfset var decodedPayload = "">
                <cftry>
                    <cfset decodedBinary = ToBinary(payloadStr)>
                    <cfset decodedPayload = CharsetDecode(decodedBinary, "utf-8")>
                    <cfset result.payload = deserializeJSON(decodedPayload)>
                <cfcatch>
                    <cfset result.payload = {
                        error: "Invalid JWT payload.",
                        rawPayload: payload,
                        decodedPayload: decodedPayload
                    }>
                    <cfset result.valid = false>
                </cfcatch>
                </cftry>
            </cfif>
        </cfif>
        <cfreturn result>
    </cffunction>


    <!--- ################### --->
    <!--- #   UPDATE USER   # --->
    <!--- ################### --->

    <cffunction name="updateUser" access="remote" returnFormat="JSON">

        <!--- handle CORS preflight --->
        <cfif lcase(cgi.request_method) EQ "options">
            <cfheader statuscode="200" statustext="OK">
            <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
            <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
            <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">
            <cfcontent type="application/json">
            <cfexit method="exit">
        </cfif>

        <!--- set CORS headers before return --->
        <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
        <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">


        <!--- init --->
        <cfset var formData = formToStruct()>
        <cfset var response = {}>
        <cfset var info = {}>
        <cfset var userInfo = {}>
        <cfset var userDataInfo = {}>
        <cfset info['baseUser'] = {}>
        <cfset info['userData'] = {}>
        <cfset info['userRole'] = "">
        <cfset info['errors'] = []>
        <cfset info['hasErrors'] = false>

        <!--- [user_role] (mandatory) --->
        <cfif (StructKeyExists(formData, 'user_role')) AND ((formData['user_role'] EQ 'artist') OR (formData['user_role'] EQ 'organizer'))>
            <cfset info['userRole'] = formData['user_role']>
            <cfset info['#info['userRole']#'] = {}>
        <cfelse>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = "Make sure to provide a 'user_role' field">
            <cfreturn response>
        </cfif>

        <!--- create user object --->
        <cfset userInfo = createUserObject(formData, false)>

        <!--- create user details --->
        <cfif info['userRole'] EQ 'artist'>
            <cfset userDataInfo = createArtistObject(formData)>
        <cfelseif info['userRole'] EQ 'organizer'>
            <cfset userDataInfo = createOrganizerObject(formData)>
        <cfelse>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Fallback - No 'user_role' provided">
            <cfreturn response>
        </cfif>

        <!--- validate --->
        <cfif userInfo['hasErrors']>
            <cfset info['hasErrors'] = true>
            <cfset info['errors'] = ArrayMerge(info['errors'], userInfo['errors'])>
        <cfelse>
            <cfset info['baseUser'] = userInfo['user']>
        </cfif>
        <cfif userDataInfo['hasErrors']>
            <cfset info['hasErrors'] = true>
            <cfset info['errors'] = ArrayMerge(info['errors'], userDataInfo['errors'])>
        <cfelse>
            <cfset info['userData'] = userDataInfo['#info['userRole']#']>
        </cfif>

        <cfif info['hasErrors']>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = info['errors']>
            <cfreturn response>
        </cfif>

        <!--- check for duplicate entries --->
        <cfquery name="checkUsername" datasource="#getConfig('DSN')#">
            SELECT * 
            FROM kb_user
            WHERE kb_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#info['baseUser']['username']#"> AND NOT id = <cfqueryparam cfsqltype="cf_sql_integer" value="#info['baseUser']['id']#">;
        </cfquery>

        <cfquery name="checkEmail" datasource="#getConfig('DSN')#">
            SELECT * 
            FROM kb_user
            WHERE kb_email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#info['baseUser']['email']#"> AND NOT id = <cfqueryparam cfsqltype="cf_sql_integer" value="#info['baseUser']['id']#">;
        </cfquery>

        <cfif checkUsername.recordCount GT 0>
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Benutzername existiert bereits.")>
        </cfif>
        <cfif checkEmail.recordCount GT 0>
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Email existiert bereits.")>
        </cfif>

        <cfif info['userRole'] EQ 'artist'>
            <cfquery name="checkArtist" datasource="#getConfig('DSN')#">
                SELECT * 
                FROM kb_artist
                WHERE name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#info['userData']['name']#"> AND NOT id = <cfqueryparam cfsqltype="cf_sql_integer" value="#info['userData']['id']#">;
            </cfquery>
            <!--- validate --->
            <cfif checkArtist.recordCount GT 0>
                <cfset info['hasErrors'] = true>
                <cfset ArrayAppend(info['errors'], "Der Künstlername existiert bereits")>
            </cfif>
        <cfelseif info['userRole'] EQ 'organizer'>
            <cfquery name="checkOrganizer" datasource="#getConfig('DSN')#">
                SELECT * 
                FROM kb_organizer
                WHERE name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#info['userData']['name']#"> AND NOT id = <cfqueryparam cfsqltype="cf_sql_integer" value="#info['userData']['id']#">;
            </cfquery>
            <!--- validate --->
            <cfif checkOrganizer.recordCount GT 0>
                <cfset info['hasErrors'] = true>
                <cfset ArrayAppend(info['errors'], "Der Veranstaltername existiert bereits")>
            </cfif>
        <cfelse>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Fallback - No 'user_role' provided">
            <cfreturn response>
        </cfif>

        <cfif info['hasErrors']>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = info['errors']>
            <cfreturn response>
        </cfif>

        <!--- update entries --->
        <cfset updatedUser = updateUserEntity(info['baseUser'])>
        
        <cfif info['userRole'] EQ 'artist'>
            <cfset updatedArtist = updateArtistEntity(info['userData'])>
        <cfelseif infoStruct['userRole'] EQ 'organizer'>
            <cfset updatedOrganizer = updateOrganizerEntity(info['userData'])>
        <cfelse>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Fallback - No 'user_role' provided">
            <cfreturn response>
        </cfif>

        <!--- upload images --->
        <cfset uploadInfo = uploadImages(formData=formData, userRole=info['userRole'], userDetailsID=info['userData']['id'])>

        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully updated user">
        <cfreturn response>

    </cffunction>


    <!--- ################################# --->
    <!--- #   PREPARE REGISTRATION DATA   # --->
    <!--- ################################# --->

    <cffunction name="prepareRegistrationData" access="private" returntype="struct">

        <!--- argument --->
        <cfargument name="formData" type="struct" required="true">

        <!--- init --->
        <cfset var userDetailsInfo = {}>
        <cfset var userInfo = {}>
        <cfset var info = {}>
        <cfset info['user'] = {}>
        <cfset info['userRole'] = "">
        <cfset info['errors'] = []>
        <cfset info['hasErrors'] = false>

        <!--- [user_role] (mandatory) - but just used internally (if not provided -> frontend-error) --->
        <cfif (StructKeyExists(formData, 'user_role')) AND ((formData['user_role'] EQ 'artist') OR (formData['user_role'] EQ 'organizer') OR (formData['user_role'] EQ 'jury'))>
            <cfset info['userRole'] = formData['user_role']>
            <cfset info['#info['userRole']#'] = {}>
        <cfelse>
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Missing or invalid field 'user_role'.")>
            <cfreturn info>
        </cfif>

        <!--- create user object --->
        <cfset userInfo = createUserObject(formData, true)>

        <!--- create user details --->
        <cfif info['userRole'] EQ 'artist'>
            <cfset userDetailsInfo = createArtistObject(formData)>
        <cfelseif info['userRole'] EQ 'organizer'>
            <cfset userDetailsInfo = createOrganizerObject(formData)>
        <cfelseif info['userRole'] EQ 'jury'>
            <cfset userDetailsInfo = createJuryObject(formData)>
        <cfelse>
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Internal Server Error")>
            <cfreturn info>
        </cfif>

        <!--- validate --->
        <cfif userInfo['hasErrors']>
            <cfset info['hasErrors'] = true>
            <cfset info['errors'] = ArrayMerge(info['errors'], userInfo['errors'])>
        <cfelse>
            <cfset info['user'] = userInfo['user']>
        </cfif>

        <cfif userDetailsInfo['hasErrors']>
            <cfset info['hasErrors'] = true>
            <cfset info['errors'] = ArrayMerge(info['errors'], userDetailsInfo['errors'])>
        <cfelse>
            <cfset info['#info['userRole']#'] = userDetailsInfo['#info['userRole']#']>
        </cfif>

        <cfreturn info>

    </cffunction>




    <!--- ################## --->
    <!--- #   STORE USER   # --->
    <!--- ################## --->

    <cffunction name="storeUser" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="user" type="struct" required="true">
        <cfargument name="userDetails" type="struct" required="true">
        <cfargument name="userRole" type="string" required="true">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['hasErrors'] = false>
        <cfset info['errors'] = []>
        <cfset info['userID'] = 0>
        <cfset info['userDetailsID'] = 0>

        <!--- base validation --->
        <cfif (StructKeyExists(arguments, 'userRole')) AND ((arguments['userRole'] EQ 'artist') OR (arguments['userRole'] EQ 'organizer') OR (arguments['userRole'] EQ 'jury'))>
            <!--- store user first --->
            <cfset userInsertInfo = storeUserEntity(arguments['user'])>
            <!--- validate --->
            <cfif userInsertInfo['new_entries'] NEQ 1>
                <cfset info['hasErrors'] = true>
                <cfset ArrayAppend(info['errors'], "Internal Server Error")>
                <cfreturn info>
            </cfif>
            <cfset info['userID'] = userInsertInfo['id']>
            <!--- store entity based on userRole --->
            <cfif arguments['userRole'] EQ 'artist'>
                <cfset artistInsertInfo = storeArtistEntity(arguments['userDetails'], info['userID'])>
                <!--- validate --->
                <cfif artistInsertInfo['new_entries'] NEQ 1>
                    <cfset info['hasErrors'] = true>
                    <cfset ArrayAppend(info['errors'], "Internal Server Error")>
                    <cfreturn info>
                </cfif>
                <cfset info['userDetailsID'] = artistInsertInfo['id']>
                <!--- --->
                <cfreturn info>
            <cfelseif arguments['userRole'] EQ 'organizer'>
                <cfset organizerInsertInfo = storeOrganizerEntity(arguments['userDetails'], info['userID'])>
                <!--- validate --->
                <cfif organizerInsertInfo['new_entries'] NEQ 1>
                    <cfset info['hasErrors'] = true>
                    <cfset ArrayAppend(info['errors'], "Internal Server Error")>
                    <cfreturn info>
                </cfif>
                <cfset info['userDetailsID'] = organizerInsertInfo['id']>
                <!--- --->
                <cfreturn info>
            <cfelseif arguments['userRole'] EQ 'jury'>
                <cfset juryInsertInfo = storeJuryEntity(arguments['userDetails'], info['userID'])>
                <!--- validate --->
                <cfif juryInsertInfo['new_entries'] NEQ 1>
                    <cfset info['hasErrors'] = true>
                    <cfset ArrayAppend(info['errors'], "Internal Server Error")>
                    <cfreturn info>
                </cfif>
                <cfset info['userDetailsID'] = juryInsertInfo['id']>
                <!--- --->
                <cfreturn info>
            <cfelse>
                <cfset info['hasErrors'] = true>
                <cfset ArrayAppend(info['errors'], "Internal Server Error")>
                <cfreturn info>
            </cfif>
        <cfelse>
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Internal Server Error")>
            <cfreturn info>
        </cfif>

    </cffunction>


    <!--- ############################### --->
    <!--- #   CREATE ORGANIZER OBJECT   # --->
    <!--- ############################### --->

    <cffunction name="createOrganizerObject" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="formData" type="struct" required="yes">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['organizer'] = {}>
        <cfset info['errors'] = []>
        <cfset info['hasErrors'] = false>

        <!--- [name] (mandatory) --->
        <cfif (StructKeyExists(formData, 'name')) AND (formData['name'] NEQ "")>
            <cfset info['organizer']['name'] = formData['name']>
        <cfelse>
            <!--- append error --->
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Missing or invalid field 'name'.")>
        </cfif>

        <!--- [description] (optional) --->
        <cfif StructKeyExists(formData, 'description')>
            <cfset info['organizer']['description'] = formData['description']>
        <cfelse>
            <cfset info['organizer']['description'] = "">
        </cfif>

        <!--- [contact_person] (optional) --->
        <cfif StructKeyExists(formData, 'contact_person')>
            <cfset info['organizer']['contact_person'] = formData['contact_person']>
        <cfelse>
            <cfset info['organizer']['contact_person'] = "">
        </cfif>

        <!--- [phone_number] (optional) --->
        <cfif StructKeyExists(formData, 'phone_number')>
            <cfset info['organizer']['phone_number'] = formData['phone_number']>
        <cfelse>
            <cfset info['organizer']['phone_number'] = "">
        </cfif>

        <!--- [location_fk] (optional) --->
        <cfif StructKeyExists(formData, 'location_fk')>
            <cfset info['organizer']['location_fk'] = formData['location_fk']>
        <cfelse>
            <cfset info['organizer']['location_fk'] = "">
        </cfif>

        <!--- [address] (optional) --->
        <cfif StructKeyExists(formData, 'address')>
            <cfset info['organizer']['address'] = formData['address']>
        <cfelse>
            <cfset info['organizer']['address'] = "">
        </cfif>

        <!--- [postal_code] (optional) --->
        <cfif StructKeyExists(formData, 'postal_code')>
            <cfset info['organizer']['postal_code'] = formData['postal_code']>
        <cfelse>
            <cfset info['organizer']['postal_code'] = "">
        </cfif>

        <!--- [link] (optional) --->
        <cfif StructKeyExists(formData, 'link')>
            <cfset info['organizer']['link'] = formData['link']>
        <cfelse>
            <cfset info['organizer']['link'] = "">
        </cfif>

        <cfreturn info>


    </cffunction>


    <!--- ############################ --->
    <!--- #   CREATE ARTIST OBJECT   # --->
    <!--- ############################ --->

    <cffunction name="createArtistObject" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="formData" type="struct" required="yes">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['artist'] = {}>
        <cfset info['errors'] = []>
        <cfset info['hasErrors'] = false>

        <!--- [name] (mandatory) --->
        <cfif (StructKeyExists(formData, 'name')) AND (formData['name'] NEQ "")>
            <cfset info['artist']['name'] = formData['name']>
        <cfelse>
            <!--- append error --->
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Missing or invalid field 'name'.")>
        </cfif>

        <!--- [description] (optional) --->
        <cfif StructKeyExists(formData, 'description')>
            <cfset info['artist']['description'] = formData['description']>
        <cfelse>
            <cfset info['artist']['description'] = "">
        </cfif>

        <!--- [contact_person] (optional) --->
        <cfif StructKeyExists(formData, 'contact_person')>
            <cfset info['artist']['contact_person'] = formData['contact_person']>
        <cfelse>
            <cfset info['artist']['contact_person'] = "">
        </cfif>

        <!--- [phone_number] (optional) --->
        <cfif StructKeyExists(formData, 'phone_number')>
            <cfset info['artist']['phone_number'] = formData['phone_number']>
        <cfelse>
            <cfset info['artist']['phone_number'] = "">
        </cfif>

        <!--- [location_fk] (optional) --->
        <cfif StructKeyExists(formData, 'location_fk')>
            <cfset info['artist']['location_fk'] = formData['location_fk']>
        <cfelse>
            <cfset info['artist']['location_fk'] = "">
        </cfif>

        <!--- [address] (optional) --->
        <cfif StructKeyExists(formData, 'address')>
            <cfset info['artist']['address'] = formData['address']>
        <cfelse>
            <cfset info['artist']['address'] = "">
        </cfif>

        <!--- [postal_code] (optional) --->
        <cfif StructKeyExists(formData, 'postal_code')>
            <cfset info['artist']['postal_code'] = formData['postal_code']>
        <cfelse>
            <cfset info['artist']['postal_code'] = "">
        </cfif>

        <!--- [link] (optional) --->
        <cfif StructKeyExists(formData, 'link')>
            <cfset info['artist']['link'] = formData['link']>
        <cfelse>
            <cfset info['artist']['link'] = "">
        </cfif>

        <!--- [id] (optional) --->
        <cfif (StructKeyExists(formData, 'artist_id')) AND (formData['artist_id'] NEQ "")>
            <cfset info['artist']['id'] = formData['artist_id']>
        </cfif>

        <cfreturn info>
    </cffunction>


    <!--- ######################## --->
    <!--- #   CREATE JURY OBJECT   # --->
    <!--- ######################## --->

    <cffunction name="createJuryObject" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="formData" type="struct" required="yes">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['jury'] = {}>
        <cfset info['errors'] = []>
        <cfset info['hasErrors'] = false>

        <!--- [first_name] (optional) --->
        <cfif StructKeyExists(formData, 'first_name')>
            <cfset info['jury']['first_name'] = formData['first_name']>
        <cfelse>
            <cfset info['jury']['first_name'] = "">
        </cfif>

        <!--- [last_name] (optional) --->
        <cfif StructKeyExists(formData, 'last_name')>
            <cfset info['jury']['last_name'] = formData['last_name']>
        <cfelse>
            <cfset info['jury']['last_name'] = "">
        </cfif>

        <cfreturn info>

    </cffunction>


    <!--- ########################## --->
    <!--- #   CREATE USER OBJECT   # --->
    <!--- ########################## --->
    <cffunction name="createUserObject" access="private" returnFormat="JSON">
        <!--- arguments --->
        <cfargument name="formData" type="struct" required="yes">
        <cfargument name="checkForPassword" type="boolean" required="yes">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['user'] = {}>
        <cfset info['errors'] = []>
        <cfset info['hasErrors'] = false>

        <!--- [username] (mandatory) --->
        <cfif (StructKeyExists(formData, 'username')) AND (formData['username'] NEQ "")>
            <cfset info['user']['username'] = formData['username']>
        <cfelse>
            <!--- append error --->
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Missing or invalid field 'username'.")>
        </cfif>

        <!--- [email] (mandatory) --->
        <cfif (StructKeyExists(formData, 'email')) AND (formData['email'] NEQ "")>
            <cfset info['user']['email'] = formData['email']>
        <cfelse>
            <!--- append error --->
            <cfset info['hasErrors'] = true>
            <cfset ArrayAppend(info['errors'], "Missing or invalid field 'email'.")>
        </cfif>

        <cfif checkForPassword>
            <!--- [password] (mandatory) --->
            <cfif (StructKeyExists(formData, 'password')) AND (formData['password'] NEQ "")>
                <cfset info['user']['password'] = formData['password']>
            <cfelse>
                <!--- append error --->
                <cfset info['hasErrors'] = true>
                <cfset ArrayAppend(info['errors'], "Missing or invalid field 'password'.")>
            </cfif>
        </cfif>

        <!--- [id] (optional) --->
        <cfif (StructKeyExists(formData, 'user_id')) AND (formData['user_id'] NEQ "")>
            <cfset info['user']['id'] = formData['user_id']>
        </cfif>

        <cfreturn info>
    </cffunction>


    <!--- ############################ --->
    <!--- #   HELPER : USER EXISTS   # --->
    <!--- ############################ --->

    <cffunction name="userExists" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="user" type="struct" required="yes">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['doesExist'] = false>
        <cfset info['errors'] = []>

        <!--- check for username --->
        <cfquery name="usernameCheck" datasource="#getConfig('DSN')#">
            SELECT id 
            FROM kb_user 
            WHERE kb_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['username']#">;
        </cfquery>

        <!--- check for email --->
        <cfquery name="emailCheck" datasource="#getConfig('DSN')#">
            SELECT id
            FROM kb_user
            WHERE kb_email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['email']#">;
        </cfquery>

        <!--- evaluate --->
        <cfif usernameCheck.recordCount GT 0>
            <cfset info['doesExist'] = true>
            <cfset ArrayAppend(info['errors'], 'Username is already in use.')>
        </cfif>
        <cfif emailCheck.recordCount GT 0>
            <cfset info['doesExist'] = true>
            <cfset ArrayAppend(info['errors'], 'Email is already in use.')>
        </cfif>

        <cfreturn info>

    </cffunction>


    <!--- ######################### --->
    <!--- #   STORE USER ENTITY   # --->
    <!--- ######################### --->

    <cffunction name="storeUserEntity" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="user" type="struct" required="yes">

        <cfquery name="insertUser" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO kb_user (kb_username, kb_email, kb_password)
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['username']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['email']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['password']#">
            );
        </cfquery>

        <!--- return info --->
        <cfset dbInfo = {}>
        <cfset dbInfo['id'] = dbResult.generatedKey>
        <cfset dbInfo['new_entries'] = dbResult.recordCount>
        <cfreturn dbInfo>

    </cffunction>


    <!--- ########################## --->
    <!--- #   UPDATE USER ENTITY   # --->
    <!--- ########################## --->

    <cffunction name="updateUserEntity" access="private" returntype="boolean">
        <!--- arguments --->
        <cfargument name="user" type="struct" required="yes">

        <cfquery name="updateUser" datasource="#getConfig('DSN')#" result="dbResult">
            UPDATE kb_user 
            SET 
                kb_username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['username']#">,
                kb_email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['email']#">
            WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#user['id']#">;
        </cfquery>

        <cfreturn true>
    </cffunction>


    <!--- ############################ --->
    <!--- #   UPDATE ARTIST ENTITY   # --->
    <!--- ############################ --->

    <cffunction name="updateArtistEntity" access="private" returntype="boolean">
        <!--- arguments --->
        <cfargument name="artist" type="struct" required="yes">

        <cfquery name="updateArtist" datasource="#getConfig('DSN')#" result="dbResult">
            UPDATE kb_artist
            SET 
                name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['name']#">,
                description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['description']#">,
                phone_number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['phone_number']#">,
                contact_person = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['contact_person']#">,
                website = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['link']#">,
                address = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['address']#">,
                location_fk = <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['location_fk']#">
            WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#artist['id']#">;
        </cfquery>

        <cfreturn true>
    </cffunction>

    <!--- ############################### --->
    <!--- #   UPDATE ORGANIZER ENTITY   # --->
    <!--- ############################### --->

    <cffunction name="updateOrganizerEntity" access="private" returntype="boolean">
        <!--- arguments --->
        <cfargument name="organizer" type="struct" required="yes">

        <cfreturn organizer>
    </cffunction>


    <!--- ########################### --->
    <!--- #   STORE ARTIST ENTITY   # --->
    <!--- ########################### --->

    <cffunction name="storeArtistEntity" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="artist" type="struct" required="yes">
        <cfargument name="user_fk" type="numeric" required="yes">

        <cfquery name="insertArtist" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO kb_artist (user_fk, name, description, address, phone_number, contact_person, website)
            VALUES(
                <cfqueryparam cfsqltype="cf_sql_integer" value="#user_fk#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['name']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['description']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['address']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['phone_number']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['contact_person']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#artist['link']#">
            );
        </cfquery>

        <!--- return info --->
        <cfset dbInfo = {}>
        <cfset dbInfo['id'] = dbResult.generatedKey>
        <cfset dbInfo['new_entries'] = dbResult.recordCount>
        <cfreturn dbInfo>

    </cffunction>


    <!--- ############################## --->
    <!--- #   STORE ORGANIZER ENTITY   # --->
    <!--- ############################## --->

    <cffunction name="storeOrganizerEntity" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="organizer" type="struct" required="yes">
        <cfargument name="user_fk" type="numeric" required="yes">

        <cfquery name="insertOrganizer" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO kb_organizer (user_fk, name, description, address, phone_number, contact_person, website)
            VALUES(
                <cfqueryparam cfsqltype="cf_sql_integer" value="#user_fk#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#organizer['name']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#organizer['description']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#organizer['address']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#organizer['phone_number']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#organizer['contact_person']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#organizer['link']#">
            );
        </cfquery>

        <!--- return info --->
        <cfset dbInfo = {}>
        <cfset dbInfo['id'] = dbResult.generatedKey>
        <cfset dbInfo['new_entries'] = dbResult.recordCount>
        <cfreturn dbInfo>

    </cffunction>


    <!--- ######################## --->
    <!--- #   STORE JURY ENTITY   # --->
    <!--- ######################## --->

    <cffunction name="storeJuryEntity" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="jury" type="struct" required="yes">
        <cfargument name="user_fk" type="numeric" required="yes">

        <cfquery name="insertJury" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO kb_jury (user_fk, first_name, last_name)
            VALUES(
                <cfqueryparam cfsqltype="cf_sql_integer" value="#user_fk#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#jury['first_name']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#jury['last_name']#">
            );
        </cfquery>

        <!--- return info --->
        <cfset dbInfo = {}>
        <cfset dbInfo['id'] = dbResult.generatedKey>
        <cfset dbInfo['new_entries'] = dbResult.recordCount>
        <cfreturn dbInfo>

    </cffunction>


    <!--- ##################### --->
    <!--- #   REGISTER USER   # --->
    <!--- ##################### --->
    <cffunction name="registerUser" access="remote" returnFormat="JSON">

        <!--- handle CORS preflight --->
        <cfif lcase(cgi.request_method) EQ "options">
            <cfheader statuscode="200" statustext="OK">
            <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
            <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
            <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">
            <cfcontent type="application/json">
            <cfexit method="exit">
        </cfif>

        <!--- set CORS headers before return --->
        <cfheader name="Access-Control-Allow-Origin" value="https://kulturbezirk-test.agindo-services.info">
        <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">

        <!--- init --->
        <cfset var formStruct = formToStruct()>
        <cfset var response = {}>

        <!--- prepare form data for registration --->
        <cfset registrationData = prepareRegistrationData(formData=formStruct)>

        <!--- respond to client if invalid formdata --->
        <cfif registrationData['hasErrors']>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['errors'] = registrationData['errors']>
            <cfreturn response>
        </cfif>

        <!--- verify if user is not already in db --->
        <cfset evalUser = userExists(registrationData['user'])>

        <!--- respond to client if user does exist already --->
        <cfif evalUser['doesExist']>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['errors'] = evalUser['errors']>
            <cfreturn response>
        </cfif>
        
        <!--- store user data --->
        <cfset insertInfo = storeUser(user=registrationData['user'], userDetails=registrationData['#registrationData['userRole']#'], userRole=registrationData['userRole'])>

        <!--- respond to client if failed to store data in database --->
        <cfif insertInfo['hasErrors']>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['errors'] = insertInfo['errors']>
            <cfreturn response>
        </cfif>

        <!--- upload images --->
        <cfset uploadInfo = uploadImages(formData=formStruct, userRole=registrationData['userRole'], userDetailsID=insertInfo['userDetailsID'])>

        <cfcontent type="application/json">

        <!--- data to send for the response --->
        <cfset data = {}>
        <cfset data['username'] = registrationData['user']['username']>
        <cfset data['email'] = registrationData['user']['email']>

        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully registered user.">
        <cfset response['data'] = data>
        <cfreturn response>

    </cffunction>


    <!--- ##################### --->
    <!--- #   UPLOAD IMAGES   # --->
    <!--- ##################### --->

    <cffunction name="uploadImages" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="formData" type="struct" required="true">
        <cfargument name="userRole" type="string" required="true">
        <cfargument name="userDetailsID" type="numeric" required="true">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['imgCount'] = 0>
        <cfset info['ma'] = 0>
        <cfset info['nt'] = 0>

        <!--- set correct media archive --->
        <cfset maInfo = getMediaArchive(userRole)>
        <cfset info['ma'] = maInfo['ma']>
        <cfset info['nt'] = maInfo['nt']>

        <!--- count incoming images --->
        <cfset info['imgCount'] = 0>
        <cfloop collection="#formData#" item="key">
            <cfif REFind("^image_\d+$", key)>
                <cfset info['imgCount'] += 1>
            </cfif>
        </cfloop>

        <cfloop from="0" to="#info['imgCount'] - 1#" index="i">
            <!--- upload image --->
            <cfset uploadResult = uploadIntoMediaArchive("image_#i#", 1301, info['ma'], "automatisch")>
            <!--- associate with regional highlight --->
            <cfinvoke component="/ameisen/components/mediaarchive" method="addUploadForInstance">
                <cfinvokeargument name="instance" value="#userDetailsID#">
                <cfinvokeargument name="uploadfield" value="images">
                <cfinvokeargument name="addid" value="#uploadResult.instanceid#">
                <cfinvokeargument name="nodetype" value="#info['nt']#">
            </cfinvoke>
        </cfloop>

        <cfcontent type="application/json">

        <cfreturn info>

    </cffunction>


    <!--- ######################### --->
    <!--- #   GET MEDIA ARCHIVE   # --->
    <!--- ######################### --->

    <cffunction name="getMediaArchive" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="userRole" type="string" required="true">

        <!--- init --->
        <cfset var info = {}>
        <cfset info['ma'] = 0>
        <cfset info['nt'] = 0>

        <!--- check for artist --->
        <cfif userRole EQ 'artist'>
            <cfset info['nt'] = 2123>
            <cfset maArtistsPath = getConfig('ma.artists')>
            <cfif (maArtistsPath NEQ "") AND (pathExists(maArtistsPath))>
                <cfset info['ma'] = getNodeId(resolvePath(maArtistsPath))>
            </cfif>
        <!--- check for organizer --->
        <cfelseif userRole EQ 'organizer'>
            <cfset info['nt'] = 2125>
            <cfset maOrganizerPath = getConfig('ma.organizer')>
            <cfif (maOrganizerPath NEQ "") AND (pathExists(maOrganizerPath))>
                <cfset info['ma'] = getNodeId(resolvePath(maOrganizerPath))>
            </cfif>
        <!--- check for jury --->
        <cfelseif userRole EQ 'jury'>
            <cfset info['nt'] = 2126>
            <cfset maJuryPath = getConfig('ma.jury')>
            <cfif (maJuryPath NEQ "") AND (pathExists(maJuryPath))>
                <cfset info['ma'] = getNodeId(resolvePath(maJuryPath))>
            </cfif>
        </cfif>

        <!--- if no media archive was found, use fallback --->
        <cfif info['ma'] EQ 0>
            <cfset maFallbackPath = getConfig('ma.fallback')>
            <cfif (maFallbackPath NEQ "") AND (pathExists(maFallbackPath))>
                <cfset info['ma'] = getNodeId(resolvePath(maFallbackPath))>
            </cfif>
        </cfif>

        <cfreturn info>
    </cffunction>


</cfcomponent>