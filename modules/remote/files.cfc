<cfcomponent>
	<cfinclude template="../functions.cfm" />
	<cfinclude template="../../ameisen/functions.cfm" />
	
	<cffunction output="no" name="upload" access="remote" returntype="struct" returnformat="JSON" >
		<cfset var returnStruct = StructNew() />
		<cfset var tmpArray = ArrayNew(1) />
		<cfset var nodetype = "1301" />
		<cfset var categoryNodeId = "0" />
		<cfset var jMaItemNode = getNodetypeConfig(1301) />
		<cfset var lMaItemFieldnames = ArrayToList(jMaItemNode.getEditFieldNames()) />
		
		<cfset returnStruct['success'] = false />
		<cfset returnStruct['error'] = "" />
		<cfset returnStruct['message'] = "Die Datei konnte nicht hochgeladen werden." />
		<cfset returnStruct['value'] = "" />
		
		<cftry>
			<cfset uploadKatInstance = resolveVPath("ma-droploader") />
			<cfset categoryNodeId = getNodeToInstance(uploadKatInstance).getId() />
			<cfcatch>
				<cfset returnStruct['error'] = cfcatch />
			</cfcatch>
		</cftry>
		
		<cfif categoryNodeId gt "0">
			<cfset cKey = form['cFileFieldname'] />
				
				<cfif !isAuth()>
					<cfset returnStruct['message'] = "Ihre Session ist abgelaufen. Bitte melden Sie sich erneut an." />
					<cfreturn returnStruct>
				</cfif>
				<!---Datei im MA speichern--->
				<cfset sFile = uploadIntoMediaArchive(cKey,nodetype,categoryNodeId,"") />
					
				<cfset dataStruct = StructNew() />
				<cfset dataStruct['beschreibung'] = "" />
				<cfset saveStruct = saveStructuredContent(instance=sFile.instanceid,nodetype=nodetype,data=dataStruct) />
				
				<cfset cFile = getMediaArchiveItem(sFile.instanceid) />
				
				<cfset myID = session['vaid']>
				<cfif form['uploadBereich'] EQ "artist">
					<cfset myID = session['aid']>
				</cfif>	
					
				<cfquery name="qMedia" datasource="#getConfig('DSN')#">
					SELECT #form['uploadTyp']# FROM #form['uploadBereich']# WHERE id = "#myID#" 
				</cfquery>
				<cfset idstring = qMedia[form['uploadTyp']]>	
				<cfset idstring = ListRemoveDuplicates(ListAppend(idstring,sFile.instanceid))>	
				<cfquery datasource="#getConfig('DSN')#">
					UPDATE #form['uploadBereich']# SET #form['uploadTyp']# = '#idstring#' WHERE id = "#myID#" 
				</cfquery>	
					
				<cfif cFile.recordcount>
					<cfset returnStruct['message'] = "Die Datei wurde erfolgreich hochgeladen." />
					<cfset returnStruct['success'] = true />
					<cfset sFile = rowAsStruct(cFile,1,cFile.columnList,'yes') />
					<cfset returnStruct['value'] = sFile.id />
				</cfif>
			<!--- ermittlung des korrekten, aktuellen Values für multiples Feld --->
			
			<cfset returnStruct['name'] = form['cFormFieldname'] />
		</cfif>
		
		<cfreturn returnStruct>
	</cffunction>
	
	
</cfcomponent>