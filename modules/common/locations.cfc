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
            SELECT rh.id, rh.adresse, rh.name AS regional_highlight, rh.beschreibung, rh.kulturrelevant, o.name AS ortsname, b.name AS bezirksname
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
            <cfif StructKeyExists(requestData, 'name') AND StructKeyExists(requestData, 'adresse') AND StructKeyExists(requestData, 'ort_fk') AND StructKeyExists(requestData, 'beschreibung') AND StructKeyExists(requestData, 'kulturrelevant')>
                <cfset user_fk = session.user.data.userid>
                <cfquery name="saveLocation" datasource="#getConfig('DSN')#">
                    INSERT INTO regional_highlights (name, adresse, ort_fk, beschreibung, kulturrelevant, created_fk)
                    VALUES (
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestData.name#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestData.adresse#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData.ort_fk#">,
                        <cfqueryparam cfsqltype="cf_sql_varchar" value="#requestData.beschreibung#">,
                        <cfqueryparam cfsqltype="cf_sql_smallint" value="#requestData.kulturrelevant#">,
                        <cfqueryparam cfsqltype="cf_sql_integer" value="#user_fk#">
                    );
                </cfquery>
                <cfset response['success'] = true>
                <cfset response['user_fk'] = user_fk>
                <cfset response['message'] = 'The new regional highlight was created successfully'>
            <cfelse>
                <!--- wrong arguments --->
                <cfset response['success'] = false>
                <cfset response['message'] = 'Please ensure to provide the following data: { name, adresse, ort_fk, beschreibung, kulturrelevant }'>
            </cfif>
        <cfelse>
            <!--- not authenticated --->
            <cfset response['success'] = false>
            <cfset response['message'] = 'You are not authenticated'>
        </cfif>

        <cfreturn response>

    </cffunction>

</cfcomponent>