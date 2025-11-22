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

</cfcomponent>