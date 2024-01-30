<cfcomponent>
<cfinclude template="/ameisen/functions.cfm">
<cfinclude template="/modules/functions.cfm">	
<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="deleteRecord" access="remote" returnFormat="json">
	<cfargument name="records" required="yes" type="string">
	<cfargument name="nodeType" required="yes" type="numeric">

	<cfset var result		= {}>
	<cfset var qItems = QueryNew('id')>
	<cfset var whereclause = "0=1">
	<cfset var cNodetype = 0>
	
	<cfset result["success"] = false>
	<cfset result["message"] = "Der Datensatz konnte nicht gelöscht werden.">

	<cfif isAuth()>
	<cfif arguments.nodeType LT 2100>
		<cfif arguments.nodeType LTE 2><!--- Bilder oder Uploads --->
			<!--- Bereinigung: Bei allen Einträgen, wo die Datei dranhängt, Zuordnung entfernen --->
			<cfset whereclause = ListAppendComplex(whereclause,"FIND_IN_SET(#arguments.records#,bilder)"," OR ")>
			<cfset whereclause = ListAppendComplex(whereclause,"FIND_IN_SET(#arguments.uploads#,bilder)"," OR ")>
			<!--- Veranstalter / Veranstaltungen / Artisten --->
			<cfloop list="2101,2102,2103" index="cNodetype">
				<cfset qItems = getStructuredContent(nodetype=cNodetype,whereclause=whereclause)>
				<cfloop query="qItems">
					<cfset removeMediaArchiveUploadFlat(qItems.id, 'bilder', arguments.records, cNodetype)>
					<cfset removeMediaArchiveUploadFlat(qItems.id, 'uploads', arguments.records, cNodetype)>
				</cfloop>
			</cfloop>
			<cfelse>
				<cfif arguments.nodeType EQ 2102>
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstaltung WHERE id IN ('#arguments.records#') OR parent_fk IN ('#arguments.records#') ORDER BY parent_fk desc
					</cfquery>
					<!---Bilder löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.bilder))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstaltung WHERE FIND_IN_SET("#cRecord#",bilder)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!---Uploads löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.uploads))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstaltung WHERE FIND_IN_SET("#cRecord#",uploads)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.id))#" index="cRecord">
						<cfset deleteFlatContent(nodetype=arguments.nodeType,instanceid=cRecord)>
					</cfloop>
				<cfelseif arguments.nodeType EQ 2101>
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstalter WHERE id IN ('#arguments.records#')
					</cfquery>
					<!---Bilder löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.bilder))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstalter WHERE FIND_IN_SET("#cRecord#",bilder)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!---Uploads löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.uploads))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstalter WHERE FIND_IN_SET("#cRecord#",uploads)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.id))#" index="cRecord">
						<cfset deleteFlatContent(nodetype=arguments.nodeType,instanceid=cRecord)>
					</cfloop>
				<cfelseif arguments.nodeType EQ 2103>
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM artist WHERE id IN ('#arguments.records#')
					</cfquery>
					<!---Bilder löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.bilder))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM artist WHERE FIND_IN_SET("#cRecord#",bilder)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!---Uploads löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.uploads))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM artist WHERE FIND_IN_SET("#cRecord#",uploads)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.id))#" index="cRecord">
						<cfset deleteFlatContent(nodetype=arguments.nodeType,instanceid=cRecord)>
					</cfloop>
				<cfelse>		
					<cfloop list="#arguments.records#" index="cRecord">
						<cfset deleteFlatContent(nodetype=arguments.nodeType,instanceid=cRecord)>
					</cfloop>
				</cfif>		
			</cfif>	
			<cfset result["success"] = true>
			<cfset result["message"] = "Der Datensatz wurde erfolgreich gelöscht.">
			<cfelse>
			<cfset result["success"] = false>
		</cfif>

	<cfreturn result>
    
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfsilent>
</cfcomponent>