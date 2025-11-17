<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">


    <!--- ###################### --->
    <!--- #   GET EVENT LIST   # --->
    <!--- ###################### --->

    <!---
    Return just the data that is needed to display the list items
    Specific event data is loaded if needed
    --->

    <cffunction name="getEventList" access="remote" returnFormat="JSON">

        <!--- arguments --->
        <cfargument name="eventsFilter" type="string" required="false">
        <cfargument name="eventsTitle" type="string" required="false"> 
        <cfargument name="eventsFrom" type="string" required="false">
        <cfargument name="eventsTill" type="string" required="false">

        <!--- init --->
        <cfset response = {}>

        <cfif isAuth() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>
            
            <!--- validate arguments --->
            <cfif StructKeyExists(arguments, 'eventsFilter') AND StructKeyExists(arguments, 'eventsTitle') AND StructKeyExists(arguments, 'eventsFrom') AND StructKeyExists(arguments, 'eventsTill')>

                <!--- expand response data --->
                <cfset response['events'] = []>

                <!--- fetch data from DB --->
                <cfquery name="eventsList" datasource="#getConfig('DSN')#">
                    SELECT id, name, von, bis, uhrzeitvon, uhrzeitbis, veranstaltungsort, adresse, ort, visible, changed_by_kbsz 
                    FROM veranstaltung
                    WHERE 1 = 1
                    <!--- consider events filter --->
                    <cfif arguments['eventsFilter'] NEQ "">
                        <cfswitch expression="#arguments['eventsFilter']#">
                            <cfcase value="not_treated">
                                AND changed_by_kbsz = 0 AND visible = 0
                            </cfcase>
                            <cfcase value="active">
                                AND changed_by_kbsz = 1 AND visible = 1
                            </cfcase>
                            <cfcase value="inactive">
                                AND changed_by_kbsz = 1 AND visible = 0
                            </cfcase>
                            <!--- fallback (all events) --->
                            <cfdefaultcase>
                                AND 1 = 1
                            </cfdefaultcase>
                        </cfswitch>
                    </cfif>
                    <!--- consider events searchstring and insert separately for safety --->
                    <cfif arguments['eventsTitle'] NEQ "">
                        <cfset searchString = "%" & arguments['eventsTitle'] & "%">
                        AND name LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#searchString#">
                    </cfif>
                    <!--- consider from date --->
                    <cfif arguments['eventsFrom'] NEQ "">
                        AND von >= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments['eventsFrom']#">
                    </cfif>
                    <!--- consider till date --->
                    <cfif arguments['eventsTill'] NEQ "">
                        AND bis <= <cfqueryparam cfsqltype="cf_sql_date" value="#arguments['eventsTill']#">
                    </cfif>
                </cfquery>

                <!--- construct response data --->
                <cfloop query="eventsList">
                    <!--- reset --->
                    <cfset event = {}>
                    <cfset event['id'] = eventsList.id>
                    <cfset event['name'] = eventsList.name>
                    <cfset event['from_date'] = eventsList.von>
                    <cfset event['till_date'] = eventsList.bis>
                    <cfset event['from_time'] = eventsList.uhrzeitvon>
                    <cfset event['till_time'] = eventsList.uhrzeitbis>
                    <cfset event['event_location'] = eventsList.veranstaltungsort>
                    <cfset event['address'] = eventsList.adresse>
                    <cfset event['location'] = eventsList.ort>
                    <cfset event['region'] = 'Dummydata'>
                    <cfset event['visible'] = eventsList.visible>
                    <cfset event['changed_by_kbsz'] = eventsList.changed_by_kbsz>
                    <cfset ArrayAppend(response['events'], event)>
                </cfloop>
                <cfset response['success'] = true>
                <cfset response['debug'] = {}>
                <cfset response['debug']['eventsFilter'] = arguments.eventsFilter>
                <cfset response['debug']['eventsTitle'] = arguments.eventsTitle>
                <cfset response['debug']['eventsFrom'] = arguments.eventsFrom>
                <cfset response['debug']['eventsTill'] = arguments.eventsTill>
                <cfset response['message'] = "Successfully send a list of events.">
                <cfreturn response>
            <cfelse>
                <cfset response['success'] = false>
                <cfset response['message'] = "Please provide the following URL parameter: 'eventsFilter', 'eventsTitle', 'eventsFrom', 'eventsTill'">
                <cfheader statuscode="400" statustext="Bad Request">
                <cfreturn response>
            </cfif>
        <cfelse>
            <cfset response['success'] = false>
            <cfset response['message'] = "User is not authorized">
            <cfheader statuscode="401" statustext="Unauthorized">
            <cfreturn response>
        </cfif>
    </cffunction>

</cfcomponent>