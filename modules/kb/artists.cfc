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
        <!--- Handle OPTIONS preflight requests --->
        <cfif uCase(cgi.request_method) EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

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
        <!--- Handle OPTIONS preflight requests --->
        <cfif uCase(cgi.request_method) EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

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
                
                <!--- Fetch artist's selected categories --->
                <cfquery name="artistCategories" datasource="#getConfig('DSN')#">
                    SELECT 
                        kc.id AS category_id,
                        kc.name AS category_name,
                        kc.display_name AS category_display_name,
                        ks.id AS subcategory_id,
                        ks.name AS subcategory_name,
                        ks.display_name AS subcategory_display_name
                    FROM kb_artist_has_subcategory AS khs
                    JOIN kb_artist_subcategory AS ks
                        ON khs.subcategory_id = ks.id
                    JOIN kb_artist_category AS kc
                        ON ks.category_id = kc.id
                    WHERE khs.artist_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(artistDetails.artistID)#">
                    ORDER BY kc.sort_order ASC, ks.sort_order ASC
                </cfquery>
                
                <!--- Build categories structure --->
                <cfset artist['categories'] = []>
                <cfloop query="artistCategories">
                    <cfset category = {}>
                    <cfset category['category_id'] = val(artistCategories.category_id)>
                    <cfset category['category_name'] = artistCategories.category_name>
                    <cfset category['category_display_name'] = artistCategories.category_display_name>
                    <cfset category['subcategory_id'] = val(artistCategories.subcategory_id)>
                    <cfset category['subcategory_name'] = artistCategories.subcategory_name>
                    <cfset category['subcategory_display_name'] = artistCategories.subcategory_display_name>
                    <cfset ArrayAppend(artist['categories'], category)>
                </cfloop>
                
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
        <!--- Handle OPTIONS preflight requests --->
        <cfif uCase(cgi.request_method) EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

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
        <!--- Handle OPTIONS preflight requests --->
        <cfif uCase(cgi.request_method) EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

        <!--- Returns artists with status flags and their selected categories --->

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
                
                <!--- Fetch artist's selected categories --->
                <cfquery name="artistCategories" datasource="#getConfig('DSN')#">
                    SELECT 
                        kc.id AS category_id,
                        kc.name AS category_name,
                        kc.display_name AS category_display_name,
                        ks.id AS subcategory_id,
                        ks.name AS subcategory_name,
                        ks.display_name AS subcategory_display_name
                    FROM kb_artist_has_subcategory AS khs
                    JOIN kb_artist_subcategory AS ks
                        ON khs.subcategory_id = ks.id
                    JOIN kb_artist_category AS kc
                        ON ks.category_id = kc.id
                    WHERE khs.artist_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(artists.artistID)#">
                    ORDER BY kc.sort_order ASC, ks.sort_order ASC
                </cfquery>
                
                <!--- Build categories structure --->
                <cfset artist['categories'] = []>
                <cfloop query="artistCategories">
                    <cfset category = {}>
                    <cfset category['category_id'] = val(artistCategories.category_id)>
                    <cfset category['category_name'] = artistCategories.category_name>
                    <cfset category['category_display_name'] = artistCategories.category_display_name>
                    <cfset category['subcategory_id'] = val(artistCategories.subcategory_id)>
                    <cfset category['subcategory_name'] = artistCategories.subcategory_name>
                    <cfset category['subcategory_display_name'] = artistCategories.subcategory_display_name>
                    <cfset ArrayAppend(artist['categories'], category)>
                </cfloop>
                
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
        <!--- Handle OPTIONS preflight requests --->
        <cfif uCase(cgi.request_method) EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

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
        <!--- Handle OPTIONS preflight requests --->
        <cfif uCase(cgi.request_method) EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

        <!--- Init --->
        <cfset var response = {}>
        <cfset var dsn = getConfig('DSN')>
        <cfset var rawBody = getHttpRequestData().content>
        <cfset var requestData = {}>

        <cftry>
            <!--- Parse JSON request body --->
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

            <!--- Validate required parameters --->
            <cfif NOT (StructKeyExists(requestData, 'jury_fk') AND 
                       StructKeyExists(requestData, 'artist_fk') AND 
                       StructKeyExists(requestData, 'approved') AND 
                       StructKeyExists(requestData, 'rejected') AND 
                       StructKeyExists(requestData, 'need_action'))>
                <cfheader statuscode="400" statustext="Bad Request">
                <cfset response['success'] = false>
                <cfset response['message'] = "Missing required parameters: jury_fk, artist_fk, approved, rejected, need_action.">
                <cfreturn response>
            </cfif>

            <!--- Validate that exactly one vote type is 1 --->
            <cfset var voteCount = val(requestData.approved) + val(requestData.rejected) + val(requestData.need_action)>
            <cfif voteCount NEQ 1>
                <cfheader statuscode="400" statustext="Bad Request">
                <cfset response['success'] = false>
                <cfset response['message'] = "Exactly one of approved, rejected, or need_action must be 1.">
                <cfreturn response>
            </cfif>

            <!--- Verify jury member exists --->
            <cfquery name="checkJury" datasource="#dsn#">
                SELECT id FROM kb_jury WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.jury_fk)#">
            </cfquery>

            <cfif checkJury.recordCount EQ 0>
                <cfheader statuscode="404" statustext="Not Found">
                <cfset response['success'] = false>
                <cfset response['message'] = "Jury member not found.">
                <cfreturn response>
            </cfif>

            <!--- Verify artist exists --->
            <cfquery name="checkArtist" datasource="#dsn#">
                SELECT id FROM kb_artist WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <cfif checkArtist.recordCount EQ 0>
                <cfheader statuscode="404" statustext="Not Found">
                <cfset response['success'] = false>
                <cfset response['message'] = "Artist not found.">
                <cfreturn response>
            </cfif>

            <!--- Insert or update jury vote (ON DUPLICATE KEY UPDATE handles upsert) --->
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
            <cfquery name="getVoteCounts" datasource="#dsn#">
                SELECT 
                    COALESCE(SUM(approved), 0) AS approved_count,
                    COALESCE(SUM(rejected), 0) AS rejected_count,
                    COALESCE(SUM(need_action), 0) AS need_action_count
                FROM kb_jury_artist
                WHERE artist_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <!--- Get total number of jurors --->
            <cfquery name="getTotalJurors" datasource="#dsn#">
                SELECT COUNT(*) AS total_jurors FROM kb_jury
            </cfquery>

            <!--- Calculate majority (more than 50% of ALL jurors) --->
            <cfset var approvedCount = val(getVoteCounts.approved_count)>
            <cfset var rejectedCount = val(getVoteCounts.rejected_count)>
            <cfset var needActionCount = val(getVoteCounts.need_action_count)>
            <cfset var totalJurors = val(getTotalJurors.total_jurors)>
            <cfset var majorityThreshold = totalJurors / 2>

            <!--- Determine which status to set (if any has majority) --->
            <cfset var newApprovedStatus = 0>
            <cfset var newRejectedStatus = 0>
            <cfset var newNeedActionStatus = 0>

            <cfif approvedCount GT majorityThreshold>
                <cfset newApprovedStatus = 1>
            <cfelseif rejectedCount GT majorityThreshold>
                <cfset newRejectedStatus = 1>
            <cfelseif needActionCount GT majorityThreshold>
                <cfset newNeedActionStatus = 1>
            </cfif>

            <!--- Always update artist status - clear flags if no majority, set if majority exists --->
            <cfquery name="updateArtist" datasource="#dsn#">
                UPDATE kb_artist
                SET 
                    approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#newApprovedStatus#">,
                    rejected = <cfqueryparam cfsqltype="cf_sql_integer" value="#newRejectedStatus#">,
                    need_action = <cfqueryparam cfsqltype="cf_sql_integer" value="#newNeedActionStatus#">,
                    approved_when = NOW()
                WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#val(requestData.artist_fk)#">
            </cfquery>

            <!--- Fetch updated artist details with jury member's decision --->
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

            <!--- Build response --->
            <cfheader statuscode="200" statustext="OK">
            <cfset response['success'] = true>
            <cfset response['message'] = "Jury vote submitted successfully.">
            
            <cfset response['artist'] = {}>
            <cfif artistDetails.recordCount GT 0>
                <cfset response['artist']['user_id'] = val(artistDetails.userID)>
                <cfset response['artist']['artist_id'] = val(artistDetails.artistID)>
                <cfset response['artist']['name'] = artistDetails.name>
                <cfset response['artist']['description'] = artistDetails.description>
                <cfset response['artist']['approved'] = val(artistDetails.approved)>
                <cfset response['artist']['rejected'] = val(artistDetails.rejected)>
                <cfset response['artist']['need_action'] = val(artistDetails.need_action)>
                <cfset response['artist']['jury_decision'] = {
                    'approved': val(artistDetails.jury_approved),
                    'rejected': val(artistDetails.jury_rejected),
                    'need_action': val(artistDetails.jury_need_action)
                }>
            </cfif>
            
            <cfset response['vote_summary'] = {
                'approved_votes': approvedCount,
                'rejected_votes': rejectedCount,
                'need_action_votes': needActionCount,
                'total_jurors': totalJurors,
                'majority_threshold': majorityThreshold,
                'has_majority': (approvedCount GT majorityThreshold) OR (rejectedCount GT majorityThreshold) OR (needActionCount GT majorityThreshold)
            }>
            
            <cfreturn response>

            <cfcatch type="any">
                <cfheader statuscode="500" statustext="Internal Server Error">
                <cfset response['success'] = false>
                <cfset response['message'] = "Error submitting jury vote: " & cfcatch.message>
                <cfset response['detail'] = cfcatch.detail>
                <cfreturn response>
            </cfcatch>

        </cftry>

    </cffunction>

</cfcomponent>