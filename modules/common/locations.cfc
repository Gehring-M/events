<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">


    <!--- ################################# --->
    <!--- #   FETCH REGIONAL HIGHLIGHTS   # --->
    <!--- ################################# --->

    <cffunction name="fetchRegionalHighlights" access="remote" returnFormat="JSON">

        <cfset response['regional_highlights'] = []>

        <cfquery name="rhs" datasource="#getConfig('DSN')#">
            SELECT rh.id, rh.adresse, rh.name AS regional_highlight, rh.beschreibung, rh.kulturrelevant, rh.active AS aktiv, o.name AS ortsname, b.name AS bezirksname
            FROM regional_highlights AS rh
            JOIN ort AS o
            ON rh.ort_fk = o.id
            JOIN bezirk AS b
            ON o.bezirk_fk = b.id
        </cfquery>

        <cfloop query="rhs">
            <!--- reset --->
            <cfset regionalHighlight = {}>
            <!--- construct object --->
            <cfset regionalHighlight['id'] = rhs['id']>
            <cfset regionalHighlight['adresse'] = rhs['adresse']>
            <cfset regionalHighlight['name'] = rhs['regional_highlight']>
            <cfset regionalHighlight['beschreibung'] = rhs['beschreibung']>
            <cfset regionalHighlight['kulturrelevant'] = rhs['kulturrelevant']>
            <cfset regionalHighlight['aktiv'] = rhs['aktiv']>
            <cfset regionalHighlight['ortsname'] = rhs['ortsname']>
            <cfset regionalHighlight['bezirksname'] = rhs['bezirksname']>
            <!--- append --->
            <cfset ArrayAppend(response['regional_highlights'], regionalHighlight)>
        </cfloop>

        <cfreturn response>

    </cffunction>


    <!--- ####################### --->
    <!--- #   FETCH LOCATIONS   # --->
    <!--- ####################### --->
    
    <cffunction name="fetchLocations" access="remote" returnFormat="JSON">

        <cfset response['locations'] = []>

        <cfquery name="locations" datasource="#getConfig('DSN')#">
            SELECT id, name 
            FROM ort 
            ORDER BY name ASC;
        </cfquery>

        <cfloop query="locations">
            <!--- reset --->
            <cfset location = {}>
            <!--- construct object --->
            <cfset location['id'] = locations.id>
            <cfset location['name'] = locations.name>
            <!--- append --->
            <cfset ArrayAppend(response['locations'], location)>
        </cfloop>

        <cfreturn response>

    </cffunction>


    <!--- ####################### --->
    <!--- #   CREATE LOCATION   # --->
    <!--- ####################### --->

    <cffunction name="createLocation" access="remote" returnFormat="JSON">
        
        <!--- init --->
        <cfset var requestData = deserializeJSON(getHttpRequestData().content)>
        <cfset var response = {}>

        <cfif isAdmin() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>
            <!--- check properties --->
            <cfif StructKeyExists(requestData, 'name') AND StructKeyExists(requestData, 'adresse') AND StructKeyExists(requestData, 'ort_fk') AND StructKeyExists(requestData, 'beschreibung') AND StructKeyExists(requestData, 'kulturrelevant') AND StructKeyExists(requestData, 'aktiv')>
                <cfset user_fk = session.user.data.userid>
                <cfquery name="saveLocation" datasource="#getConfig('DSN')#">
                    INSERT INTO regional_highlights (name, adresse, ort_fk, beschreibung, kulturrelevant, active, created_fk)
                    VALUES (
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestData.name#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestData.adresse#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData.ort_fk#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestData.beschreibung#">,
                        <cfqueryparam cfsqltype="cf_sql_smallint" value="#requestData.kulturrelevant#">,
                        <cfqueryparam cfsqltype="cf_sql_smallint" value="#requestData.aktiv#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#user_fk#">
                    );
                </cfquery>
                <cfset response['success'] = true>
                <cfset response['user_fk'] = user_fk>
                <cfset response['message'] = 'The new regional highlight was created successfully'>
            <cfelse>
                <!--- wrong arguments --->
                <cfset response['success'] = false>
                <cfset response['message'] = 'Please ensure to provide the following data: { name, adresse, ort_fk, beschreibung, kulturrelevant, aktiv }'>
            </cfif>
        <cfelse>
            <!--- not authenticated --->
            <cfset response['success'] = false>
            <cfset response['message'] = 'You are not authenticated'>
        </cfif>

        <cfreturn response>

    </cffunction>


    <!--- #################### --->
    <!--- #   UPLOAD IMAGE   # --->
    <!--- #################### --->

    <cffunction name="uploadImage" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset formStruct = formToStruct()>
        <cfset response = {}>

        <!--- upload image --->
        <cfif isAdmin() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>

            <!--- ensure correct media archive --->
            <cfset maPath = getConfig('vpath.regional.highlights')>
            <cfif maPath EQ "" OR NOT pathExists(maPath)>
                <cfset response['success'] = false>
                <cfset response['message'] = "Make sure to create the media archive" & getConfig('vpath.regional.highlights') & " first!">
                <cfreturn response>
            </cfif>
            <cfset maCatNode = getNodeId(resolvePath(maPath))>

            <!--- validate arguments --->
            <cfif StructKeyExists(formStruct, 'file') AND StructKeyExists(formStruct, 'locationID') AND StructKeyExists(formStruct, 'filename')>
                
                <!--- save image --->
                <cfset uploadResult = uploadIntoMediaArchive("file", 1301, maCatNode, "automatisch")>

                <!--- associate with regional highlight --->
                <cfinvoke component="/ameisen/components/mediaarchive" method="addUploadForInstance">
                    <cfinvokeargument name="instance" value="#formStruct['locationID']#">
                    <cfinvokeargument name="uploadfield" value="bilder">
                    <cfinvokeargument name="addid" value="#uploadResult.instanceid#">
                    <cfinvokeargument name="nodetype" value="2112">
                </cfinvoke>

                <cfset response['test'] = getComponentMetadata("/ameisen/components/mediaarchive")>
                <cfset response['success'] = true>
                <cfset response['upload_result'] = uploadResult>
                <cfset response['message'] = "Successfully uploaded new image for locationID: " & formStruct['locationID']>
                <cfreturn response>
            <cfelse>
                <cfset response['success'] = false>
                <cfset response['message'] = "Make sure the client sends data as 'multipart-formdata' and provides the following data: { file, filename, locationID }">
                <cfreturn response>
            </cfif>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated!">
            <cfreturn response>
        </cfif>
    </cffunction>


    <!--- #################### --->
    <!--- #   FETCH IMAGES   # --->
    <!--- #################### --->

    <cffunction name="fetchImages" access="remote" returnFormat="JSON">

        <!--- arguments --->
        <cfargument name="locationID" type="string" required="yes">

        <!--- init --->
        <cfset response = {}>
        <cfset response['images'] = []>

        <cfquery name="locationImages" datasource="#getConfig('DSN')#">
            SELECT bilder FROM regional_highlights WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['locationID']#">;
        </cfquery> 

        <cfif locationImages['bilder'] NEQ "">
            <cfset images = getStructuredContent(nodetype=1301, instanceids="#locationImages['bilder']#")>
            <cfloop query="images">
                <!--- reset --->
                <cfset image = {}>
                <cfset image['id'] = images.id>
                <cfset image['path'] = href("instance:"&images.id)&"&dimensions=300x150&cropmode=cropcenter">
                <cfset image['filename'] = images.originalfilename>
                <cfset ArrayAppend(response['images'], image)>
            </cfloop>
        </cfif>

        <cfreturn response>

    </cffunction>


    <!--- ######################## --->
    <!--- #   SLIDER LOCATIONS   # --->
    <!--- ######################## --->

    <cffunction name="sliderLocations" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset response = {}>
        <cfset response['locations'] = []>


        <cfif isAdmin() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>

            <cfquery name="activeLocations" datasource="#getConfig('DSN')#">
                SELECT 
                    rh.id AS id,
                    rh.adresse AS adresse,
                    rh.name AS name,
                    rh.beschreibung AS beschreibung,
                    rh.bilder AS bilder,
                    o.name AS ort_name,
                    b.name AS bezirk_name
                FROM regional_highlights AS rh
                JOIN ort AS o 
                ON rh.ort_fk = o.id
                JOIN bezirk as b
                ON o.bezirk_fk = b.id
                WHERE rh.active = 1;
            </cfquery>

            <cfif activeLocations.recordcount GT 0>
                <cfloop query="activeLocations">
                    <!--- location --->
                    <cfset activeLocation = {}>
                    <cfset activeLocation['id'] = activeLocations['id']>
                    <cfset activeLocation['address'] = activeLocations['adresse']>
                    <cfset activeLocation['name'] = activeLocations['name']>
                    <cfset activeLocation['description'] = activeLocations['beschreibung']>
                    <cfset activeLocation['location'] = activeLocations['ort_name']>
                    <cfset activeLocation['district'] = activeLocations['bezirk_name']>
                    <cfset activeLocation['images'] = []>
                    <!--- extract images --->
                    <cfif activeLocations['bilder'] NEQ "">
                        <cfset images = getStructuredContent(nodetype=1301, instanceids=activeLocations.bilder)>
                        <cfloop query="images">
                            <!--- image --->
                            <cfset image = {}>
                            <cfset image['id'] = images.id>
                            <cfset image['path'] = href("instance:"&images.id)&"&dimensions=300x150&cropmode=cropcenter">
                            <cfset image['filename'] = images.originalfilename>
                            <cfset ArrayAppend(activeLocation['images'], image)>
                        </cfloop>
                    </cfif>
                    <!--- append location --->
                    <cfset ArrayAppend(response['locations'], activeLocation)>
                </cfloop>
            </cfif>
            <cfset response['success'] = true>
            <cfset response['message'] = "Sending locations...">
            <cfreturn response>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated!">
            <cfreturn response>
        </cfif>

    </cffunction>

</cfcomponent>