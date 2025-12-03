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


    <!--- ##################################### --->
    <!--- #   FETCH ARTIST CATEGORIES        # --->
    <!--- ##################################### --->

    <cffunction name="fetchArtistCategories" access="remote" returnFormat="JSON">
        <!--- init --->
        <cfset var response = {}>
        <cfset var dsn = getConfig('DSN')>
        <cfset var categories = []>

        <cftry>
            <!--- Get all main categories --->
            <cfquery name="mainCategories" datasource="#dsn#">
                SELECT id, name, display_name, sort_order
                FROM kb_artist_category
                ORDER BY sort_order ASC
            </cfquery>

            <!--- Loop through categories and build hierarchy --->
            <cfloop query="mainCategories">
                <cfset var category = {}>
                <cfset category['id'] = mainCategories.id>
                <cfset category['name'] = mainCategories.name>
                <cfset category['display_name'] = mainCategories.display_name>
                <cfset category['sort_order'] = mainCategories.sort_order>
                <cfset category['subcategories'] = []>

                <!--- Get subcategories for this category --->
                <cfquery name="subCategories" datasource="#dsn#">
                    SELECT id, name, display_name, sort_order
                    FROM kb_artist_subcategory
                    WHERE category_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#mainCategories.id#">
                    ORDER BY sort_order ASC
                </cfquery>

                <!--- Add subcategories to category --->
                <cfloop query="subCategories">
                    <cfset var subCategory = {}>
                    <cfset subCategory['id'] = subCategories.id>
                    <cfset subCategory['name'] = subCategories.name>
                    <cfset subCategory['display_name'] = subCategories.display_name>
                    <cfset subCategory['sort_order'] = subCategories.sort_order>
                    <cfset ArrayAppend(category['subcategories'], subCategory)>
                </cfloop>

                <cfset ArrayAppend(categories, category)>
            </cfloop>

            <cfheader statuscode="200" statustext="OK">
            <cfset response['success'] = true>
            <cfset response['message'] = "Successfully fetched artist categories">
            <cfset response['categories'] = categories>
            <cfreturn response>

            <cfcatch type="any">
                <cfheader statuscode="500" statustext="Internal Server Error">
                <cfset response['success'] = false>
                <cfset response['message'] = "An error occurred: " & cfcatch.message>
                <cfreturn response>
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
                    <!--- Loop through comma-separated image IDs --->
                    <cfloop list="#artistDetails['imgs']#" index="imgID">
                        <cfset imgID = trim(imgID)>
                        <cfif len(imgID) GT 0>
                            <cfset image = {}>
                            <cfset image['id'] = imgID>
                            <cfset image['path'] = href("instance:"&imgID)&"&dimensions=300x150&cropmode=cropcenter">
                            <!--- Try to get filename if possible --->
                            <cfset image['filename'] = "image_"&imgID>
                            <cfset ArrayAppend(artist['images'], image)>
                        </cfif>
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

        <!--- init --->
        <cfset var response = {}>
        <cfset response['artists'] = []>

        <cfquery name="artists" datasource="#getConfig('DSN')#">
            SELECT 
                ku.id AS userID,
                ka.id AS artistID, 
                ka.name AS name, 
                ka.description AS description, 
                ka.approved AS approved
            FROM kb_artist AS ka
            JOIN kb_user AS ku
            ON ka.user_fk = ku.id
            WHERE ka.deactivated = 0;
        </cfquery>

        <cfloop query="artists">
            <cfset artist = {}>
            <cfset artist['user_id'] = artists.userID>
            <cfset artist['artist_id'] = artists.artistID>
            <cfset artist['name'] = artists.name>
            <cfset artist['description'] = artists.description>
            <cfset artist['approved'] = artists.approved>
            <cfset ArrayAppend(response['artists'], artist)>
        </cfloop>

        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully fetched event details">
        <cfreturn response>

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

            <!--- Get all votes for this artist --->
            <cfquery name="getAllVotes" datasource="#dsn#">
                SELECT 
                    COALESCE(SUM(approved), 0) AS approved_count,
                    COALESCE(SUM(rejected), 0) AS rejected_count,
                    COALESCE(SUM(need_action), 0) AS need_action_count,
                    COUNT(*) AS total_jurors
                FROM kb_jury_artist
                WHERE artist_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <!--- Calculate majority and update artist status --->
            <cfset var approvedCount = val(getAllVotes.approved_count)>
            <cfset var rejectedCount = val(getAllVotes.rejected_count)>
            <cfset var needActionCount = val(getAllVotes.need_action_count)>
            <cfset var totalJurors = val(getAllVotes.total_jurors)>

            <!--- Determine majority (more than 50%) --->
            <cfset var majorityThreshold = totalJurors / 2>
            <cfset var newApprovedStatus = 0>

            <cfif approvedCount GT majorityThreshold>
                <cfset newApprovedStatus = 1>
            <cfelseif rejectedCount GT majorityThreshold OR needActionCount GT majorityThreshold>
                <cfset newApprovedStatus = 0>
            </cfif>

            <!--- Update artist status in kb_artist --->
            <cfquery name="updateArtist" datasource="#dsn#">
                UPDATE kb_artist
                SET 
                    approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#newApprovedStatus#">,
                    approved_when = NOW()
                WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <!--- Return success response --->
            <cfheader statuscode="200" statustext="OK">
            <cfset response['success'] = true>
            <cfset response['message'] = "Jury vote submitted successfully.">
            <cfset response['artist_approved'] = newApprovedStatus>
            <cfset response['vote_summary'] = {
                'approved': approvedCount,
                'rejected': rejectedCount,
                'need_action': needActionCount,
                'total_jurors': totalJurors
            }>
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