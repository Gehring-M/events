<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">

    <cffunction name="loginArtist" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var requestData = deserializeJSON(getHttpRequestData().content)>
        <cfset var response = {}>

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

        <cfif StructKeyExists(requestData, 'email') AND StructKeyExists(requestData, 'password')>
            <!--- authenticate user --->
            <cfset authStruct = authenticate(requestData['email'], requestData['password'], 'page')>

            <cfif authStruct.authenticated>
                <!--- evaluate corresponding artist ID --->
                <cfquery name="fetchArtist" datasource="#getConfig('DSN')#">
                    SELECT id 
                    FROM artist 
                    WHERE email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestData['email']#">;
                </cfquery>

                <!--- check for faulty data that was initially in the DB --->
                <cfif fetchArtist.recordCount NEQ 1>
                    <cfheader statuscode="500" statustext="Internal Server Error">
                    <cfset response['success'] = false>
                    <cfset response['message'] = "Check DB, there are duplicate entries">
                    <cfreturn response>
                </cfif>

                <!--- respond to client --->
                <cfheader statuscode="200" statustext="OK">
                <cfset response['id'] = fetchArtist.id>
                <cfset response['success'] = true>
                <cfset response['message'] = "Successfully logged in">
                <cfreturn response>

            <cfelse>
                <cfheader statuscode="401" statustext="Unauthorized">
                <cfset response['success'] = false>
                <cfset response['message'] = "Wrong username or password.">
                <cfreturn response>
            </cfif>
        <cfelse>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = "Please provide 'username' and 'password' in the HTTP request body.">
            <cfreturn response>
        </cfif>

    </cffunction>


    <!--- ############################### --->
    <!--- #   GENERATE JSON WEB TOKEN   # --->
    <!--- ############################### --->

    <cffunction name="generateJWT" access="private" returntype="string">
        <!--- user data to use for the payload --->
        <cfargument name="userData" type="struct" required="true"> 

        <!--- construct JWT header (contains information about the token) --->
        <cfset header = {}>
        <cfset header['alg'] = "HS256">
        <cfset header['typ'] = "JWT">
        <cfset jwtHeader = base64UrlEncode(serializeJSON(header))>

        <!--- construct JWT payload (contains information about the user [NOT SENSITIVE DATA THO]) --->
        <cfset payload = userData>
        <cfset jwtPayload = base64UrlEncode(serializeJSON(payload))>

        <!--- generate token in format <header>.<payload> --->
        <cfset token = jwtHeader & "." & jwtPayload>

        <!--- generate signature (consisting token) --->
        <cfset signature = base64UrlEncode(binaryEncode(hmac(token, getConfig('jwt.secret'), "HMACSH256"), "hex"))>

        <!--- generate JWT --->
        <cfset jwt = token & "." & signature>

        <cfreturn jwt>

    </cffunction>



    <!--- ####################### --->
    <!--- #   REGISTER ARTIST   # --->
    <!--- ####################### --->

    <cffunction name="registerArtist" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var formStruct = formToStruct()>
        <cfset var response = {}>

        <!--- ensure correct media archive --->
        <cfset maArtistsPath = getConfig('ma.artists')>
        <cfif maArtistsPath EQ "" OR NOT pathExists(maArtistsPath)>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Make sure to create the media archive " & maArtistsPath & "first.">
            <cfreturn response>
        </cfif>

        <!--- media archive --->
        <cfset maArtists = getNodeId(resolvePath(maArtistsPath))>

        <!--- parse user from incoming form-data --->
        <cfset newUser = parseUserData(formStruct)>
        <cfif IsNull(newUser)>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Could not parse user data from incoming formdata.">
            <cfreturn response>
        </cfif>

        <!--- check if the user is in the db already --->
        <cfif userExists(newUser)>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "The user does already exist in the database.">
            <cfreturn response>
        </cfif>

        <!--- create new user --->
        <cfset userInfo = createKbUser(newUser)>

        <!--- validate creation --->
        <cfif userInfo.recordCount NEQ 1>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Something went wrong while writing the user to the DB">
            <cfreturn response>
        </cfif>

         


        <!--- initialize new artist object --->
        <cfset newArtist = {}>

        <cfif StructKeyExists(formStruct, 'name')>
            <cfset newArtist['name'] = formStruct.name>
        <cfelse>
            <!--- shouldn't execute because it's validated in the frontend but just in case --->
            <cfset newArtist['name'] = "fallback-name">
        </cfif>

        <!--- additional field names --->
        <cfset formFieldNames = ['email', 'telefon', 'adresse', 'plz', 'ort', 'link', 'beschreibung']>
        <cfloop array="#formFieldNames#" item="formFieldName">
            <cfif StructKeyExists(formStruct, formFieldName)>
                <cfset newArtist[formFieldName] = formStruct[formFieldName]>
            <cfelse>
                <!--- shouldn't happen but as a fallback (be aware that this works just for VARCHAR columns in the db) --->
                <cfset newArtist[formFieldName] = "">
            </cfif>
        </cfloop>

        <!--- insert artist --->
        <cfquery name="createArtist" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO artist (name, email, telefon, adresse, plz, ort, link, beschreibung) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['name']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['email']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['telefon']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['adresse']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['plz']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['ort']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['link']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newArtist['beschreibung']#">
            );
        </cfquery>

        <!--- extract artist ID --->
        <cfset artistID = dbResult.generatedKey>

        <!--- count incoming images --->
        <cfset imageCount = 0>
        <cfloop collection="#formStruct#" item="key">
            <cfif REFind("^image_\d+$", key)>
                <cfset imageCount = imageCount + 1>
            </cfif>
        </cfloop>

        <cfloop from="0" to="#imageCount - 1#" index="i">
            <!--- upload image --->
            <cfset uploadResult = uploadIntoMediaArchive("image_#i#", 1301, maArtists, "automatisch")>
            <!--- associate with regional highlight --->
            <cfinvoke component="/ameisen/components/mediaarchive" method="addUploadForInstance">
                <cfinvokeargument name="instance" value="#artistID#">
                <cfinvokeargument name="uploadfield" value="bilder">
                <cfinvokeargument name="addid" value="#uploadResult.instanceid#">
                <cfinvokeargument name="nodetype" value="2103">
            </cfinvoke>
        </cfloop>

        <cfcontent type="application/json">

        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully created new artist.">
        <cfreturn response>

    </cffunction>


    <!--- ############################ --->
    <!--- #   HELPER : CREATE USER   # --->
    <!--- ############################ --->

    <cffunction name="createUser" access="private" returnFormat="JSON">

    </cffunction>


    <!--- ################################ --->
    <!--- #   HELPER : PARSE USER DATA   # --->
    <!--- ################################ --->

    <cffunction name="parseUserData" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="formStruct" type="struct" required="yes">

        <!--- init --->
        <cfset userData = {}>

        <cfif StructKeyExists(formStruct, 'username') AND StructKeyExists(formStruct, 'email') AND StructKeyExists(formStruct, 'password')>
            <cfset userData['username'] = formStruct['username']>
            <cfset userData['email'] = formStruct['email']>
            <cfset userData['password'] = formStruct['password']>
        <cfelse>
            <cfset userData = NULL>
        </cfif>
        <!--- return --->
        <cfreturn userData>
    </cffunction>


    <!--- ############################ --->
    <!--- #   HELPER : USER EXISTS   # --->
    <!--- ############################ --->

    <cffunction name="userExists" access="private" returntype="boolean">
        <!--- arguments --->
        <cfargument name="user" type="struct" required="yes">

        <cfquery name="userData" datasource="#getConfig('DSN')#">
            SELECT id 
            FROM kb_user 
            WHERE username = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['username']#"> OR email = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['email']#">;
        </cfquery>

        <cfreturn (userData.recordCount GT 0)>

    </cffunction>



    <!--- ################### --->
    <!--- #   CREATE USER   # --->
    <!--- ################### --->

    <cffunction name="createKbUser" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="user" type="struct" required="yes">

        <!--- use bcrypt to encrypt password --->
        <cfset bcrypt = createObject("java", "org.mindrot.jbcrypt.BCrypt")>
        <cfset hashedPassword = bcrypt.hashpw(userPassword, bcrypt.gensalt(12))>

        <cfquery name="insertUser" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO kb_user (username, email, password)
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['username']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#user['email']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#hashedPassword#">
            );
        </cfquery>

        <!--- return info --->
        <cfset dbInfo = {}>
        <cfset dbInfo['id'] = dbResult.generatedKey>
        <cfset dbInfo['new_entries'] = dbResult.recordCount>
        <cfreturn dbInfo>

    </cffunction>

</cfcomponent>