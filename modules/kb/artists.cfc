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
            <cfset response['uuid'] = createUUID()>
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

</cfcomponent>