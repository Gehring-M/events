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

    <cffunction name="fetchEventDetail" access="remote" returnFormat="JSON">

        <!--- argument --->
        <cfargument name="id" type="numeric" required="no">

        <!--- init --->
        <cfset var response = {}>

        <!--- check for correct call --->
        <cfif StructKeyExists(arguments, 'id')>

            <cfquery name="eventDetails" datasource="#getConfig('DSN')#">
                SELECT 
                    id,
                    name,
                    beschreibung,
                    von,
                    bis,
                    uhrzeitvon,
                    uhrzeitbis,
                    adresse,
                    ort,
                    plz,
                    kinder,
                    tipp,
                    preis,
                    link,
                    bilder
                FROM veranstaltung
                WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['id']#">
            </cfquery>

            <cfquery name="subEvents" datasource="#getConfig('DSN')#">
                SELECT 
                    id,
                    name,
                    von,
                    bis,
                    uhrzeitvon,
                    uhrzeitbis,
                    ort
                FROM veranstaltung
                WHERE parent_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['id']#">
            </cfquery>

            <cfloop query="eventDetails">
                <cfset event = {}>
                <cfset event['id'] = eventDetails.id>
                <cfset event['name'] = eventDetails.name>
                <cfset event['description'] = eventDetails.beschreibung>
                <cfset event['from'] = eventDetails.von>
                <cfset event['till'] = eventDetails.bis>
                <cfset event['time_from'] = eventDetails.uhrzeitvon>
                <cfset event['time_till'] = eventDetails.uhrzeitbis>
                <cfset event['address'] = eventDetails.adresse>
                <cfset event['location'] = eventDetails.ort>
                <cfset event['postal_code'] = eventDetails.plz>
                <cfset event['children'] = eventDetails.kinder>
                <cfset event['tip'] = eventDetails.tipp>
                <cfset event['price'] = eventDetails.preis>
                <cfset event['link'] = eventDetails.link>
                <!--- evaluate images --->
                <cfset event['images'] = []>
                <cfif eventDetails['bilder'] NEQ "">
                    <cfset images = getStructuredContent(nodetype=1301, instanceids="#eventDetails['bilder']#")>
                    <cfloop query="images">
                        <!--- construct individual images --->
                        <cfset image = {}>
                        <cfset image['id'] = images.id>
                        <cfset image['path'] = href("instance:"&images.id)&"&dimensions=600x300&cropmode=cropcenter">
                        <cfset image['filename'] = images.originalfilename>
                        <cfset ArrayAppend(event['images'], image)>
                    </cfloop>
                </cfif>
                <!--- --->
                <cfset event['sub_events'] = []>
                <cfset response['event'] = event>
            </cfloop>

            <cfloop query="subEvents">
                <cfset subEvent = {}>
                <cfset subEvent['id'] = subEvents.id>
                <cfset subEvent['name'] = subEvents.name>
                <cfset subEvent['from'] = subEvents.von>
                <cfset subEvent['till'] = subEvents.bis>
                <cfset subEvent['time_from'] = subEvents.uhrzeitvon>
                <cfset subEvent['time_till'] = subEvents.uhrzeitbis>
                <cfset subEvent['location'] = subEvents.ort>
                <cfset ArrayAppend(response['event']['sub_events'], subEvent)>
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
                    id,
                    name,
                    beschreibung,
                    ansprechperson,
                    ort,
                    adresse,
                    plz,
                    telefon,
                    email,
                    web,
                    link,
                    bilder
                FROM artist
                WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['id']#"> AND approved = 1;
            </cfquery>

            <cfloop query="artistDetails">
                <cfset artist = {}>
                <cfset artist['id'] = artistDetails.id>
                <cfset artist['name'] = artistDetails.name>
                <cfset artist['description'] = artistDetails.beschreibung>
                <cfset artist['location'] = artistDetails.ort>
                <cfset artist['address'] = artistDetails.adresse>
                <cfset artist['postal_code'] = artistDetails.plz>
                <cfset artist['phone'] = artistDetails.telefon>
                <cfset artist['email'] = artistDetails.email>
                <cfset artist['web'] = artistDetails.web>
                <cfset artist['link'] = artistDetails.link>
                <cfset artist['images'] = artistDetails.bilder>
                <!--- evaluate images --->
                <cfset artist['images'] = []>
                <cfif artistDetails['bilder'] NEQ "">
                    <cfset images = getStructuredContent(nodetype=1301, instanceids="#artistDetails['bilder']#")>
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


    <!--- ############################# --->
    <!--- #   FETCH LOCATION DETAIL   # --->
    <!--- ############################# --->

    <cffunction name="fetchLocationDetail" access="remote" returnFormat="JSON">
        <!--- argument --->
        <cfargument name="id" type="numeric" required="no">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['location'] = {}>

        <!--- check for correct call --->
        <cfif StructKeyExists(arguments, 'id')>

            <cfquery name="locationDetails" datasource="#getConfig('DSN')#">
                SELECT 
                    rh.id AS rh_id,
                    rh.name AS rh_name,
                    rh.adresse AS rh_address,
                    rh.beschreibung AS rh_description,
                    rh.bilder AS rh_images,
                    o.name AS location_name,
                    o.plz AS location_postal_code,
                    b.name AS district_name,
                    bu.name AS region_name
                FROM regional_highlights AS rh
                JOIN ort AS o
                ON rh.ort_fk = o.id
                JOIN bezirk AS b
                ON o.bezirk_fk = b.id
                JOIN bundesland AS bu
                ON b.bundesland_fk = bu.id
                WHERE rh.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments['id']#"> AND rh.aktiv = 1;
            </cfquery>

            <cfloop query="locationDetails">
                <cfset location = {}>
                <cfset location['id'] = locationDetails.rh_id>
                <cfset location['name'] = locationDetails.rh_name>
                <cfset location['description'] = locationDetails.rh_description>
                <cfset location['address'] = locationDetails.rh_address>
                <cfset location['location_name'] = locationDetails.location_name>
                <cfset location['location_postal_code'] = locationDetails.location_postal_code>
                <cfset location['district_name'] = locationDetails.district_name>
                <cfset location['region_name'] = locationDetails.region_name>
                <!--- evaluate images --->
                <cfset location['images'] = []>
                <cfif locationDetails.rh_images NEQ "">
                    <cfset image = getStructuredContent(nodetype=1301, instanceids="#locations['bilder']#")>
                    <cfloop query="images">
                        <!--- construct individual images --->
                        <cfset image = {}>
                        <cfset image['id'] = images.id>
                        <cfset image['path'] = href("instance:"&images.id)&"&dimensions=300x150&cropmode=cropcenter">
                        <cfset image['filename'] = images.originalfilename>
                        <cfset ArrayAppend(location['images'], image)>
                    </cfloop>
                </cfif>
                <cfset response['location'] = location>
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


    <!--- ############################ --->
    <!--- #   FETCH ARTICLE DETAIL   # --->
    <!--- ############################ --->

    <cffunction name="fetchArticleDetail" access="remote" returnFormat="JSON">
        <!--- argument --->
        <cfargument name="id" type="numeric" required="no">

        <!--- init --->
        <cfset var wordpressURL = getConfig('wordpress.url')>
        <cfset var response = {}>
        <cfset var wpArticle = NULL>
        <cfset response['article'] = {}>

        <!--- check for correct call --->
        <cfif StructKeyExists(arguments, 'id')>

            <cftry>
                <!--- fetch article from wordpress --->
                <cfhttp url="#wordpressURL#/posts/#arguments['id']#" method="GET" result="wpArticleRes">
                    <cfhttpparam type="header" name="Accept" value="application/json">
                </cfhttp>

                <cfset wpArticle = deserializeJSON(wpArticleRes.filecontent)>
            <cfcatch>
                <cfset response['success'] = false>
                <cfset response['message'] = "Could not fetch article from wordpress">
                <cfset response['error'] = {}>
                <cfset response['error']['message'] = cfcatch.message>
                <cfset response['error']['detail'] = cfcatch.detail>
            </cfcatch>
            </cftry>

            <cfif NOT IsNull(wpArticle)>
                <!--- init --->
                <cfset article = {}>
                <!--- construct article --->
                <cfif StructKeyExists(wpArticle, 'id')>
                    <cfset article['id'] = wpArticle.id>
                </cfif>
                <cfif StructKeyExists(wpArticle, 'title') AND StructKeyExists(wpArticle['title'], 'rendered')>
                    <cfset article['name'] = wpArticle.title.rendered>
                </cfif>
                <cfif StructKeyExists(wpArticle, 'content') AND StructKeyExists(wpArticle['content'], 'rendered')>
                    <cfset article['content'] = wpArticle.content.rendered>
                </cfif>
                <cfif StructKeyExists(wpArticle, 'excerpt') AND StructKeyExists(wpArticle['excerpt'], 'rendered')>
                    <cfset article['excerpt'] = wpArticle.excerpt.rendered>
                </cfif>
                <!--- --->
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
                <!--- send article back to client --->
                <cfset response['article'] = article>
            </cfif>

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


    <!--- ############################# --->
    <!--- #   CREATE EVENT EXTERNAL   # --->
    <!--- ############################# --->

    <cffunction name="createEventExternal" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var formStruct = formToStruct()>
        <cfset var response = {}>

        <!--- ensure correct media archive --->
        <cfset maEventsPath = getConfig('ma.events')>
        <cfif maEventsPath EQ "" OR NOT pathExists(maEventsPath)>
            <cfheader statuscode="500" statustext="Internal Server Error">
            <cfset response['success'] = false>
            <cfset response['message'] = "Make sure to create the media archive " & maEventsPath & "first">
            <cfreturn response>
        </cfif>

        <!--- media archive --->
        <cfset maEvents = getNodeId(resolvePath(maEventsPath))>

        <!--- initialize new artist object --->
        <cfset newEvent = {}>

        <cfif StructKeyExists(formStruct, 'eventName')>
            <cfset newEvent['name'] = formStruct.eventName>
        <cfelse>
            <!--- shouldn't execute because it's validated in the frontend but just in case --->
            <cfset newEvent['name'] = "fallback-name">
        </cfif>

        <!--- insert artist --->
        <cfquery name="createEvent" datasource="#getConfig('DSN')#" result="dbResult">
            INSERT INTO veranstaltung (parent_fk, name, von, bis, uhrzeitvon, uhrzeitbis, veranstaltungsort, adresse, plz, ort, beschreibung, preis, link, extern, visible, changed_by_kbsz) 
            VALUES (
                NULL,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventname']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventvon']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventbis']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventuhrzeitvon']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventuhrzeitbis']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventort']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventadresse']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventplz']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventort']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventbeschreibung']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventpreis']#">,
                <cfqueryparam cfsqltype="cf_sql_varchar" value="#formStruct['eventlink']#">,
                2,
                0,
                0
            )
        </cfquery>

        <!--- extract event ID --->
        <cfset eventID = dbResult.generatedKey>

        <!--- count incoming images --->
        <cfset imageCount = 0>
        <cfloop collection="#formStruct#" item="key">
            <cfif REFind("^image_\d+$", key)>
                <cfset imageCount = imageCount + 1>
            </cfif>
        </cfloop>

        <cfloop from="0" to="#imageCount - 1#" index="i">
            <!--- upload image --->
            <cfset uploadResult = uploadIntoMediaArchive("image_#i#", 1301, maEvents, "automatisch")>

            <!--- associate with regional highlight --->
            <cfinvoke component="/ameisen/components/mediaarchive" method="addUploadForInstance">
                <cfinvokeargument name="instance" value="#eventID#">
                <cfinvokeargument name="uploadfield" value="bilder">
                <cfinvokeargument name="addid" value="#uploadResult.instanceid#">
                <cfinvokeargument name="nodetype" value="2102">
            </cfinvoke>

        </cfloop>

        <cfcontent type="application/json">

        <cfheader statuscode="200" statustext="OK">
        <cfset response['formstruct'] = formStruct>
        <cfset response['success'] = true>
        <cfset response['message'] = "Successfully created new artist.">
        <cfreturn response>

    </cffunction>


</cfcomponent>