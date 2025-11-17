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

    <!--- ############################# --->
    <!--- #   FETCH UPCOMING EVENTS   # --->
    <!--- ############################# --->

    <cffunction name="fetchUpcomingEvents" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['upcoming_events'] = []>

        <cfquery name="upcomingEvents" datasource="#getConfig('DSN')#">
            SELECT 
                v.id AS event_id,
                v.name AS event_name,
                v.von AS event_from,
                v.bis AS event_till,
                r.id AS region_id,
                r.name AS region_name
            FROM (
                SELECT 
                    rv.region_fk,
                    MIN(CONCAT(LPAD(ver.von, 20, '0'), '-', LPAD(ver.id, 10, '0'))) AS min_key
                FROM r_veranstaltung_region rv
                JOIN veranstaltung ver ON rv.veranstaltung_fk = ver.id
                WHERE ver.von > CURRENT_TIMESTAMP
                AND ver.visible = 1
                AND (ver.deactivated IS NULL OR ver.deactivated = 0)
                AND (
                    (
                        EXISTS (
                            SELECT 1
                            FROM r_veranstaltung_region rv2
                            JOIN veranstaltung ver2 ON rv2.veranstaltung_fk = ver2.id
                            WHERE rv2.region_fk = rv.region_fk
                            AND ver2.von > CURRENT_TIMESTAMP
                            AND ver2.visible = 1
                            AND (ver2.deactivated IS NULL OR ver2.deactivated = 0)
                            AND ver2.next = 1
                        )
                        AND ver.next = 1
                    )
                    OR (
                        NOT EXISTS (
                            SELECT 1
                            FROM r_veranstaltung_region rv2
                            JOIN veranstaltung ver2 ON rv2.veranstaltung_fk = ver2.id
                            WHERE rv2.region_fk = rv.region_fk
                            AND ver2.von > CURRENT_TIMESTAMP
                            AND ver2.visible = 1
                            AND (ver2.deactivated IS NULL OR ver2.deactivated = 0)
                            AND ver2.next = 1
                        )
                    )
                )
                GROUP BY rv.region_fk
            ) AS sub
            JOIN r_veranstaltung_region rv ON rv.region_fk = sub.region_fk
            JOIN veranstaltung v ON v.id = rv.veranstaltung_fk
            JOIN region r ON r.id = sub.region_fk
            WHERE CONCAT(LPAD(v.von, 20, '0'), '-', LPAD(v.id, 10, '0')) = sub.min_key
            AND v.visible = 1
            AND (v.deactivated IS NULL OR v.deactivated = 0)
            ORDER BY v.von ASC;
        </cfquery>

        <cfloop query="upcomingEvents">
            <cfset upcomingEvent = {}>
            <cfset upcomingEvent['event_id'] = upcomingEvents.event_id>
            <cfset upcomingEvent['event_name'] = upcomingEvents.event_name>
            <cfset upcomingEvent['event_from'] = parseAndFormatDate(upcomingEvents.event_from)>
            <cfset upcomingEvent['event_till'] = parseAndFormatDate(upcomingEvents.event_till)>
            <cfset upcomingEvent['region_id'] = upcomingEvents.region_id>
            <cfset upcomingEvent['region_name'] = upcomingEvents.region_name>
            <cfset ArrayAppend(response['upcoming_events'], upcomingEvent)>
        </cfloop>

        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully fetched upcoming events">
        <cfreturn response>

    </cffunction>


    <!--- ################################## --->
    <!--- #   FETCH CULTURE SLIDER ITEMS   # --->
    <!--- ################################## --->

    <cffunction name="fetchCultureSliderItems" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['culture_slider'] = []>

        <!--- fetch events for the culture slider --->
        <cfquery name="cultureSliderEvents" datasource="#getConfig('DSN')#">
            SELECT 
                id,
                name,
                von,
                bis,
                bilder, 
                (
                    SELECT st.name
                    FROM slider_tag AS st
                    WHERE slider_tag_fk = st.id
                ) 
                AS culture_tag
            FROM veranstaltung
            WHERE EXISTS 
            (
                SELECT 1 
                FROM slider_tag AS st
                WHERE slider_tag_fk = st.id
            )
            AND bis >= CURRENT_DATE()
            AND parent_fk IS NULL
            AND visible = 1
            AND changed_by_kbsz = 1
            ORDER BY von;
        </cfquery>

        <!--- construct objects --->
        <cfloop query="cultureSliderEvents">
            <cfset cultureSliderEvent = {}>
            <cfset cultureSliderEvent['event_id'] = cultureSliderEvents.id>
            <cfset cultureSliderEvent['event_name'] = cultureSliderEvents.name>
            <cfset cultureSliderEvent['event_from'] = parseAndFormatDate(cultureSliderEvents.von)>
            <cfset cultureSliderEvent['event_till'] = parseAndFormatDate(cultureSliderEvents.bis)>
            <!--- evaluate image (might need improvement) --->
            <cfset cultureSliderEvent['event_img'] = {}>
            <!------>
            <cfif cultureSliderEvents.bilder NEQ "">
                <cfset image = getStructuredContent(nodetype=1301, instanceids="#cultureSliderEvents['bilder']#", orderclause="createdwhen DESC", maxrows=1)>
                <!--- construct image object --->
                <cfif image.recordCount EQ 1>
                    <cfset cultureSliderEvent['event_img']['path'] = href("instance:" & image.id) & "&dimensions=300x150&cropmode=cropcenter">
                    <cfset cultureSliderEvent['event_img']['name'] = image.originalfilename>
                <!--- shouldn't happen bust just in case --->
                <cfelse>
                    <cfset cultureSliderEvent['event_img']['path'] = NULL>
                    <cfset cultureSliderEvent['event_img']['name'] = "Fallback">
                </cfif>
            <cfelse>
                <cfset cultureSliderEvent['event_img']['path'] = NULL>
                <cfset cultureSliderEvent['event_img']['name'] = "Fallback">
            </cfif>
            <!------>
            <cfset cultureSliderEvent['event_tag'] = cultureSliderEvents.culture_tag>
            <cfset ArrayAppend(response['culture_slider'], cultureSliderEvent)>
        </cfloop>

        <!--- respond to client --->
        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully fetched slider events">
        <cfreturn response>

    </cffunction>



    <!--- ########################## --->
    <!--- #   FETCH EVENT FILTER   # --->
    <!--- ########################## --->

    <cffunction name="fetchEventFilter" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['event_types'] = []>
        
        <!--- retrieve event types from db --->
        <cfquery name="eventTypes" datasource="#getConfig('DSN')#">
            SELECT id, name
            FROM typ
            WHERE kb = 1;
        </cfquery>

        <!--- build response --->
        <cfloop query="eventTypes">
            <cfset eventType = {}>
            <cfset eventType['typ_id'] = eventTypes.id>
            <!--- parse name (remove numbers and trim whitespace) --->
            <cfset eventType['typ_name'] = Trim(ReReplace(eventTypes.name, "[0-9]", "", "ALL"))>
            <cfset ArrayAppend(response['event_types'], eventType)>
        </cfloop>
        
        <!--- respond to client --->
        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully fetched event filter">
        <cfreturn response>

    </cffunction>


    <!--- #################### --->
    <!--- #   FETCH EVENTS   # --->
    <!--- #################### --->

    <cffunction name="fetchEvents" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var response = {}>
        <cfset var today = DateFormat(Now(), "yyyy-mm-dd")>
        <cfset var eventMap = {}>
        <cfset response['events'] = []>
        
        <!--- retrieve events from db --->
        <cfquery name="events" datasource="#getConfig('DSN')#">
            SELECT 
                v.id AS id, 
                v.name AS name, 
                v.beschreibung AS beschreibung,
                v.von AS von,
                v.bis AS bis,
                v.bilder AS bilder,
                rvt.typ_fk AS typ_id
            FROM veranstaltung AS v
            INNER JOIN r_veranstaltung_typ AS rvt
            ON v.id = rvt.veranstaltung_fk
            -- 1. just content, that was marked as "visible" in the Sencha client
            WHERE v.visible = 1
            -- 2. just content, that wasn't "deleted" in the Sencha client
            AND (v.deactivated IS NULL OR v.deactivated = 0)
            -- show just current and upcoming events
            AND (v.von >= '#today#' OR v.bis >= '#today#')
            ORDER BY v.von ASC, v.id ASC
        </cfquery>

        <!--- build response with grouped type IDs --->
        <cfloop query="events">
            <!--- check if event already exists in map --->
            <cfif NOT StructKeyExists(eventMap, events.id)>
                <!--- create new event object --->
                <cfset event = {}>
                <cfset event['id'] = events.id>
                <cfset event['name'] = events.name>
                <cfset event['description'] = events.beschreibung>
                <cfset event['from'] = parseAndFormatDate(events.von)>
                <cfset event['till'] = parseAndFormatDate(events.bis)>
                <cfset event['event_type'] = []>
                <!--- evaluate image --->
                <cfset event['img'] = {}>
                <cfif events.bilder NEQ "">
                    <cfset image = getStructuredContent(nodetype=1301, instanceids="#events['bilder']#", orderclause="createdwhen DESC", maxrows=1)>
                    <cfif image.recordCount EQ 1>
                        <cfset event['img']['path'] = href("instance:" & image.id) & "&dimensions=300x150&cropmode=cropcenter">
                        <cfset event['img']['name'] = image.originalfilename>
                    <cfelse>
                        <cfset event['img']['path'] = NULL>
                        <cfset event['img']['name'] = "Fallback">
                    </cfif>
                <cfelse>
                    <cfset event['img']['path'] = NULL>
                    <cfset event['img']['name'] = "Fallback">
                </cfif>
                <!--- store in map --->
                <cfset eventMap[events.id] = event>
            </cfif>
            <!--- add type ID to array --->
            <cfset ArrayAppend(eventMap[events.id]['event_type'], events.typ_id)>
        </cfloop>
        
        <!--- convert map to array --->
        <cfloop collection="#eventMap#" item="eventId">
            <cfset ArrayAppend(response['events'], eventMap[eventId])>
        </cfloop>
        
        <!--- respond to client --->
        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully fetched events">
        <cfreturn response>

    </cffunction>


    <!--- ################################## --->
    <!--- #   FETCH ARTICLE SLIDER ITEMS   # --->
    <!--- ################################## --->

    <cffunction name="fetchArticleSliderItems" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['article_slider'] = {}>
        <cfset response['article_slider']['articles'] = []>
        <cfset response['article_slider']['artists'] = []>
        <cfset response['article_slider']['locations'] = []>
        

        <!--- ############### --->
        <!--- #   ARTISTS   # --->
        <!--- ############### --->

        <!--- retrieve artists from db --->
        <cfquery name="artists" datasource="#getConfig('DSN')#">
            SELECT id, name, bilder 
            FROM artist
            WHERE deactivated = 0 AND approved = 1
        </cfquery>

        <cfif artists.recordcount GT 0>
            <cfloop query="artists">
                <!--- artist --->
                <cfset artist = {}>
                <cfset artist['id'] = artists.id>
                <cfset artist['name'] = artists.name>
                <!--- evaluate image --->
                <cfset artist['img'] = {}>
                <cfif artists.bilder NEQ "">
                    <cfset image = getStructuredContent(nodetype=1301, instanceids="#artists['bilder']#", orderclause="createdwhen DESC", maxrows=1)>
                    <cfif image.recordCount EQ 1>
                        <cfset artist['img']['path'] = href("instance:" & image.id) & "&dimensions=300x150&cropmode=cropcenter">
                        <cfset artist['img']['name'] = image.originalfilename>
                    <cfelse>
                        <cfset artist['img']['path'] = NULL>
                        <cfset artist['img']['name'] = "Fallback">
                    </cfif>
                <cfelse>
                    <cfset artist['img']['path'] = NULL>
                    <cfset artist['img']['name'] = "Fallback">
                </cfif>
                <!--- append artist --->
                <cfset ArrayAppend(response['article_slider']['artists'], artist)>
            </cfloop>
        </cfif>


        <!--- ################# --->
        <!--- #   LOCATIONS   # --->
        <!--- ################# --->

        <!--- retrieve locations from db --->
        <cfquery name="locations" datasource="#getConfig('DSN')#">
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

        <cfif locations.recordcount GT 0>
            <cfloop query="locations">
                <!--- artist --->
                <cfset location = {}>
                <cfset location['id'] = locations.id>
                <cfset location['name'] = locations.name>
                <!--- evaluate image --->
                <cfset location['img'] = {}>
                <cfif locations.bilder NEQ "">
                    <cfset image = getStructuredContent(nodetype=1301, instanceids="#locations['bilder']#", orderclause="createdwhen DESC", maxrows=1)>
                    <cfif image.recordCount EQ 1>
                        <cfset location['img']['path'] = href("instance:" & image.id) & "&dimensions=300x150&cropmode=cropcenter">
                        <cfset location['img']['name'] = image.originalfilename>
                    <cfelse>
                        <cfset location['img']['path'] = NULL>
                        <cfset location['img']['name'] = "Fallback">
                    </cfif>
                <cfelse>
                    <cfset location['img']['path'] = NULL>
                    <cfset location['img']['name'] = "Fallback">
                </cfif>
                <!--- append artist --->
                <cfset ArrayAppend(response['article_slider']['locations'], location)>
            </cfloop>
        </cfif>


        <!--- ################ --->
        <!--- #   ARTICLES   # --->
        <!--- ################ --->

        <cfset wordpressURL = getConfig('wordpress.url')>
        <cfset var wpArticles = NULL>

        <cftry>
            <!--- fetch articles from wordpress --->
            <cfhttp url="#wordpressURL#/posts" method="GET" result="wpArticleRes">
                <cfhttpparam type="header" name="Accept" value="application/json">
            </cfhttp>

            <cfset wpArticles = deserializeJSON(wpArticleRes.filecontent)>
        <cfcatch>
            <cfset response['success'] = false>
            <cfset response['message'] = "Could not fetch articles from wordpress">
            <cfset response['error'] = {}>
            <cfset response['error']['message'] = cfcatch.message>
            <cfset response['error']['detail'] = cfcatch.detail>
        </cfcatch>
        </cftry>

        <!--- loop through articles --->
        <cfif NOT IsNull(wpArticles) AND IsArray(wpArticles)>
            <cfloop array="#wpArticles#" item="wpArticle">
                <cfif StructKeyExists(wpArticle, 'id') AND StructKeyExists(wpArticle, 'title') AND StructKeyExists(wpArticle['title'], 'rendered')>
                    <cfset article = {}>
                    <cfset article['id'] = wpArticle.id>
                    <cfset article['name'] = wpArticle.title.rendered>
                    <cfset article['img'] = {}>
                    <!--- evaluate image --->
                    <cfif StructKeyExists(wpArticle, '_links') AND StructKeyExists(wpArticle['_links'], 'wp:featuredmedia') AND isArray(wpArticle['_links']['wp:featuredmedia']) AND ArrayLen(wpArticle['_links']['wp:featuredmedia']) GT 0>
                        <!--- fetch image --->
                        <cftry>
                            <cfset imageURL = "#wpArticle['_links']['wp:featuredmedia'][1]['href']#">
                            <cfhttp url="#imageURL#" method="GET" result="wpArticleImageRes">
                                <cfhttpparam type="header" name="Accept" value="application/json">
                            </cfhttp>
                            <cfset wpArticleImage = deserializeJSON(wpArticleImageRes.filecontent)>
                            <!--- build object --->
                            <cfif StructKeyExists(wpArticleImage, 'link') AND StructKeyExists(wpArticleImage, 'title') AND StructKeyExists(wpArticleImage['title'], 'rendered')>
                                <cfset article['img']['path'] = wpArticleImage.link>
                                <cfset article['img']['name'] = wpArticleImage.title.rendered>
                            <cfelse>
                                <cfset article['img']['path'] = NULL>
                                <cfset article['img']['name'] = "Fallback">
                            </cfif>
                        <cfcatch>
                            <cfset article['img']['path'] = NULL>
                            <cfset article['img']['name'] = "Fallback">
                        </cfcatch>
                        </cftry>
                    <cfelse>
                        <cfset article['img']['path'] = NULL>
                        <cfset article['img']['name'] = "Fallback">
                    </cfif>
                    <cfset ArrayAppend(response['article_slider']['articles'], article)>
                </cfif>
            </cfloop>
        </cfif>
        
        
        <!--- respond to client --->
        <cfheader statuscode="200" statustext="OK">
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully fetched artists">
        <cfreturn response>

    </cffunction>


    <!--- ########################### --->
    <!--- #   FETCH EVENT DETAILS   # --->
    <!--- ########################### --->

    <cffunction name="fetchEventDetails" access="remote" returnFormat="JSON">



    </cffunction>

</cfcomponent>