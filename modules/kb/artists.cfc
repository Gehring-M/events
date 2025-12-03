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

</cfcomponent>