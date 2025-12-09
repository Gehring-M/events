<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">
    <cfinclude template="/modules/cors.cfm">


    <!--- ############################# --->
    <!--- #   HELPER: PARSE DATE      # --->
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


    <!--- ########################## --->
    <!--- #   REGISTER ORGANIZER   # --->
    <!--- ########################## --->

    <cffunction name="registerOrganizer" access="remote" returnFormat="JSON">
        <!--- Handle OPTIONS preflight requests --->
        <cfif uCase(cgi.request_method) EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>

        <!--- init --->
        <cfset var formStruct = formToStruct()>
        <cfset var response = {}>

        <!--- ensure correct media archive --->
        <cfset maOrganizerPath = getConfig('ma.organizer')>
        <cfif maOrganizerPath EQ "" OR NOT pathExists(maOrganizerPath)>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Make sure to create the media archive " & maOrganizerPath & "first">
            <cfreturn response>
        </cfif>

        <!--- media archive --->
        <cfset maOrganizer = getNodeId(resolvePath(maOrganizerPath))>

        <!--- initialize new artist object --->
        <cfset newOrganizer = {}>

        <cfif StructKeyExists(formStruct, 'name')>
            <cfset newOrganizer['name'] = formStruct.name>
        <cfelse>
            <!--- shouldn't execute because it's validated in the frontend but just in case --->
            <cfset newOrganizer['name'] = "fallback-name">
        </cfif>

        <!--- additional field names --->
        <cfset formFieldNames = ['email', 'telefon', 'adresse', 'plz', 'ort', 'link', 'beschreibung']>
        <cfloop array="#formFieldNames#" item="formFieldName">
            <cfif StructKeyExists(formStruct, formFieldName)>
                <cfset newOrganizer[formFieldName] = formStruct[formFieldName]>
            <cfelse>
                <!--- shouldn't happen but as a fallback (be aware that this works just for VARCHAR columns in the db) --->
                <cfset newOrganizer[formFieldName] = "">
            </cfif>
        </cfloop>

        <!--- insert artist --->
        <cfquery name="createOrganizer" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO veranstalter (name, email, telefon, adresse, plz, ort, web, beschreibung) 
            VALUES (
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['name']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['email']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['telefon']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['adresse']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['plz']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['ort']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['link']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#newOrganizer['beschreibung']#">
            )
        </cfquery>

        <!--- extract artist ID --->
        <cfset organizerID = dbResult.generatedKey>

        <!--- count incoming images --->
        <cfset imageCount = 0>
        <cfloop collection="#formStruct#" item="key">
            <cfif REFind("^image_\d+$", key)>
                <cfset imageCount = imageCount + 1>
            </cfif>
        </cfloop>

        <cfloop from="0" to="#imageCount - 1#" index="i">
            <!--- upload image --->
            <cfset uploadResult = uploadIntoMediaArchive("image_#i#", 1301, maOrganizer, "automatisch")>

            <!--- associate with regional highlight --->
            <cfinvoke component="/ameisen/components/mediaarchive" method="addUploadForInstance">
                <cfinvokeargument name="instance" value="#organizerID#">
                <cfinvokeargument name="uploadfield" value="bilder">
                <cfinvokeargument name="addid" value="#uploadResult.instanceid#">
                <cfinvokeargument name="nodetype" value="2101">
            </cfinvoke>

        </cfloop>

        <cfcontent type="application/json">

        <cfheader statuscode="200" statustext="OK">
        <cfset response['formStruct'] = formStruct>
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully created new organizer.">
        <cfreturn response>

    </cffunction>


    <!--- ############################## --->
    <!--- #   FETCH ORGANIZER DETAIL   # --->
    <!--- ############################## --->

    <cffunction name="fetchOrganizerDetail" access="remote" returnFormat="JSON">
        <!--- Handle OPTIONS preflight requests --->\n        <cfif uCase(cgi.request_method) EQ "OPTIONS">\n            <cfheader statuscode="200" statustext="OK">\n            <cfabort>\n        </cfif>

        <!--- argument --->
        <cfargument name="id" type="numeric" required="no">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['organizer'] = {}>

        <!--- check for correct call --->
        <cfif StructKeyExists(arguments, 'id')>

            <cfquery name="organizerDetail" datasource="#getConfig('DSN')#">
                SELECT 
                    ku.id AS userID,
                    ku.kb_username AS username,
                    ku.kb_email AS email,
                    ko.id AS organizerID,
                    ko.name,
                    ko.description,
                    ko.address,
                    ko.location_fk,
                    ko.phone_number,
                    ko.website,
                    ko.images AS imgs,
                    ko.uploads,
                    ko.approved
                FROM kb_organizer AS ko
                JOIN kb_user AS ku
                ON ko.user_fk = ku.id
                WHERE ko.user_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['id']#">;
            </cfquery>

            <cfloop query="organizerDetail">
                <cfset organizer = {}>
                <cfset organizer['user_id'] = organizerDetail.userID>
                <cfset organizer['username'] = organizerDetail.username>
                <cfset organizer['email'] = organizerDetail.email>
                <cfset organizer['organizer_id'] = organizerDetail.organizerID>
                <cfset organizer['name'] = organizerDetail.name>
                <cfset organizer['description'] = organizerDetail.description>
                <cfset organizer['location'] = organizerDetail.location_fk>
                <cfset organizer['address'] = organizerDetail.address>
                <cfset organizer['phone'] = organizerDetail.phone_number>
                <cfset organizer['email'] = organizerDetail.email>
                <cfset organizer['link'] = organizerDetail.website>
                <cfset organizer['imgs'] = organizerDetail.imgs>
                <cfset organizer['approved'] = organizerDetail.approved>
                <!--- evaluate images --->
                <cfset organizer['images'] = []>
                <cfif organizerDetail['imgs'] NEQ "">
                    <cfset images = getStructuredContent(nodetype=1301, instanceids="#organizerDetail['imgs']#")>
                    <cfloop query="images">
                        <!--- construct individual images --->
                        <cfset image = {}>
                        <cfset image['id'] = images.id>
                        <cfset image['path'] = href("instance:"&images.id)&"&dimensions=300x150&cropmode=cropcenter">
                        <cfset image['filename'] = images.originalfilename>
                        <cfset ArrayAppend(organizer['images'], image)>
                    </cfloop>
                </cfif>
                <!--- --->
                <cfset response['organizer'] = organizer>
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

</cfcomponent>