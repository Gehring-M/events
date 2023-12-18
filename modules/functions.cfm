<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- funktion handelt die sonderfälle der updateData funktion ab. diese unterscheiden sich je nach nodetype --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="updateSpecialData" access="private" returnFormat="json">
	<cfargument name="nodetype" type="numeric" required="yes">
	<cfargument name="data" type="struct" required="yes">
	<cfargument name="instanceid" type="string" required="yes">
	<cfset var result = StructNew()>
	<cfset result['overWriteMessage'] = "">
	<cfset var uploadStruct = StructNew()>
	<cfset var myUploadID = 0>
	<cfset var qPLZ = QueryNew('id')>	   
	<cfswitch expression="#arguments.nodetype#">
		<cfcase value="2102">
			<cfset myData = StructNew()>
			<cfset latlon = getLatLon(arguments.data.adresse,arguments.data.plz,arguments.data.ort)>
			<cfif latlon['plz'] NEQ "">
				<cfif arguments.data.plz NEQ latlon['plz']>
					<cfset myData['plz'] = latlon['plz']>	
				</cfif>	
				<cfset arguments.data.plz = latlon['plz']>
			</cfif>
			<cfif arguments.data.plz NEQ "">
				<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
					SELECT id FROM ort WHERE plz = "#arguments.data.plz#"
				</cfquery>
				<cfif qPLZ.recordcount EQ 0>
					<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
						SELECT id FROM ort WHERE weitereplz = "#arguments.data.plz#"
					</cfquery>
				</cfif>
			</cfif>
			<cfset myData['latitude'] = 0>
			<cfset myData['longitude'] = 0>
			<cfset myData['ort_fk'] = "">	
			<cfif latlon['lat'] NEQ "" AND latlon['lon'] NEQ "">	
				<cfset myData['latitude'] = latlon['lat']>
				<cfset myData['longitude'] = latlon['lon']>
			</cfif>
			<cfif qPLZ.recordcount NEQ 0>
				<cfset myData['ort_fk'] = qPLZ.id>
			</cfif>	
			<cfset save = saveStructuredContent(nodetype=2102,instance=arguments.instanceid,data=myData)>	
			<cfif NOT StructKeyExists(data,'duplicate') OR data.duplicate eq 0> 
			<cfquery name="qUpdate" datasource="#getConfig('DSN')#">
				DELETE FROM r_veranstaltung_typ WHERE veranstaltung_fk = "#arguments.data.instance#"
			</cfquery>
			</cfif>
			<cfloop list="#arguments.data.typ_fk#" index="cItem">
				<cfset myData = StructNew()>
				<cfset myData['veranstaltung_fk'] = arguments.instanceid>
				<cfset myData['typ_fk'] = cItem>
				<cfset save = saveStructuredContent(nodetype=2115,data=myData)>
			</cfloop>
			<cfif NOT StructKeyExists(data,'duplicate') OR data.duplicate eq 0> 
			<cfquery name="qUpdate" datasource="#getConfig('DSN')#">
				DELETE FROM r_veranstaltung_region WHERE veranstaltung_fk = "#arguments.data.instance#"
			</cfquery>
			</cfif>
					<cfset myData = StructNew()>
				<cfset myData['veranstaltung_fk'] = arguments.instanceid>
				<cfset myData['region_fk'] = arguments.data.region_fk>
				<cfset save = saveStructuredContent(nodetype=2117,data=myData)>
			<cfif StructKeyExists(arguments.data,'duplicate') AND arguments.data['duplicate'] eq 1>
				<!--- Veranstalter verknüpfungen duplizieren --->
				<cfset qDuplicate = getStructuredContent(nodetype=2111,whereclause="veranstaltung_fk = "&arguments.data.instance)>
				<cfloop query="qDuplicate">
					<cfset myData = StructNew()>
					<cfset myData['veranstaltung_fk'] = arguments.instanceid>
					<cfset myData['veranstalter_fk'] = qDuplicate.veranstalter_fk>
					<cfset save = saveStructuredContent(nodetype=2111,data=myData)>
				</cfloop>
				<!--- Veranstalter verknüpfungen duplizieren --->
				<cfset qDuplicate = getStructuredContent(nodetype=2110,whereclause="veranstaltung_fk = "&arguments.data.instance)>
				<cfloop query="qDuplicate">
					<cfset myData = StructNew()>
					<cfset myData['veranstaltung_fk'] = arguments.instanceid>
					<cfset myData['artist_fk'] = qDuplicate.artist_fk>
					<cfset myData['uhrzeitvon'] = qDuplicate.uhrzeitvon>
					<cfset myData['uhrzeitbis'] = qDuplicate.uhrzeitbis>
					<cfset myData['ort_fk'] = qDuplicate.ort_fk>
					<cfset myData['veranstaltungsort'] = qDuplicate.veranstaltungsort>
					<cfset myData['adresse'] = qDuplicate.adresse>
					<cfset myData['plz'] = qDuplicate.plz>
					<cfset myData['ort'] = qDuplicate.ort>
					<cfset myData['latitude'] = qDuplicate.latitude>
					<cfset myData['longitude'] = qDuplicate.longitude>
					<cfset myData['beschreibung'] = qDuplicate.beschreibung>
					<cfset save = saveStructuredContent(nodetype=2110,data=myData)>
				</cfloop>	
				<!--- Tag Verknüpfungen duplizieren --->
				<cfset qDuplicate = getStructuredContent(nodetype=2116,whereclause="veranstaltung_fk = "&arguments.data.instance)>
				<cfloop query="qDuplicate">
					<cfset myData = StructNew()>
					<cfset myData['veranstaltung_fk'] = arguments.instanceid>
					<cfset myData['tag_fk'] = qDuplicate.tag_fk>
					<cfset save = saveStructuredContent(nodetype=2116,data=myData)>
				</cfloop>	
				<!--- Bilder & Dokumente übernehmen --->
				<cfquery name="qUpdate" datasource="#getConfig('DSN')#">
					SELECT id, bilder, uploads FROM veranstaltung WHERE id = "#arguments.data.instance#"
				</cfquery>
				<cfquery  datasource="#getConfig('DSN')#">
					UPDATE veranstaltung SET bilder = '#qUpdate.bilder#', uploads = '#qUpdate.uploads#' WHERE id = "#arguments.instanceid#"
				</cfquery>		
			</cfif>	
		</cfcase>
		<cfcase value="2101">
			<cfset myData = StructNew()>
			<cfset latlon = getLatLon(arguments.data.adresse,arguments.data.plz,arguments.data.ort)>
			<cfif latlon['plz'] NEQ "">
				<cfif arguments.data.plz NEQ latlon['plz']>
					<cfset myData['plz'] = latlon['plz']>	
				</cfif>
				<cfset arguments.data.plz =latlon['plz']>
			</cfif>
			<cfif arguments.data.plz NEQ "">
				<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
					SELECT id FROM ort WHERE plz = "#arguments.data.plz#"
				</cfquery>
				<cfif qPLZ.recordcount EQ 0>
					<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
						SELECT id FROM ort WHERE weitereplz = "#arguments.data.plz#"
					</cfquery>
				</cfif>
			</cfif>
			<cfset myData['latitude'] = 0>
			<cfset myData['longitude'] = 0>
			<cfset myData['ort_fk'] = "">	
			<cfif latlon['lat'] NEQ "" AND latlon['lon'] NEQ "">	
				<cfset myData['latitude'] = latlon['lat']>
				<cfset myData['longitude'] = latlon['lon']>
			</cfif>
			<cfif qPLZ.recordcount NEQ 0>
				<cfset myData['ort_fk'] = qPLZ.id>
			</cfif>	
			<cfset save = saveStructuredContent(nodetype=2101,instance=arguments.instanceid,data=myData)>	
			<cfif StructKeyExists(arguments.data,'vkid') AND arguments.data['vkid'] neq "">
				<cfset myData = StructNew()>
				<cfset myData['veranstaltung_fk'] = arguments.data['vkid']>
				<cfset myData['veranstalter_fk'] = arguments.instanceid>
				<cfset save = saveStructuredContent(nodetype=2111,data=myData)>
			</cfif>
		</cfcase>	
		<cfcase value="2103">
			<cfset myData = StructNew()>
			<cfset latlon = getLatLon(arguments.data.adresse,arguments.data.plz,arguments.data.ort)>
			<cfif latlon['plz'] NEQ "">
				<cfif arguments.data.plz NEQ latlon['plz']>
					<cfset myData['plz'] = latlon['plz']>	
				</cfif>
				<cfset arguments.data.plz =latlon['plz']>
			</cfif>	
			<cfif arguments.data.plz NEQ "">
				<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
					SELECT id FROM ort WHERE plz = "#arguments.data.plz#"
				</cfquery>
				<cfif qPLZ.recordcount EQ 0>
					<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
						SELECT id FROM ort WHERE weitereplz = "#arguments.data.plz#"
					</cfquery>
				</cfif>
			</cfif>
			<cfset myData['latitude'] = 0>
			<cfset myData['longitude'] = 0>
			<cfset myData['ort_fk'] = "">	
			<cfif latlon['lat'] NEQ "" AND latlon['lon'] NEQ "">	
				<cfset myData['latitude'] = latlon['lat']>
				<cfset myData['longitude'] = latlon['lon']>
			</cfif>
			<cfif qPLZ.recordcount NEQ 0>
				<cfset myData['ort_fk'] = qPLZ.id>
			</cfif>	
			<cfset save = saveStructuredContent(nodetype=2103,instance=arguments.instanceid,data=myData)>	
		</cfcase>
		<cfcase value="2110">
			<cfset myData = StructNew()>
			<cfset latlon = getLatLon(arguments.data.adresse,arguments.data.plz,arguments.data.ort)>
			<cfif latlon['plz'] NEQ "">
				<cfif arguments.data.plz NEQ latlon['plz']>
					<cfset myData['plz'] = latlon['plz']>	
				</cfif>
				<cfset arguments.data.plz = latlon['plz']>
			</cfif>
			<cfif arguments.data.plz NEQ "">
				<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
					SELECT id FROM ort WHERE plz = "#arguments.data.plz#"
				</cfquery>
				<cfif qPLZ.recordcount EQ 0>
					<cfquery name="qPLZ" datasource="#getConfig('DSN')#">
						SELECT id FROM ort WHERE weitereplz = "#arguments.data.plz#"
					</cfquery>
				</cfif>
			</cfif>	
			<cfset myData['latitude'] = 0>
			<cfset myData['longitude'] = 0>
			<cfset myData['ort_fk'] = "">	
			<cfif latlon['lat'] NEQ "" AND latlon['lon'] NEQ "">	
				<cfset myData['latitude'] = latlon['lat']>
				<cfset myData['longitude'] = latlon['lon']>
			</cfif>
			<cfif qPLZ.recordcount NEQ 0>
				<cfset myData['ort_fk'] = qPLZ.id>
			</cfif>	
			<cfset save = saveStructuredContent(nodetype=2110,instance=arguments.instanceid,data=myData)>	
		</cfcase>	
		<cfcase value="1,2">
			<cfset dataStruct = StructNew() />
			<cfset dataStruct['bezeichnung'] = arguments.data['titel'] />
			<cfset dataStruct['beschreibung'] = arguments.data['beschreibung'] />
			<cfset saveStruct = saveStructuredContent(instance=arguments.data['instance'],nodetype=1301,data=dataStruct) />	
		</cfcase>
	</cfswitch>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="getLatLon" returntype="struct">
    <cfargument name="strasse" type="string" />
    <cfargument name="plz" type="string" />
    <cfargument name="ort" type="string" />

    
    <cfset var dataStruct = structNew() >
    <cfset var address = "" >
    <cfset var bezirk = "" >
    <cfset var apiKey = getConfig('api.key.googlemaps.geocode') >
    <cfset var geourl = "https://maps.googleapis.com/maps/api/geocode/json?key=#apiKey#&address=" >

    <cfset dataStruct['lat'] = "">
    <cfset dataStruct['lon'] = "">
    <cfset dataStruct['plz'] = "">
    <cfset dataStruct['errorType'] = "">
    <cfset dataStruct['errorMessage'] = "">
        
    <cfif arguments.strasse eq "" OR arguments.ort eq "" OR apiKey eq "">
        <cfreturn dataStruct>
    </cfif>

    <cfif arguments.plz eq "">
        <cfset address = arguments.strasse & "+" & arguments.ort >
    <cfelse>
        <cfset address = arguments.strasse & "+" & arguments.plz & "+" & arguments.ort >
    </cfif>
    <cfset address = replace(address, " ", "+") >
    <cfset geourl = geourl & address >
    <cftry>
        <cfhttp url = "#geourl#" result="res" />
        <cfcatch>
            <cfset dataStruct['errorMessage'] = "Fehler 1 bei HTTPRequest bei der Geocode Anfrage für Adresse: #address#)">
            <cfreturn dataStruct>
        </cfcatch>
    </cftry>
    <cfif res.status_code neq "200">
        <cfset dataStruct['errorMessage'] = "Fehler 2 bei Antwort auf Geocode Anfrage, Status: #res.statuscode#, für Adresse: #address# ">
        <cfreturn dataStruct>
    </cfif>
    <cfif IsJson(#res.filecontent#)>
        <cfset JsonAdresse = deserializeJson(#res.filecontent#) />
        <cfif JsonAdresse.status neq "OK">
            <cfset dataStruct['errorType'] = JsonAdresse.status>
            <cfset dataStruct['errorMessage'] = "Fehler 3 bei Antwort auf Geocode Anfrage, Status: #JsonAdresse.status#, für Adresse: #address# ">
            <cfreturn dataStruct>
        </cfif>
        <cfset dataStruct['lat'] = JsonAdresse.results[1].geometry.location.lat>
        <cfset dataStruct['lon'] = JsonAdresse.results[1].geometry.location.lng>
		<cfloop from="1" to="#ArrayLen(JsonAdresse.results[1].address_components)#" index="cRow">

		<!---TODO Maybe remove or fix--->
			<cfif JsonAdresse.results[1].address_components[cRow]['types'][1] EQ "postal_code">
			<!---	<cfset dataStruct['plz'] = JsonAdresse.results[1].address_components[cRow]['long_name']>--->
			</cfif>
		</cfloop>	
        <cfreturn dataStruct>
    <cfelse>
        <cfset dataStruct['errorMessage'] = "Fehler bei Antwort auf Geocode Anfrage für Adresse: #address#, kein gültiges Json \n content: #res.filecontent#">
        <cfreturn dataStruct>
    </cfif>

</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->						
</cfsilent>