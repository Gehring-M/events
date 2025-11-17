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
				<cfset imageID = sFile.instanceid>
					
				<cfset dataStruct = StructNew() />
				<cfset dataStruct['beschreibung'] = "" />
				<cfset saveStruct = saveStructuredContent(instance=imageID,nodetype=nodetype,data=dataStruct) />
				
				<cfset cFile = getMediaArchiveItem(imageID) />
				
				<cfset myID = session['vaid']>
				<cfif form['uploadBereich'] EQ "artist">
					<cfset myID = session['aid']>
				</cfif>	
				<cfif form['uploadBereich'] EQ "veranstalter">
					<cfset myID = session['vid']>
				</cfif>	
					
				<cfquery name="qMedia" datasource="#getConfig('DSN')#">
					SELECT #form['uploadTyp']# FROM #form['uploadBereich']# WHERE id = "#myID#"
				</cfquery>
				<cfset idstring = qMedia[form['uploadTyp']]>	
				<cfset idstring = ListRemoveDuplicates(ListAppend(idstring, imageID))>	
				<cfquery datasource="#getConfig('DSN')#">
					UPDATE #form['uploadBereich']# SET #form['uploadTyp']# = '#idstring#' WHERE id = "#myID#" 
				</cfquery>

				<!--- get image data --->
				<cfset qImage = getStructuredContent(nodetype=1301, instanceids=imageID, additionalSelectFields='i.width,i.height')>

				<!--- construct correct response for store --->
				<cfset newImage = {}>
				<cfset newImage['recordid'] = qImage.id>
				<cfset newImage['vorschaubild'] = href("instance:"&qImage.id)&"&dimensions=100x66&cropmode=cropcenter">
				<cfif qImage.height GT qImage.width>
					<cfset newImage["hei"] = 600>
					<cfset newImage["wid"] = 395>	
					<cfset newImage["bild"] = href("instance:"&qImage.id)&"&dimensions=395x600&cropmode=cropcenter">	
				<cfelse>
					<cfset newImage["hei"] = 495>
					<cfset newImage["wid"] = 750>	
					<cfset newImage["bild"] = href("instance:"&qImage.id)&"&dimensions=750x495&cropmode=cropcenter">	
				</cfif>	
				<cfset newImage["createdwhen"] = qImage.createdwhen>
				<cfset newImage["titel"] 		= qImage.bezeichnung>
				<cfset newImage["beschreibung"] = qImage.beschreibung>
				<cfset newImage["previewable"] = "yes">
				<cfset newImage["resolution"] = qImage.width&" x "&qImage.height>
					
				<cfif cFile.recordcount>
					<cfset returnStruct['image'] = newImage />
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