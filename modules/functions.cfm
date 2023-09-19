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
		   
	<cfswitch expression="#arguments.nodetype#">
		<cfcase value="2102">
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
			</cfif>	
			<cfdump var="#arguments.data#">
		</cfcase>	
	</cfswitch>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
					
</cfsilent>