<cfcomponent>
<cfinclude template="/ameisen/functions.cfm">
<cfinclude template="/modules/functions.cfm">
<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="updateData" access="remote" returnFormat="json" output="no">

    <cfargument name="nodeType" required="yes" type="numeric">
	<cfargument name="instance" required="yes" type="string" default="0">
	
	<cfset var ndx = "">
	<cfset var myData = StructNew()>
	<cfset var editfieldnames="">
	<cfset var checkErrors 	= QueryNew('fieldname,errorlevel,errortype,errormessage,fieldtype,xmlname')>
	<cfset var saveStruct = StructNew()>
	<cfset var whereclause = "">
		
	<cfloop collection=#form# item="ndx">
		<cfset form[ndx] = trim(form[ndx])>
		<cfif StructKeyExists(form,ndx&"_time") AND StructKeyExists(form,ndx)>
			<cfset form[ndx] = CreateDateTime(year(form[ndx&"_date"]),MONTH(form[ndx&"_date"]),DAY(form[ndx&"_date"]),ListFirst(form[ndx&"_time"],":"),ListLast(form[ndx&"_time"],":"),00)>
		</cfif>
	</cfloop>
			
    <cfset var result		= {}>
    <cfset result["success"] = false>
	<cfset result["message"] = "Die Daten konnten nicht erfolgreich gespeichert werden.">
   
		
    <cfif isAuth()>
		<cfif arguments.nodeType GT 1000>
			<!--- Zu prüfende Felder festlegen	--->
			<cfset editfieldnames =  ArrayToList(getNodeTypeConfig(arguments.nodeType).getEditFieldNames())>

			<cfif StructKeyExists(form,'start')>
				<cfset editfieldnames=ListAppend(editfieldnames,'start')>
			</cfif>

			<cfif StructKeyExists(form,'stop')>
				<cfset editfieldnames=ListAppend(editfieldnames,'stop')>
			</cfif>

			<cfset myData = formToStruct(editfieldnames,"yes")>

			<!--- Nodeabhängige Validierungen durchführen --->
			<cfswitch expression="#arguments.nodeType#">
				<cfcase value="2101">
					<!--- Todo: Schnittstelle zum Ermitteln von lat und lon einbauen --->
					<cfset myData['latitude'] = "0.0000000000">
					<cfset myData['longitude'] = "0.0000000000">
				</cfcase>
				<cfcase value="2102">
					<!--- Todo: Schnittstelle zum Ermitteln von lat und lon einbauen --->
					<cfset myData['latitude'] = "0.0000000000">
					<cfset myData['longitude'] = "0.0000000000">
				</cfcase>
				<cfcase value="2103">
					<!--- Todo: Schnittstelle zum Ermitteln von lat und lon einbauen --->
					<cfset myData['latitude'] = "0.0000000000">
					<cfset myData['longitude'] = "0.0000000000">
				</cfcase>
				<cfcase value="2110">
					<cfif checkErrors.RecordCount EQ 0 AND myData['artist_fk'] EQ "">
						<cfset QueryAddRow(checkErrors)>
						<cfset QuerySetCell(checkErrors, "errormessage", 'Bitte wählen Sie einen Künstler. Suchen Sie dafür mittels Texteingabe im entsprechenden Feld und wählen Sie dann einen Künstler aus der Auswahlliste aus.')>
					</cfif>
				</cfcase>
			</cfswitch>
		</cfif>		
		<!--- Bei Errors alle zum Ausgabe Array anhängen--->
		<cfif checkErrors.RecordCount gt 0>
			<cfset result["message"] = "">
			<cfloop query="checkErrors">
				<cfset result["message"] &= REPlace(checkErrors.errormessage,"Das Feld","Das Feld "&checkErrors.fieldname,"")&"</br>">
			</cfloop>
			<cfset result["checkErrors"] = checkErrors>
		<!--- Bei erfolgreichem Errorcheck speichern--->
		<cfelse>  
			
			<cfset instanceid = arguments.instance>
			<cfif arguments.nodeType GT 1000>
				<cfif StructKeyExists(myData,'bild') AND NOT StructKeyExists(myData,'bild_upload')>
					<cfset StructDelete(myData,'bild')>
				</cfif>
				<cfif StructKeyExists(myData,'teaserbild') AND NOT StructKeyExists(myData,'teaserbild_upload')>
					<cfset StructDelete(myData,'teaserbild')>
				</cfif>

				<cfif StructKeyExists(form,'duplicate') AND form['duplicate'] EQ 1>
					<cfset instanceid = 0>
				</cfif>	
				
				<!--- Daten eintragen --->
					
				
				<cfset result["success"] = true>
				<cfset saveStruct = saveStructuredContent(nodetype=arguments.nodeType,instance=instanceid,data=myData)>

				<cfset result["message"] = "Die Daten wurden erfolgreich gespeichert.">
				<cfset result["data"] = form>
				<cfset result["instanceid"] = saveStruct['instanceid']>
				<cfset result["recordid"] = saveStruct['instanceid']>
					
				<cfset instanceid = saveStruct['instanceid']>
			<cfelse>
				<cfset result["success"] = true>
				<cfset result["message"] = "Die Daten wurden erfolgreich gespeichert.">
			</cfif>	
				
			<cfset specialDataUpdate = updateSpecialData(nodetype=arguments.nodeType,data=form,instanceid=instanceid)>
			
			<cfif specialDataUpdate['overWriteMessage'] NEQ "">
				<cfset result["message"] = specialDataUpdate['overWriteMessage']>
			</cfif>	 
				
		</cfif>
    </cfif>
   	<cfreturn result>
