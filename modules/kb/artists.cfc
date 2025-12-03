<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">
    <cfinclude template="/modules/cors.cfm">


    <!--- ############################# --->
    <!--- #   HELPER : PARSE DATE     # --->
    <!--- ############################# --->

    <cffunction name="parseAndFormatDate" access="private" returntype="string">
        <cfargument name="dateString" type="string" required="true">
        
        <cftry>
            <!--- Parse the date string --->
            <cfset var parsedDate = ParseDateTime(arguments.dateString)>
            <!--- Format as dd.mm.yyyy --->
            <cfreturn DateFormat(parsedDate, "dd.mm.yyyy")>
            
            <cfcatch>
                <!--- Return original string if parsing fails --->
                <cfreturn arguments.dateString>
            </cfcatch>
        </cftry>
    </cffunction>



    <!--- ########################### --->
    <!--- #   FETCH ARTIST DETAIL   # --->
    <!--- ########################### --->

    <cffunction name="fetchArtistDetail" access="remote" returnFormat="JSON">
        <!--- argument --->
        <cfargument name="id" type="numeric" required="no">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['artist'] = {}>

        <!--- check for correct call --->
        <cfif StructKeyExists(arguments, 'id')>

            <cfquery name="artistDetails" datasource="#getConfig('DSN')#">
                SELECT 
                    ku.id AS userID,
                    ku.kb_username AS username,
                    ku.kb_email AS email,
                    ka.id AS artistID,
                    ka.name,
                    ka.description,
                    ka.address,
                    ka.location_fk,
                    ka.phone_number,
                    ka.website,
                    ka.images AS imgs,
                    ka.uploads,
                    ka.approved
                FROM kb_artist AS ka
                JOIN kb_user AS ku
                ON ka.user_fk = ku.id
                WHERE ku.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['id']#">;
            </cfquery>   

            <cfloop query="artistDetails">
                <cfset artist = {}>
                <cfset artist['user_id'] = artistDetails.userID>
                <cfset artist['username'] = artistDetails.username>
                <cfset artist['email'] = artistDetails.email>
                <cfset artist['artist_id'] = artistDetails.artistID>
                <cfset artist['name'] = artistDetails.name>
                <cfset artist['description'] = artistDetails.description>
                <cfset artist['location'] = artistDetails.location_fk>
                <cfset artist['address'] = artistDetails.address>
                <cfset artist['phone'] = artistDetails.phone_number>
                <cfset artist['email'] = artistDetails.email>
                <cfset artist['link'] = artistDetails.website>
                <cfset artist['imgs'] = artistDetails.imgs>
                <cfset artist['approved'] = artistDetails.approved>
                <!--- evaluate images --->
                <cfset artist['images'] = []>
                <cfif artistDetails['imgs'] NEQ "">
                    <cfset images = getStructuredContent(nodetype=1301, instanceids="#artistDetails['imgs']#")>
                    <cfloop query="images">
                        <!--- construct individual images --->
                        <cfset image = {}>
                        <cfset image['id'] = images.id>
                        <cfset image['path'] = href("instance:"&images.id)&"&dimensions=300x150&cropmode=cropcenter">
                        <cfset image['filename'] = images.originalfilename>
                        <cfset ArrayAppend(artist['images'], image)>
                    </cfloop>
                </cfif>
                <!--- --->
                <cfset response['artist'] = artist>
            </cfloop>

            <cfheader statuscode="200" statustext="OK">
            <cfset response['success'] = true>
            <cfset response['message'] = "Successfully fetched event details">
            <cfreturn response>
        <cfelse>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = "Please provide an ID as a URL parameter.">
            <cfreturn response>
        </cfif>

    </cffunction>


    <cffunction name="fetchArtists" access="remote" returnFormat="JSON">
        <!--- argument --->
        <cfargument name="juryId" type="numeric" required="no">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['artists'] = []>
        <cfset var hasJuryId = StructKeyExists(arguments, 'juryId') AND arguments['juryId'] GT 0>

        <cfquery name="artists" datasource="#getConfig('DSN')#">
            SELECT 
                ku.id AS userID,
                ka.id AS artistID, 
                ka.name AS name, 
                ka.description AS description, 
                ka.approved AS approved,
                ka.rejected AS rejected,
                ka.need_action AS need_action
                <cfif hasJuryId>
                    ,COALESCE(kja.approved, 0) AS jury_approved,
                    COALESCE(kja.rejected, 0) AS jury_rejected,
                    COALESCE(kja.need_action, 0) AS jury_need_action
                </cfif>
            FROM kb_artist AS ka
            JOIN kb_user AS ku
            ON ka.user_fk = ku.id
            <cfif hasJuryId>
                LEFT JOIN kb_jury_artist AS kja
                ON ka.id = kja.artist_fk AND kja.jury_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['juryId']#">
            </cfif>
            WHERE ka.deactivated = 0;
        </cfquery>

        <cfloop query="artists">
            <cfset artist = {}>
            <cfset artist['user_id'] = artists.userID>
            <cfset artist['artist_id'] = artists.artistID>
            <cfset artist['name'] = artists.name>
            <cfset artist['description'] = artists.description>
            <cfset artist['approved'] = artists.approved>
            <cfset artist['rejected'] = artists.rejected>
            <cfset artist['need_action'] = artists.need_action>
            <cfif hasJuryId>
                <cfset artist['jury_decision'] = {
                    'approved': artists.jury_approved,
                    'rejected': artists.jury_rejected,
                    'need_action': artists.jury_need_action
                }>
            </cfif>
            <cfset ArrayAppend(response['artists'], artist)>
        </cfloop>

        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully fetched event details">
        <cfreturn response>

    </cffunction>


    <cffunction name="fetchArtistsPublic" access="remote" returnFormat="JSON">
        <!--- Returns artists with status flags but without individual jury decisions --->

        <!--- init --->
        <cfset var response = {}>
        <cfset var response['artists'] = []>

        <cftry>
            <cfquery name="artists" datasource="#getConfig('DSN')#">
                SELECT 
                    ku.id AS userID,
                    ka.id AS artistID, 
                    ka.name AS name, 
                    ka.description AS description, 
                    ka.approved AS approved,
                    ka.rejected AS rejected,
                    ka.need_action AS need_action
                FROM kb_artist AS ka
                JOIN kb_user AS ku
                ON ka.user_fk = ku.id
                WHERE ka.deactivated = 0;
            </cfquery>

            <cfloop query="artists">
                <cfset artist = {}>
                <cfset artist['user_id'] = val(artists.userID)>
                <cfset artist['artist_id'] = val(artists.artistID)>
                <cfset artist['name'] = artists.name>
                <cfset artist['description'] = artists.description>
                <cfset artist['approved'] = val(artists.approved)>
                <cfset artist['rejected'] = val(artists.rejected)>
                <cfset artist['need_action'] = val(artists.need_action)>
                <cfset ArrayAppend(response['artists'], artist)>
            </cfloop>

            <cfheader statuscode="200" statustext="OK">
            <cfset response['success'] = true>
            <cfset response['message'] = "Successfully fetched artists (count: " & len(response['artists']) & ")">
            <cfreturn response>

            <cfcatch type="any">
                <cfheader statuscode="500" statustext="Internal Server Error">
                <cfset response['success'] = false>
                <cfset response['message'] = "Error fetching artists: " & cfcatch.message>
                <cfset response['detail'] = cfcatch.detail>
                <cfreturn response>
            </cfcatch>
        </cftry>

    </cffunction>


    <cffunction name="approveArtist" access="remote" returnFormat="JSON">
        <!--- argument --->
        <cfargument name="id" type="numeric" required="no">

        <!--- init --->
        <cfset var response = {}>

        <!--- check for correct call --->
        <cfif StructKeyExists(arguments, 'id')>

            <cfquery name="approvedArtist" datasource="#getConfig('DSN')#">
            </cfquery>

            <cfheader statuscode="200" statustext="OK">
            <cfset response['success'] = true>
            <cfset response['message'] = "Successfully approved artist.">
            <cfreturn response>
        <cfelse>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = "Please provide an ID as a URL parameter.">
            <cfreturn response>
        </cfif>

    </cffunction>


    <!--- #################################### --->
    <!--- #   JURY VOTING ON ARTIST        # --->
    <!--- #################################### --->

    <cffunction name="submitJuryVote" access="remote" returnFormat="JSON">
        <!--- handle OPTIONS preflight (shouldn't reach here due to Application.cfm, but just in case) --->
        <cfif lcase(cgi.request_method) EQ "options">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

        <!--- init --->
        <cfset var response = {}>
        <cfset var dsn = getConfig('DSN')>
        <cfset var rawBody = getHttpRequestData().content>
        <cfset var requestData = {}>
        <cfif len(trim(rawBody)) EQ 0>
            <cfheader statuscode="400" statustext="Bad Request">
            <cfset response['success'] = false>
            <cfset response['message'] = "Request body is empty.">
            <cfreturn response>
        </cfif>
        <cftry>
            <cfset requestData = deserializeJSON(rawBody)>
            <cfcatch>
                <cfheader statuscode="400" statustext="Bad Request">
                <cfset response['success'] = false>
                <cfset response['message'] = "Invalid JSON in request body.">
                <cfreturn response>
            </cfcatch>
        </cftry>

        <cftry>
            <!--- Validate that all required parameters are present --->
            <cfif NOT (StructKeyExists(requestData, 'jury_fk') AND StructKeyExists(requestData, 'artist_fk') AND StructKeyExists(requestData, 'approved') AND StructKeyExists(requestData, 'rejected') AND StructKeyExists(requestData, 'need_action'))>
                <cfheader statuscode="400" statustext="Bad Request">
                <cfset response['success'] = false>
                <cfset response['message'] = "Missing required parameters: jury_fk, artist_fk, approved, rejected, need_action.">
                <cfreturn response>
            </cfif>

            <!--- Validate input: only one vote type can be 1 --->
            <cfset var voteCount = val(requestData.approved) + val(requestData.rejected) + val(requestData.need_action)>
            <cfif voteCount NEQ 1>
                <cfheader statuscode="400" statustext="Bad Request">
                <cfset response['success'] = false>
                <cfset response['message'] = "Exactly one of approved, rejected, or need_action must be 1.">
                <cfreturn response>
            </cfif>

            <!--- Check if jury member and artist exist --->
            <cfquery name="checkJury" datasource="#dsn#">
                SELECT id FROM kb_jury WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.jury_fk)#">
            </cfquery>

            <cfif checkJury.recordCount EQ 0>
                <cfheader statuscode="404" statustext="Not Found">
                <cfset response['success'] = false>
                <cfset response['message'] = "Jury member not found.">
                <cfreturn response>
            </cfif>

            <cfquery name="checkArtist" datasource="#dsn#">
                SELECT id FROM kb_artist WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <cfif checkArtist.recordCount EQ 0>
                <cfheader statuscode="404" statustext="Not Found">
                <cfset response['success'] = false>
                <cfset response['message'] = "Artist not found.">
                <cfreturn response>
            </cfif>

            <!--- Insert or update jury vote --->
            <cfquery name="submitVote" datasource="#dsn#">
                INSERT INTO kb_jury_artist (jury_fk, artist_fk, approved, rejected, need_action)
                VALUES (
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.jury_fk)#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.approved)#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.rejected)#">,
                    <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.need_action)#">
                )
                ON DUPLICATE KEY UPDATE
                    approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.approved)#">,
                    rejected = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.rejected)#">,
                    need_action = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.need_action)#">
            </cfquery>

            <!--- Get vote counts for this artist --->
            <cfquery name="getAllVotes" datasource="#dsn#">
                SELECT 
                    COALESCE(SUM(approved), 0) AS approved_count,
                    COALESCE(SUM(rejected), 0) AS rejected_count,
                    COALESCE(SUM(need_action), 0) AS need_action_count
                FROM kb_jury_artist
                WHERE artist_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <!--- Get total number of jurors --->
            <cfquery name="getTotalJurors" datasource="#dsn#">
                SELECT COUNT(*) AS total_jurors
                FROM kb_jury
            </cfquery>

            <!--- Calculate majority and update artist status --->
            <cfset var approvedCount = val(getAllVotes.approved_count)>
            <cfset var rejectedCount = val(getAllVotes.rejected_count)>
            <cfset var needActionCount = val(getAllVotes.need_action_count)>
            <cfset var totalJurors = val(getTotalJurors.total_jurors)>

            <!--- Determine majority (more than 50% of ALL jurors) --->
            <cfset var majorityThreshold = totalJurors / 2>
            <cfset var newApprovedStatus = 0>
            <cfset var newRejectedStatus = 0>
            <cfset var newNeedActionStatus = 0>

            <!--- Only set a status if there is a clear majority (> 50%) --->
            <cfif approvedCount GT majorityThreshold>
                <cfset newApprovedStatus = 1>
            <cfelseif rejectedCount GT majorityThreshold>
                <cfset newRejectedStatus = 1>
            <cfelseif needActionCount GT majorityThreshold>
                <cfset newNeedActionStatus = 1>
            </cfif>

            <!--- Only update artist status if there is a clear majority --->
            <cfif (approvedCount GT majorityThreshold) OR (rejectedCount GT majorityThreshold) OR (needActionCount GT majorityThreshold)>
                <cfquery name="updateArtist" datasource="#dsn#">
                    UPDATE kb_artist
                    SET 
                        approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#newApprovedStatus#">,
                        rejected = <cfqueryparam cfsqltype="cf_sql_integer" value="#newRejectedStatus#">,
                        need_action = <cfqueryparam cfsqltype="cf_sql_integer" value="#newNeedActionStatus#">,
                        approved_when = NOW()
                    WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
                </cfquery>
            </cfif>

            <!--- Fetch updated artist details --->
            <cfquery name="artistDetails" datasource="#dsn#">
                SELECT 
                    ku.id AS userID,
                    ka.id AS artistID, 
                    ka.name AS name, 
                    ka.description AS description, 
                    ka.approved AS approved,
                    ka.rejected AS rejected,
                    ka.need_action AS need_action,
                    COALESCE(kja.approved, 0) AS jury_approved,
                    COALESCE(kja.rejected, 0) AS jury_rejected,
                    COALESCE(kja.need_action, 0) AS jury_need_action
                FROM kb_artist AS ka
                JOIN kb_user AS ku
                ON ka.user_fk = ku.id
                LEFT JOIN kb_jury_artist AS kja
                ON ka.id = kja.artist_fk AND kja.jury_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.jury_fk)#">
                WHERE ka.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <!--- Return success response --->
            <cfheader statuscode="200" statustext="OK">
            <cfset response['success'] = true>
            <cfset response['message'] = "Jury vote submitted successfully.">
            
            <!--- Build artist object --->
            <cfset artist = {}>
            <cfif artistDetails.recordCount GT 0>
                <cfset artist['user_id'] = artistDetails.userID>
                <cfset artist['artist_id'] = artistDetails.artistID>
                <cfset artist['approved'] = artistDetails.approved>
                <cfset artist['rejected'] = artistDetails.rejected>
                <cfset artist['need_action'] = artistDetails.need_action>
                <cfset artist['jury_decision'] = {
                    'approved': artistDetails.jury_approved,
                    'rejected': artistDetails.jury_rejected,
                    'need_action': artistDetails.jury_need_action
                }>
            </cfif>
            
            <cfset response['artist'] = artist>
            <cfreturn response>

            <cfcatch type="any">
                <cfheader statuscode="500" statustext="Internal Server Error">
                <cfset response['success'] = false>
                <cfset response['message'] = "An error occurred: " & cfcatch.message & " - " & cfcatch.detail>
                <cfreturn response>
            </cfcatch>

        </cftry>

    </cffunction>

</cfcomponent>