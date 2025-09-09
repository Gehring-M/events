<cfcomponent>

    <!--- imports --->
    <cfinclude template="../ameisen/functions.cfm">
    <cfinclude template="../modules/functions.cfm">


    <!--- ################################# --->
    <!--- #   GET EVENT STRUCT TEMPLATE   # --->
    <!--- ################################# --->

    <!--- Returns the template event struct that shares properties between parent & sub events --->
    <cffunction name="getEventStructTemplate" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="new_event" type="struct" required="true">
        <cfargument name="import_status" type="numeric" required="true">
        <cfargument name="event_schedule" type="struct" required="true">
        <cfargument name="parent_fk" type="numeric" required="false">

        <!--- init --->
        <cfset var constructed_event = {}>

        <!--- decide if the event is a 'main event' or 'sub event' --->
        <cfif StructKeyExists(arguments, 'parent_fk')>
            <cfset constructed_event['parent_fk'] = arguments.parent_fk>
        <cfelse>
            <cfset constructed_event['parent_fk'] = NULL>
        </cfif>

        <!--- show on website if import_status = 1 (sofort importieren) --->
        <cfif import_status EQ 1>
            <cfset constructed_event['visible'] = 1>
        </cfif>

        <!--- check for geodatenpool_id --->
        <cfif StructKeyExists(new_event, '@id')>
            <cfset constructed_event['geodatenpool_id'] = new_event['@id']>   
        </cfif>

        <!--- check for event name --->
        <cfif StructKeyExists(new_event, 'name')>
            <cfset constructed_event['name'] = new_event['name']>
        </cfif>

        <!--- check for event description --->
        <cfif StructKeyExists(new_event, 'description')>
            <cfset constructed_event['beschreibung'] = new_event['description']>
        </cfif>

        <!--- event schedule --->
        <cfif StructKeyExists(event_schedule, 'von')>
            <cfset constructed_event['von'] = event_schedule['von']>
        </cfif>
        <cfif StructKeyExists(event_schedule, 'bis')>
            <cfset constructed_event['bis'] = event_schedule['bis']>
        </cfif>
        <cfif StructKeyExists(event_schedule, 'uhrzeitvon')>
            <cfset constructed_event['uhrzeitvon'] = event_schedule['uhrzeitvon']>
        </cfif>
        <cfif StructKeyExists(event_schedule, 'uhrzeitbis')>
            <cfset constructed_event['uhrzeitbis'] = event_schedule['uhrzeitbis']>
        </cfif>

        <!--- parse location --->
        <cfif StructKeyExists(new_event, 'location')>

            <!--- check for location name --->
            <cfif StructKeyExists(new_event['location'], 'name')>
                <cfset constructed_event['veranstaltungsort'] = new_event['location']['name']>
            </cfif>

            <!--- check for coordinates --->
            <cfif StructKeyExists(new_event['location'], 'geo')>

                <!--- check for latitude --->
                <cfif StructKeyExists(new_event['location']['geo'], 'latitude')>
                    <cfset constructed_event['latitude'] = new_event['location']['geo']['latitude']>
                </cfif>

                <!--- check for longitude --->
                <cfif StructKeyExists(new_event['location']['geo'], 'longitude')>
                    <cfset constructed_event['longitude'] = new_event['location']['geo']['longitude']>
                </cfif>

            </cfif>

            <!--- check address data --->
            <cfif StructKeyExists(new_event['location'], 'address')>

                <!--- check for street address --->
                <cfif StructKeyExists(new_event['location']['address'], 'streetAddress')>
                    <cfset constructed_event['adresse'] = new_event['location']['address']['streetAddress']>
                </cfif>

                <!--- check for postalcode --->
                <cfif StructKeyExists(new_event['location']['address'], 'postalCode')>
                    <cfset constructed_event['plz'] = new_event['location']['address']['postalCode']>
                </cfif>

                <!--- check for address locality --->
                <cfif StructKeyExists(new_event['location']['address'], 'addressLocality')>
                    <cfset constructed_event['ort'] = new_event['location']['address']['addressLocality']>
                </cfif>

            </cfif>

            <!--- check url --->
            <cfif StructKeyExists(new_event['location'], 'url')>
                <cfset constructed_event['link'] = new_event['location']['url']>
            </cfif>

        </cfif>

        <cfset constructed_event['ort_fk'] = NULL>
        <cfset constructed_event['import_status'] = import_status>

        <cfreturn constructed_event>

    </cffunction>


    <!--- ######################### --->
    <!--- #   GET IMPORT STATUS   # --->
    <!--- ######################### --->
    
    <!--- Evaluates the import status based on the event types --->
    <cffunction name="getImportStatus" access="private" returntype="numeric">
        <!--- arguments --->
        <cfargument name="new_event" type="struct" required="false">
        <cfargument name="allowed_types" type="struct" required="true">

        <!--- init --->
        <cfset import_status = 3> <!--- do not import --->

        <!--- check if there are events for the incoming import --->
        <cfif StructKeyExists(new_event, 'odta:kindOfEvent')>
            <!--- check for allowed events --->
            <cfloop array="#new_event['odta:kindOfEvent']#" index="event_type">
                <!--- check if new event is allowed for import --->
                <cfif StructKeyExists(allowed_types, event_type)>
                    <cfset quality = allowed_types[event_type]>
                    <cfif import_status GT quality>
                        <cfset import_status = quality>
                    </cfif>
                </cfif>
            </cfloop>
        </cfif>

        <cfreturn import_status>

    </cffunction>


    <!--- #################### --->
    <!--- #   STORE IMAGES   # --->
    <!--- #################### --->

    <cffunction name="storeImages" access="private" returntype="void">
        <!--- arguments --->
        <cfargument name="images" type="array" required="true">
        <cfargument name="event_id" type="numeric" required="true">
        <cfargument name="category_node" type="numeric" required="true">
        <cfargument name="old_event" type="struct" required="true">

        <!--- init --->
        <cfset var image_ids = []>
        <cfset var uploadResults = []>

        <!--- remove already existing images --->
        <cfif StructKeyExists(old_event, 'bilder') AND old_event.bilder NEQ "">
            <cfset remove_ids = ListToArray(old_event['bilder'], ',')>
            <cfloop array="#remove_ids#" index="remove_id">
                <cfset removeMediaArchiveUploadFlat(event_id, 'bilder', remove_id, 2102)>
                <cfset deleteStructuredContent(remove_id)>
            </cfloop>
        </cfif>

        <cfset var uploadStruct = {}>
        <cfset var imageUrl = "">
        <cfset var baseUrl = "">
        <cfset var imageName = "">

        <!--- upload new images --->
        <cfloop array="#images#" index="image">
            <cfif StructKeyExists(image, 'contentUrl')>
                <!------>
                <cfset uploadStruct = {}>
                <cfset imageUrl = "">
                <cfset baseUrl = "">
                <cfset imageName = "">
                <!------>
                <cfset imageUrl = image['contentUrl']> 
                <cfset baseUrl = left(imageUrl, len(imageUrl) - len(GetFileFromPath(imageUrl)))>
                <cfset imageName = GetFileFromPath(imageUrl)>

                <!--- upload into correct media-archive via URL --->
                <cfset uploadResult = copyIntoMediaArchive(nodetype=1301, categoryNodeId=category_node, method="url", path=baseUrl, file=imageName)>
                <!------>
                <cfset ArrayAppend(uploadResults, uploadResult)>
            </cfif>
        </cfloop>

        <!--- associate images with entity --->
        <cfloop array="#uploadResults#" item="uploadResult">
            <cfset attachMediaArchiveItemFlat(instanceID=event_id, uploadfield="bilder", uploaddataid=uploadResult['instanceid'], nodetype=2102)>
        </cfloop>
    </cffunction>


    <!--- ############################# --->
    <!--- #   STORE EVENT <> REGION   # --->
    <!--- ############################# --->

    <cffunction name="storeEventRegion" access="private" returntype="void">
        <!--- arguments --->
        <cfargument name="event_ids" type="array" required="true">
        <cfargument name="region_fk" type="numeric" required="true">

        <!--- init --->
        <cfset var relation = {}>

        <!--- check if there are IDs to store --->
        <cfif ArrayLen(event_ids) GT 0>
            <cfloop array="#event_ids#" index="event_id">
                <!------>
                <cfset relation = {}>
                <cfset relation['veranstaltung_fk'] = event_id>
                <cfset relation['region_fk'] = region_fk>
                <!------>
                <cfset saveStructuredContent(nodetype=2117, data=relation)>
            </cfloop>
        </cfif>
    </cffunction>


    <!--- #################### --->
    <!--- #   STORE EVENTS   # --->
    <!--- #################### --->

    <cffunction name="storeEvents" access="private" returntype="struct">

        <!--- argument --->
        <cfargument name="new_event" type="struct" required="true">
        <cfargument name="import_status" type="numeric" required="true">
        <cfargument name="instanceId" type="numeric" required="false">
        <cfargument name="region_fk" type="numeric" required="true">
        <cfargument name="old_event" type="struct" required="true">

        <!--- init --->
        <cfset var events_modified = 0>
        <cfset var event_schedules = []>
        <cfset var event_schedule = {}>
        <cfset var eventSchedule = {}>
        <cfset var upload_results = []>
        <cfset var saved_event = {}>
        <cfset var event_ids = []>
        <cfset var has_images = false>
        <cfset var main_event_id = 0>

        <cfset var returnStruct = {}>
        <cfset returnStruct['main_event_ID'] = 0>

        <!--- set event_schedules if available (is used to determine if just main event OR sub events as well) --->
        <cfif StructKeyExists(new_event, 'eventSchedule')>
            <cfset event_schedules = new_event['eventSchedule']>
        </cfif>

        <!--- check if there are some images to download --->
        <cfif StructKeyExists(new_event, 'image')>
            <cfset has_images = true>
        </cfif>


        <!--- ############################################## --->
        <!--- #   CONSTRUCT MAIN EVENT (JUST MAIN EVENT)   # --->
        <!--- ############################################## --->

        <cfif ArrayLen(event_schedules) EQ 1>
    
            <cfset event_schedule = event_schedules[1]>

            <cfif StructKeyExists(event_schedule, 'startDate')>
                <cfset eventSchedule['von'] = parseDateTime(event_schedule['startDate'])>
            </cfif>
            <cfif StructKeyExists(event_schedule, 'endDate')>
                <cfset eventSchedule['bis'] = parseDateTime(event_schedule['endDate'])>
            </cfif>
            <cfif StructKeyExists(event_schedule, 'startTime')>
                <cfset eventSchedule['uhrzeitvon'] = parseDateTime(event_schedule['startTime'])>
            </cfif>
            <cfif StructKeyExists(event_schedule, 'endTime')>
                <cfset eventSchedule['uhrzeitbis'] = parseDateTime(event_schedule['endTime'])>
            </cfif>

            <cfset main_event = getEventStructTemplate(new_event = new_event, import_status = import_status, event_schedule = eventSchedule)>

            <!--- decide if overwrite OR new entry --->
            <cfif StructKeyExists(arguments, 'instanceId')>
                <!--- overwrite --->
                <cfset saved_event = saveStructuredContent(nodetype=2102, instance=instanceId, data=main_event)>
            <cfelse>
                <!--- store new event --->
                <cfset saved_event = saveStructuredContent(nodetype=2102, data=main_event)>
                <cfset ArrayAppend(event_ids, saved_event.nodeid)>
            </cfif>

            <!--- ID for the main event --->
            <cfset main_event_id = saved_event.nodeid>

            <!--- increment counter for feedback --->
            <cfset events_modified += 1>

        <!--- ############################################# --->
        <!--- #   CONSTRUCT MAIN EVENT (HAS SUB EVENTS)   # --->
        <!--- ############################################# --->
        
        <cfelseif ArrayLen(event_schedules) GT 1>

            <!--- extract schedules --->
            <cfset event_count = ArrayLen(event_schedules)>
            <cfset first_event = event_schedules[1]>
            <cfset last_event  = event_schedules[event_count]>

            <!--- evaluate start date --->
            <cfif StructKeyExists(first_event, 'startDate')>
                <cfset eventSchedule['von'] = parseDateTime(first_event['startDate'])>
            </cfif>

            <!--- evaluate end date --->
            <cfif StructKeyExists(last_event, 'endDate')>
                <cfset eventSchedule['bis'] = parseDateTime(last_event['endDate'])>
            <cfelse>
                <cfif StructKeyExists(last_event, 'startDate')>
                    <cfset eventSchedule['bis'] = parseDateTime(last_event['startDate'])>
                </cfif>
            </cfif>

            <!--- get constructed event for parent --->
            <cfset main_event = getEventStructTemplate(new_event = new_event, import_status = import_status, event_schedule = eventSchedule)>

            <!--- decide if overwrite OR new entry --->
            <cfif StructKeyExists(arguments, 'instanceId')>
                <!--- overwrite --->
                <cfset saved_event = saveStructuredContent(nodetype=2102, instance=instanceId, data=main_event)>
            <cfelse>
                <!--- store new event --->
                <cfset saved_event = saveStructuredContent(nodetype=2102, data=main_event)>
                <cfset ArrayAppend(event_ids, saved_event.nodeid)>
            </cfif>

            <!--- ID for the main event --->
            <cfset main_event_id = saved_event.nodeid>

            <!--- increment counter for feedback --->
            <cfset events_modified += 1>


            <!--- ################################ --->
            <!--- #   STORE SUB EVENTS AS WELL   # --->
            <!--- ################################ --->

            <!--- subevents reference main event via parent_fk --->
            <cfset parent_fk = main_event_id>


            <!--- maybe make more performant (externalize) --->
            <cfquery name="qEvent" datasource="#getConfig('DSN_RO')#">
                SELECT geodatenpool_id FROM veranstaltung WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#main_event_id#">;
            </cfquery>
            <!--- get sub event IDs --->
            <cfquery name="qSubEvents" datasource="#getConfig('DSN_RO')#">
                SELECT id, von, bis, uhrzeitvon, uhrzeitbis FROM veranstaltung WHERE geodatenpool_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#qEvent.geodatenpool_id#">;
            </cfquery>

            <!--- memorize overwritten IDs --->
            <cfset var overwrite_struct = {}>
            <cfset overwrite_struct['overwrite'] = false>
            <cfset overwrite_struct['overwrite_id'] = -1>

            <!--- just new sub events --->
            <cfif qSubEvents.recordCount EQ 0>

                <cfloop array="#event_schedules#" index="event_schedule_item">
                    <!--- reset --->
                    <cfset eventSchedule = {}>
                    <!--- construct sub events --->
                    <cfif StructKeyExists(event_schedule_item, 'startDate')>
                        <cfset eventSchedule['von'] = parseDateTime(event_schedule_item['startDate'])>
                    </cfif>
                    <cfif StructKeyExists(event_schedule_item, 'endDate')>
                        <cfset eventSchedule['bis'] = parseDateTime(event_schedule_item['endDate'])>
                    </cfif>
                    <cfif StructKeyExists(event_schedule_item, 'startTime')>
                        <cfset eventSchedule['uhrzeitvon'] = parseDateTime(event_schedule_item['startTime'])>
                    </cfif>
                    <cfif StructKeyExists(event_schedule_item, 'endTime')>
                        <cfset eventSchedule['uhrzeitbis'] = parseDateTime(event_schedule_item['endTime'])>
                    </cfif>
                    <!--- get shared properties --->
                    <cfset sub_event = getEventStructTemplate(new_event = new_event, import_status = import_status, event_schedule = eventSchedule, parent_fk = parent_fk)>
                    <!--- save new sub event --->
                    <cfset savedEvent = saveStructuredContent(nodetype=2102, data=sub_event)>
                    <cfset ArrayAppend(event_ids, savedEvent.nodeid)>
                    <!--- increment counter for feedback --->
                    <cfset events_modified += 1>
                </cfloop>

            <!--- overall .. overwrite but might be the case that new schedules arrived as well --->
            <cfelseif qSubEvents.recordCount GT 0>
                
                <cfloop array="#event_schedules#" index="event_schedule_item">
                    <!--- reset --->
                    <cfset overwrite_struct['overwrite'] = false>
                    <cfset overwrite_struct['overwrite_id'] = -1>
                    <cfset eventSchedule = {}>
                    <!--- construct sub events --->
                    <cfif StructKeyExists(event_schedule_item, 'startDate')>
                        <cfset eventSchedule['von'] = parseDateTime(event_schedule_item['startDate'])>
                    </cfif>
                    <cfif StructKeyExists(event_schedule_item, 'endDate')>
                        <cfset eventSchedule['bis'] = parseDateTime(event_schedule_item['endDate'])>
                    </cfif>
                    <cfif StructKeyExists(event_schedule_item, 'startTime')>
                        <cfset eventSchedule['uhrzeitvon'] = parseDateTime(event_schedule_item['startTime'])>
                    </cfif>
                    <cfif StructKeyExists(event_schedule_item, 'endTime')>
                        <cfset eventSchedule['uhrzeitbis'] = parseDateTime(event_schedule_item['endTime'])>
                    </cfif>

                    <!--- check for duplicates --->
                    <cfloop query="qSubEvents">
                        <cfif 
                            StructKeyExists(eventSchedule, "von") AND eventSchedule.von NEQ "" AND
                            StructKeyExists(eventSchedule, "bis") AND eventSchedule.bis NEQ "" AND
                            StructKeyExists(eventSchedule, "uhrzeitvon") AND eventSchedule.uhrzeitvon NEQ "" AND
                            StructKeyExists(eventSchedule, "uhrzeitbis") AND eventSchedule.uhrzeitbis NEQ "" AND
                            qSubEvents.von NEQ "" AND qSubEvents.bis NEQ "" AND qSubEvents.uhrzeitvon NEQ "" AND qSubEvents.uhrzeitbis NEQ "" AND
                            dateFormat(qSubEvents.von, "yyyy-mm-dd") EQ dateFormat(eventSchedule.von, "yyyy-mm-dd") AND
                            dateFormat(qSubEvents.bis, "yyyy-mm-dd") EQ dateFormat(eventSchedule.bis, "yyyy-mm-dd") AND
                            timeFormat(qSubEvents.uhrzeitvon, "HH:mm") EQ timeFormat(eventSchedule.uhrzeitvon, "HH:mm") AND
                            timeFormat(qSubEvents.uhrzeitbis, "HH:mm") EQ timeFormat(eventSchedule.uhrzeitbis, "HH:mm")
                        >
                            <cfset overwrite_struct['overwrite'] = true>
                            <cfset overwrite_struct['overwrite_id'] = qSubEvents.id>
                            <cfbreak>
                        </cfif>
                    </cfloop>

                    <cfif overwrite_struct.overwrite>
                        <cfset sub_event = getEventStructTemplate(new_event = new_event, import_status = import_status, event_schedule = eventSchedule, parent_fk = parent_fk)>
                        <!--- overwrite sub event --->
                        <cfset savedEvent = saveStructuredContent(nodetype=2102, instanceId=overwrite_struct['overwrite_id'], data=sub_event)>
                        <!--- increment counter for feedback --->
                        <cfset events_modified += 1>
                    <cfelse>
                        <cfset sub_event = getEventStructTemplate(new_event = new_event, import_status = import_status, event_schedule = eventSchedule, parent_fk = parent_fk)>
                        <!--- save new sub event --->
                        <cfset savedEvent = saveStructuredContent(nodetype=2102, data=sub_event)>
                        <cfset ArrayAppend(event_ids, savedEvent.nodeid)>
                        <!--- increment counter for feedback --->
                        <cfset events_modified += 1>
                    </cfif>
                </cfloop>
            </cfif>
        </cfif>

        <!--- stores relations event <> region --->
        <cfset storeEventRegion(event_ids=event_ids, region_fk=region_fk)>

        <cfset returnStruct['main_event_ID'] = main_event_id>

        <!--- handle images --->
        <cfif has_images>
            <cfset maPath = getConfig('vpath.geodatenimport')>
            <!--- just insert into archive if category does exist --->
            <cfif maPath NEQ "" AND pathExists(maPath)>
                <cfset maNode = getNodeId(resolvePath(maPath))>
                <cfset storeImages(images=new_event['image'], event_id=main_event_id, category_node=maNode, old_event=old_event)>
            </cfif>
        </cfif>

        <cfset returnStruct['events_modified'] = events_modified>

        <cfreturn returnStruct>

    </cffunction>


    <!--- ########################## --->
    <!--- #   FETCH TVBs FROM DB   # --->
    <!--- ########################## --->

    <!--- includes all the TVBs that needs synching --->
    <cffunction name="fetchTVBsFromDB" access="private" returntype="array">
        
        <!--- init --->
        <cfset var tvbs = []>
        <cfset var tvb  = {}>

        <!--- query all TVBs that needs synching --->
        <cfquery name="qTVB" datasource="#getConfig('DSN_RO')#">
            SELECT * FROM tvb WHERE sync = TRUE;
        </cfquery>

        <!--- construct return data --->
        <cfloop query="qTVB">
            <cfset tvb = {}>
            <!--- add properties --->
            <cfset tvb['id'] = qTVB.id>
            <cfset tvb['api_key'] = qTVB.geodatenpool_key>
            <cfset tvb['region_fk'] = qTVB.region_fk>
            <!--- append --->
            <cfset ArrayAppend(tvbs, tvb)>
        </cfloop>

        <cfreturn tvbs>

    </cffunction>


    <!--- ################################ --->
    <!--- #   FETCH CATEGORIES FROM DB   # --->
    <!--- ################################ --->

    <!--- Returns a map where [key = allowed_event_name] and [value = quality_level] --->
    <cffunction name="fetchCategoriesFromDB" access="private" returntype="struct">

        <!--- init --->
        <cfset var category_map = {}>

        <!--- get allowed categories and join with quality --->
        <cfquery name="qCategories" datasource="#getConfig('DSN_RO')#">
            SELECT * 
            FROM tvb_kategorie AS tvb_k 
            JOIN tvb_kategorie_qualitaet AS tvb_kq
            ON tvb_k.qualitaet_fk = tvb_kq.id;
        </cfquery>

        <!--- construct map --->
        <cfloop query="qCategories">
            <cfset category_map[qCategories.name] = qCategories.qualitaetsstufe>
        </cfloop>

        <cfreturn category_map>

    </cffunction>


    <!--- ############################# --->
    <!--- #   FETCH GEODATA FOR TVB   # --->
    <!--- ############################# --->

    <cffunction name="fetchTVBGeoData" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="tvb_id" type="numeric" required="true">
        <cfargument name="api_key" type="string" required="true">
        <cfargument name="api_url" type="string" required="true">

        <!--- init --->
        <cfset var returnStruct = {}>
        <cfset returnStruct['events'] = {}>
        <cfset returnStruct['success'] = false>
        <cfset returnStruct['errors'] = []>

        <!--- send HTTP request --->
        <cfif api_key NEQ NULL AND api_key NEQ "">

            <cfhttp url="#api_url#" method="get" result="datapoolResponse">
                <cfhttpparam type="url" name="LoadResourcesByCategory" value="action">
                <cfhttpparam type="url" name="apiKey" value="#api_key#">
                <cfhttpparam type="url" name="exportAsOdta" value="true">
            </cfhttp>

            <!--- check response code --->
            <cfif datapoolResponse.status_code EQ 200>
                 <!--- parse response data --->
                <cfset data = deserializeJSON(datapoolResponse['filecontent'])>
                <cfset returnStruct['events'] = data['@graph']>
                <cfset returnStruct['success'] = true>
            <cfelse>
                <cfset ArrayAppend(returnStruct['errors'], 'Could not complete HTTP Request for TVB with ID [#tvb_id#]')>
            </cfif>
        <!--- not a valid API key --->
        <cfelse>
            <cfset ArrayAppend(returnStruct['errors'], 'Invalid API Key for TVB with ID [#tvb_id#]')>
        </cfif>

        <cfreturn returnStruct>

    </cffunction>


    <!--- ############################################### --->
    <!--- #   FETCH EVENT INFORMATION FOR SOME REGION   # --->
    <!--- ############################################### --->

    <cffunction name="fetchEventInformationFromDB" access="private" returntype="array">
        <!--- arguments --->
        <cfargument name="region_fk" type="numeric" required="true">

        <!--- init --->
        <cfset var event_informations = []>
        <cfset var event_struct = {}>

        <!--- get old events from DB --->
        <cfquery name="oldEvents" datasource="#getConfig('DSN_RO')#">
            SELECT *
            FROM veranstaltung AS v
            JOIN r_veranstaltung_region AS rvr
            ON v.id = rvr.veranstaltung_fk 
            WHERE rvr.region_fk = <cfqueryparam cfsqltype="cf_sql_integer" value="#region_fk#">
            AND v.parent_fk IS NULL;
        </cfquery>

        <!--- construct array --->
        <cfloop query="oldEvents">
            <cfif StructKeyExists(oldEvents, 'geodatenpool_id') AND oldEvents.geodatenpool_id NEQ "">
                <!--- reset --->
                <cfset event_struct = {}>
                <!--- build struct --->
                <cfset event_struct['geodatenpool_id'] = oldEvents.geodatenpool_id>
                <cfset event_struct['db_id'] = oldEvents.id>
                <cfset event_struct['changed_by_kbsz'] = oldEvents.changed_by_kbsz>
                <cfif StructKeyExists(oldEvents, 'bilder')>
                    <cfset event_struct['bilder'] = oldEvents.bilder>
                <cfelse>
                    <cfset event_struct['bilder'] = "">
                </cfif>
                <!--- append to array --->
                <cfset ArrayAppend(event_informations, event_struct)>
            </cfif>
        </cfloop>

        <cfreturn event_informations>

    </cffunction>


    <!--- ######################## --->
    <!--- #   IS ALREADY IN DB   # --->
    <!--- ######################## --->

    <cffunction name="isAlreadyInDB" access="private" returntype="struct">
        <!--- arguments --->
        <cfargument name="new_event_id" type="numeric" required="true">
        <cfargument name="event_informations" type="array" required="true">

        <!--- init --->
        <cfset returnStruct = {}>
        <cfset returnStruct['unknown'] = true>
        <cfset returnStruct['db_id'] = NULL>

        <!--- check for duplicates --->
        <cfloop array="#event_informations#" index="event_struct">
            <cfif new_event_id EQ event_struct['geodatenpool_id']>
                <cfset returnStruct['unknown'] = false>
                <cfset returnStruct['db_id'] = event_struct['db_id']>
                <cfset returnStruct['changed_by_kbsz'] = event_struct['changed_by_kbsz']>
                <cfset returnStruct['bilder'] = event_struct['bilder']>
            </cfif>
        </cfloop>

        <cfreturn returnStruct>

    </cffunction>


    <!--- ###################### --->
    <!--- #   GEODATA IMPORT   # --->
    <!--- ###################### --->

    <!--- Diese Funktion holt alle Geodaten --->
    <cffunction name="importGeodata" access="remote" returnFormat="json">

        <!--- inits --->
        <cfset var newEvents = []>
        <cfset var oldEvents = QueryNew('id')>
        <cfset var response = {}>
        <cfset var api_url = getConfig('geodatapool.url')>
        <cfset var tvb_response = {}>
        <cfset var geodatapool_ids = []>
        <cfset var import_status = 3>
        <cfset var constructed_events = []>

        <!--- information about the script --->
        <cfset response['debug'] = {}>
        <cfset response['debug']['new_visible_on_website'] = 0>
        <cfset response['debug']['new_need_approval'] = 0>
        <cfset response['debug']['overwrite_visible_on_website'] = 0>
        <cfset response['debug']['overwrite_need_approval'] = 0>
        <cfset response['debug']['no_import'] = 0>
        <cfset response['debug']['no_overwrite'] = 0>
        <cfset response['debug']['http_error'] = 0>


        <!--- get data from DB --->
        <cfset var tvbs = fetchTVBsFromDB()>
        <cfset var tvb_categories = fetchCategoriesFromDB()>      


        <!--- check if there are tvbs that needs synching --->
        <cfif ArrayLen(tvbs) GT 0>

            <!--- fetch events for every tvb --->
            <cfloop array="#tvbs#" index="tvb">

                <!--- fetch new data from datapool --->
                <cfset tvb_response = fetchTVBGeoData(tvb_id = tvb.id, api_key = tvb.api_key, api_url = api_url)>

                <!--- check result --->
                <cfif tvb_response.success>
                    <!--- fetch information on every event (for that region) --->
                    <cfset event_informations = fetchEventInformationFromDB(region_fk = tvb.region_fk)>
                    <cfset event_import = []>

                    <!--- loop through new events and decide if to import or not --->
                    <cfloop array="#tvb_response.events#" index="newEvent">

                        <!--- evaluate import status for this event --->
                        <cfset import_status = getImportStatus(new_event = newEvent, allowed_types = tvb_categories)>

                        <!--- check if new data should be imported or not --->
                        <cfif import_status EQ 1 OR import_status EQ 2> 

                            <!--- check if the incoming event is in the DB already --->
                            <cfset result = isAlreadyInDB(new_event_id = newEvent['@id'], event_informations = event_informations)>

                            <cfif result.unknown>
                                <cfset retStruct = storeEvents(new_event = newEvent, import_status = import_status, region_fk = tvb.region_fk, old_event=result)>
                                <cfset events_modified = retStruct['events_modified']>
                                <cfset ArrayAppend(event_import, retStruct)>
                                <cfif import_status EQ 1>
                                    <cfset response['debug']['new_visible_on_website'] += events_modified>
                                <cfelse>
                                    <cfset response['debug']['new_need_approval'] += events_modified>
                                </cfif>
                            <cfelse>
                                <!--- just overwrite if data wasn't changed by KBSZ (Kulturbezirk Schwaz) --->
                                <cfif result.changed_by_kbsz EQ 0>
                                    <cfset retStruct = storeEvents(new_event = newEvent, import_status = import_status, instanceId = result.db_id, region_fk = tvb.region_fk, old_event=result)>
                                    <cfset events_modified = retStruct['events_modified']>
                                    <cfset ArrayAppend(event_import, retStruct)>
                                    <cfif import_status EQ 1>
                                        <cfset response['debug']['overwrite_visible_on_website'] += events_modified>
                                    <cfelse>
                                        <cfset response['debug']['overwrite_need_approval'] += events_modified>
                                    </cfif>
                                <cfelse>
                                    <cfset response['debug']['no_overwrite'] += 1>
                                </cfif>
                            </cfif>
                        <cfelse> 
                            <!--- do NOT import --->
                            <cfset response['debug']['no_import'] += 1>
                        </cfif>
                    </cfloop>

                <!--- HTTP request failed --->
                <cfelse>
                    <cfset response['debug']['http_errors'] += 1>
                </cfif>
            </cfloop>
        </cfif>

        <!--- return response --->
        <cfreturn response>

    </cffunction>
</cfcomponent>