</cffunction>
<cffunction  name="removeParent" access="remote" returnFormat="json" output="no">
	<cfargument  name="id" required="yes" type="numeric">
	<cfset out=QueryGetRow(getStructuredContent(nodetype=2102, instanceids=id),1)>
	<cfset region=QueryGetRow(getStructuredContent(nodetype=2117, whereclause="veranstaltung_fk = #out['parent_fk']#"),1)>
	<cfset out["parent_fk"]=null>
	<cfset region["veranstaltung_fk"]=id>
	<cfset region["node_fk"]=null>
	<cfset region["id"]=null>
	<cfset saveStructuredContent(nodetype=2102, data=out, instance=id)>

	<cfreturn region>
</cffunction>
<!---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="changeArtistApproval" access="remote" returnFormat="json" output="no">
	<!--- inits --->
	<cfset var requestData = deserializeJson(getHttpRequestData().content)>
	<cfset var response    = {}>

	<!--- check if authenticated and if correct params --->
	<cfif isAuth() AND StructKeyExists(requestData, 'artistID') AND StructKeyExists(requestData, 'artistMail') AND StructKeyExists(requestData, 'approved') AND StructKeyExists(requestData, 'name')>
		<!--- update flag for that artist --->
		<cfquery name="approveArtist" datasource="#getConfig('DSN')#">
			UPDATE artist 
			SET 
				approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData.approved#">,
				approvedwhen = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData.artistID#">;
		</cfquery>
		<!--- send email --->
		<cfmail to="#requestData['artistMail']#" from="#getConfig('mail.from')#" subject="Vielen Dank für Ihre Registrierung" type="html" charset="utf-8">
			<html>
				<body>
					<h2>Hallo #requestData['name']#,</h2>
					<cfif requestData['approved']>
						<p>Vielen Dank für Ihre Registrierung als Künstler auf kulturbezirk-schwaz.tirol. Wir nehmen Ihre Daten gerne in unsere Datenbank auf. Damit werden Sie auf kulturbezirk-schwaz.tirol gefunden und können zukünftig von den Vorteilen der Plattform profitieren.</p>
					<cfelse>
						<p>Vielen Dank für Ihre Registrierung als Künstler auf kulturbezirk-schwaz.tirol. Leider können wir Ihre Registrierung nicht annehmen, weil sie nicht den Kriterien unserer Plattform entspricht.</p>
					</cfif>
				</body>
			</html>
		</cfmail>
		<!--- set response message --->
		<cfif requestData['approved']>
			<cfset response['message'] = 'Successfully approved artist with ID [#requestData.artistID#]. Send mail to [#requestData.artistMail#] from [#getConfig('mail.from')#].'>
		<cfelse>
			<cfset response['message'] = 'Successfully rejected artist with ID [#requestData.artistID#]. Send mail to [#requestData.artistMail#] from [#getConfig('mail.from')#].'>
		</cfif>
	<cfelse>
		<cfset response['message'] = 'Not authenticated or wrong parameters'>
	</cfif>

	<!--- return response --->
	<cfreturn response>
</cffunction>
<!---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="changeOrganizerApproval" access="remote" returnFormat="json" output="no">
	<!--- inits --->
	<cfset var requestData = deserializeJson(getHttpRequestData().content)>
	<cfset var response    = {}>

	<!--- check if authenticated and if correct params --->
	<cfif isAuth() AND StructKeyExists(requestData, 'organizerID') AND StructKeyExists(requestData, 'organizerMail') AND StructKeyExists(requestData, 'approved') AND StructKeyExists(requestData, 'name')>
		<!--- update flag for that artist --->
		<cfquery name="approveOrganizer" datasource="#getConfig('DSN')#">
			UPDATE veranstalter 
			SET 
				approved = <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData.approved#">,
				approvedwhen = <cfqueryparam cfsqltype="cf_sql_date" value="#now()#">
			WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#requestData.organizerID#">;
		</cfquery>
		<!--- send email --->
		<cfmail to="#requestData['organizerMail']#" from="#getConfig('mail.from')#" subject="Vielen Dank für Ihre Registrierung" type="html" charset="utf-8">
			<html>
				<body>
					<h2>Hallo #requestData['name']#,</h2>
					<cfif requestData['approved']>
						<p>Vielen Dank für Ihre Registrierung als Künstler auf kulturbezirk-schwaz.tirol. Wir nehmen Ihre Daten gerne in unsere Datenbank auf. Damit werden Sie auf kulturbezirk-schwaz.tirol gefunden und können zukünftig von den Vorteilen der Plattform profitieren.</p>
					<cfelse>
						<p>Vielen Dank für Ihre Registrierung als Künstler auf kulturbezirk-schwaz.tirol. Leider können wir Ihre Registrierung nicht annehmen, weil sie nicht den Kriterien unserer Plattform entspricht.</p>
					</cfif>
				</body>
			</html>
		</cfmail>
		<!--- set response message --->
		<cfif requestData['approved']>
			<cfset response['message'] = 'Successfully approved organizer with ID [#requestData.organizerID#]. Send mail to [#requestData.organizerMail#] from [#getConfig('mail.from')#].'>
		<cfelse>
			<cfset response['message'] = 'Successfully rejected organizer with ID [#requestData.organizerID#]. Send mail to [#requestData.organizerMail#] from [#getConfig('mail.from')#].'>
		</cfif>
	<cfelse>
		<cfset response['message'] = 'Not authenticated or wrong parameters'>
	</cfif>

	<!--- return response --->
	<cfreturn response>
</cffunction>
<!---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfsilent>
</cfcomponent>