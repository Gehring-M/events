<cfcomponent>

    <!--- includes --->
    <cfinclude template="../../ameisen/functions.cfm">



    <!--- ######################## --->
    <!--- #   SLIDER LOCATIONS   # --->
    <!--- ######################## --->

    <cffunction name="sliderLocations" access="remote" returnFormat="JSON">

        <!--- arguments --->
        <cfargument name="username" type="string" required="no" default="">
        <cfargument name="password" type="string" required="no" default="">

        <!--- init --->
        <cfset response = {}>
        <cfset response['locations'] = []>

        <!--- authenticate --->
        <cfset authStruct = authenticate(arguments['username'], arguments['password'], 'page')>

	    <cfif authStruct.authenticated>

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
                WHERE rh.aktiv = 1;
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
                            <cfset image['path'] = "https://#CGI.SERVER_NAME#"&href("instance:"&images.id)&"&dimensions=900x450&cropmode=cropcenter">
                            <cfset image['filename'] = images.originalfilename>
                            <cfset ArrayAppend(activeLocation['images'], image)>
                        </cfloop>
                    <cfelse>
                        <cfset image = {}>
                        <cfset image['path'] = "/img/fallback_events.jpg">
                        <cfset image['filename'] = "fallbackImage">
                        <cfset ArrayAppend(activeLocation['images'], image)>
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
            <cfset response['message'] = "You are not authenticated.">
            <cfreturn response>
        </cfif>

    </cffunction>


    <!--- ###################### --->
    <!--- #   SLIDER ARTISTS   # --->
    <!--- ###################### --->

    <cffunction name="sliderArtists" access="remote" returnFormat="JSON">

        <!--- arguments --->
        <cfargument name="username" type="string" required="no" default="">
        <cfargument name="password" type="string" required="no" default="">

        <!--- init --->
        <cfset response = {}>
        <cfset response['artists'] = []>

        <!--- authenticate --->
        <cfset authStruct = authenticate(arguments['username'], arguments['password'], 'page')>

	    <cfif authStruct.authenticated>

            <cfquery name="sliderArtists" datasource="#getConfig('DSN')#">
                SELECT id, name, bilder 
                FROM artist
                WHERE deactivated = 0 AND approved = 1
            </cfquery>

            <cfif sliderArtists.recordcount GT 0>
                <cfloop query="sliderArtists">
                    <!--- artist --->
                    <cfset sliderArtist = {}>
                    <cfset sliderArtist['id'] = sliderArtists['id']>
                    <cfset sliderArtist['name'] = sliderArtists['name']>
                    <cfset sliderArtist['images'] = []>
                    <!--- extract images --->
                    <cfif sliderArtists['bilder'] NEQ "">
                        <cfset images = getStructuredContent(nodetype=1301, instanceids=sliderArtists.bilder)>
                        <cfloop query="images">
                            <!--- image --->
                            <cfset image = {}>
                            <cfset image['id'] = images.id>
                            <cfset image['path'] = "https://#CGI.SERVER_NAME#"&href("instance:"&images.id)&"&dimensions=900x450&cropmode=cropcenter">
                            <cfset image['filename'] = images.originalfilename>
                            <cfset ArrayAppend(sliderArtist['images'], image)>
                        </cfloop>
                    <cfelse>
                        <cfset image = {}>
                        <cfset image['path'] = "/img/fallback_events.jpg">
                        <cfset image['filename'] = "fallbackImage">
                        <cfset ArrayAppend(sliderArtist['images'], image)>
                    </cfif>
                    <!--- append artist --->
                    <cfset ArrayAppend(response['artists'], sliderArtist)>
                </cfloop>
            </cfif>
            <cfset response['success'] = true>
            <cfset response['message'] = "Sending artists...">
            <cfreturn response>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated.">
            <cfreturn response>
        </cfif>


    </cffunction>
    
</cfcomponent>