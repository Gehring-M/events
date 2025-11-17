<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">


    <!--- ############################### --->
    <!--- #   UPDATE EVENT VISIBILITY   # --->
    <!--- ############################### --->

    <cffunction name="updateEventVisibility" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var requestData = deserializeJSON(getHttpRequestData().content)>
        <cfset response = {}>
        
        <cfif isAdmin() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>

            <cfif StructKeyExists(requestData, 'eventID') AND StructKeyExists(requestData, 'visibility')>

                <cfquery name="eventsInQuestion" datasource="#getConfig('DSN')#">
                    SELECT id 
                    FROM veranstaltung 
                    WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData['eventID']#"> 
                    OR parent_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData['eventID']#">;
                </cfquery>

                <cfset idArray = []>
                <cfloop query="eventsInQuestion">
                    <cfset ArrayAppend(idArray, eventsInQuestion.id)>
                </cfloop>
                <cfset idList = ArrayToList(idArray)>

                <cfquery name="updateEvents" datasource="#getConfig('DSN')#" result="updateResult">
                    UPDATE veranstaltung 
                    SET 
                        visible = <cfqueryparam cfsqltype="cf_sql_smallint" value="#requestData['visibility']#">,
                        changed_by_kbsz = 1
                    WHERE id IN (#idList#);
                </cfquery>

                <cfset response['success'] = true>
                <cfset response['info'] = updateResult>
                <cfset response['message'] = "Successfully updated events!">
                <cfreturn response>

            <cfelse>
                <cfset response['success'] = false>
                <cfset response['message'] = "Please ensure to provide the following structure: { eventID }">
                <cfreturn response>
            </cfif>

        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated!">
            <cfreturn response>
        </cfif>

    </cffunction>


    <!--- ########################### --->
    <!--- #   GET MAIN EVENT LIST   # --->
    <!--- ########################### --->

    <cffunction name="getMainEventList" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset response = {}>

        <cfif isAdmin() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>

            <!--- add property to response --->
            <cfset response['mainEvents'] = []>

            <cfquery name="mainEvents" datasource="#getConfig('DSN')#">
                SELECT id, name
                FROM veranstaltung
                WHERE parent_fk IS NULL AND (deactivated = 0 OR deactivated IS NULL);
            </cfquery>

            <cfloop query="mainEvents">
                <cfset mainEvent = {}>
                <cfset mainEvent['recordid'] = mainEvents.id>
                <cfset mainEvent['name'] = mainEvents.name>
                <cfset ArrayAppend(response['mainEvents'], mainEvent)>
            </cfloop>

            <cfset response['success'] = true>
            <cfreturn response>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated!">
            <cfreturn response>
        </cfif>

    </cffunction>


    <!--- ####################### --->
    <!--- #   GET SLIDER TAGS   # --->
    <!--- ####################### --->

    <cffunction name="getSliderTags" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset response = {}>

        <cfif isAdmin() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>

            <!--- add property to response --->
            <cfset response['sliderTags'] = []>

            <cfquery name="sliderTags" datasource="#getConfig('DSN')#">
                SELECT id, name
                FROM slider_tag
                ORDER BY name ASC;
            </cfquery>

            <cfloop query="sliderTags">
                <cfset sliderTag = {}>
                <cfset sliderTag['recordid'] = sliderTags.id>
                <cfset sliderTag['name'] = sliderTags.name>
                <cfset ArrayAppend(response['sliderTags'], sliderTag)>
            </cfloop>

            <cfset response['success'] = true>
            <cfreturn response>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated!">
            <cfreturn response>
        </cfif>

    </cffunction>



    <!--- #################### --->
    <!--- #   DELETE IMAGE   # --->
    <!--- #################### --->

    <cffunction name="deleteImage" access="remote" returnFormat="JSON">
        
        <!--- arguments --->
        <cfargument name="imageID" type="numeric" required="no">

        <!--- init --->
        <cfset response = {}>

        <cfif isAuth() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>
            <!--- check incoming data --->
            <cfif StructKeyExists(arguments, 'imageID')>

                <!--- get event ID(s) --->
                <cfquery name="relatedEventIDs" datasource="#getConfig('DSN')#">
                    SELECT id
                    FROM veranstaltung
                    WHERE FIND_IN_SET(<cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.imageID#">, bilder);
                </cfquery>

                <!--- get a list of event IDs --->
                <cfset eventIDs = []>
                <cfloop query="relatedEventIDs">
                    <cfset ArrayAppend(eventIDs, relatedEventIDs.id)>
                </cfloop>

                <!--- remove associated images from events --->
                <cfloop array="#eventIDs#" item="eventID">
                    <cfset result = removeMediaArchiveUploadFlat(eventID, 'bilder', arguments.imageID, 2102)>
                </cfloop>

                <!--- remove image --->
                <cfset deletionResult = deleteStructuredContent(arguments.imageID)>

                <cfset response['success'] = true>
                <cfset response['message'] = "Successfully deleted image">
                <cfreturn response>
            <cfelse>
                <cfset response['success'] = false>
                <cfset response['message'] = "Please provide the following URL param: { eventID }">
                <cfreturn response>
            </cfif>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated">
            <cfreturn response>
        </cfif>

    </cffunction>



    <!--- ###################### --->
    <!--- #   GET SUB EVENTS   # --->
    <!--- ###################### --->

    <cffunction name="getSubEvents" access="remote" returnFormat="JSON" output="no">
	
        <!--- arguments --->
        <cfargument name="mainEventID" type="string" required="no">

        <!--- init --->
        <cfset response = {}>

        <cfif isAuth() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>
            <!--- check incoming data --->
            <cfif StructKeyExists(arguments, 'mainEventID')>

                <cfquery name="qSubEvents" datasource="#getConfig('DSN')#">
                    SELECT 
                        v1.*, 
                        v2.name AS parent_name
                    FROM 
                        veranstaltung AS v1 
                        LEFT JOIN veranstaltung AS v2
                        ON v1.parent_fk = v2.id
                    WHERE 
                        v1.deactivated = 0 AND v1.parent_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['mainEventID']#">
                    ORDER BY 
                        v1.von, v1.uhrzeitvon
                </cfquery>

                <cfset response['subevents'] = []>

                <!--- construct objects --->
                <cfloop query="qSubEvents">
                    <cfset subEvent = {}>
                    <cfset subEvent['recordid'] = qSubEvents.id>
                    <cfset subEvent['parent_fk'] = qSubEvents.parent_fk>
                    <cfset subEvent['opened'] = 0> <!--- ?? --->
                    <cfset subEvent['name'] = qSubEvents.name>
                    <cfset subEvent['parent_name'] = qSubEvents.parent_name>
                    <cfset subEvent['von'] = qSubEvents.von>
                    <cfset subEvent['bis'] = qSubEvents.bis>
                    <cfset subEvent['uhrzeitvon'] = qSubEvents.uhrzeitvon>
                    <cfset subEvent['uhrzeitbis'] = qSubEvents.uhrzeitbis>
                    <cfset subEvent['ort_fk'] = qSubEvents.ort_fk>
                    <cfset subEvent['ort_name'] = qSubEvents.ort_fk> <!--- ?? ---> 
                    <cfset subEvent['bezirk'] = qSubEvents.ort_fk> <!--- ?? --->
                    <cfset subEvent['veranstaltungsort'] = qSubEvents.veranstaltungsort>
                    <cfset subEvent['adresse'] = qSubEvents.adresse>
                    <cfset subEvent['plz'] = qSubEvents.plz>
                    <cfset subEvent['ort'] = qSubEvents.ort>
                    <cfset subEvent['latitude'] = qSubEvents.latitude>
                    <cfset subEvent['longitude'] = qSubEvents.longitude>
                    <cfset subEvent['beschreibung'] = qSubEvents.beschreibung>
                    <cfset subEvent['preis'] = qSubEvents.preis>
                    <cfset subEvent['bilder'] = qSubEvents.bilder>
                    <cfset subEvent['link'] = qSubEvents.link>
                    <cfset subEvent['uploads'] = qSubEvents.uploads>
                    <cfset subEvent['optionstyle'] = "font-weight: bold; border-bottom: 1px dotted ##e6e6e6; padding: 1px 6px;"> <!--- ?? --->
                    <cfset subEvent['tipp'] = qSubEvents.tipp>
                    <cfset subEvent['kinder'] = qSubEvents.kinder>
                    <cfset subEvent['showteasertext'] = qSubEvents.showteasertext>
                    <cfset subEvent['duplicate_fk'] = qSubEvents.duplicate_fk>
                    <cfset subEvent['visible'] = qSubEvents.visible>
                    <cfset subEvent['next'] = qSubEvents.next>
                    <cfset subEvent['extern'] = qSubEvents.extern>
                    <cfset subEvent['deactivated'] = qSubEvents.deactivated>
                    <cfset subEvent['deactivatedwhen'] = qSubEvents.deactivatedwhen>
                    <cfset subEvent['changed_by_kbsz'] = qSubEvents.changed_by_kbsz>
                    <cfset subEvent['geodatenpool_id'] = qSubEvents.geodatenpool_id>
                    <cfset subEvent['import_status'] = qSubEvents.import_status>
                    <cfset subEvent['slider_tag_fk'] = qSubEvents.slider_tag_fk>
                    <cfset ArrayAppend(response['subevents'], subEvent)>
                </cfloop>

                <cfset response['success'] = true>
                <cfset response['message'] = "Successfully fetched subevents for main event [#mainEventID#]">
                <cfreturn response>
            <cfelse>
                <cfset response['success'] = false>
                <cfset response['message'] = "Please provide the following URL param: { mainEventID }">
                <cfreturn response>
            </cfif>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated">
            <cfreturn response>
        </cfif>
    </cffunction>	

</cfcomponent>