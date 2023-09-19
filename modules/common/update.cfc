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
				
		<!--- Bei Errors alle zum Ausgabe Array anhängen--->
		<cfif checkErrors.RecordCount gt 0>
			<cfset result["message"] = "">
			<cfloop query="checkErrors">
				<cfset result["message"] &= REPlace(checkErrors.errormessage,"Das Feld","Das Feld "&checkErrors.fieldname,"")&"</br>">
			</cfloop>
			<cfset result["checkErrors"] = checkErrors>
		<!--- Bei erfolgreichem Errorcheck speichern--->
		<cfelse>  
			<cfif StructKeyExists(myData,'bild') AND NOT StructKeyExists(myData,'bild_upload')>
				<cfset StructDelete(myData,'bild')>
			</cfif>
			<cfif StructKeyExists(myData,'teaserbild') AND NOT StructKeyExists(myData,'teaserbild_upload')>
				<cfset StructDelete(myData,'teaserbild')>
			</cfif>
				
			<cfset myInstance = arguments.instance>
			<cfif StructKeyExists(form,'duplicate') AND form['duplicate'] EQ 1>
				<cfset myInstance = 0>
			</cfif>	
				
			<!--- Daten eintragen --->
			<cfset result["success"] = true>
			<cfset saveStruct = saveStructuredContent(nodetype=arguments.nodeType,instance=myInstance,data=myData)>
				
			<cfset result["message"] = "Die Daten wurden erfolgreich gespeichert.">
			<cfset result["data"] = form>
			<cfset result["instanceid"] = saveStruct['instanceid']>
			<cfset result["recordid"] = saveStruct['instanceid']>
			
			<cfset instanceid = saveStruct['instanceid']>
			
			<cfset specialDataUpdate = updateSpecialData(nodetype=arguments.nodeType,data=form,instanceid=instanceid)>
			
			<cfif specialDataUpdate['overWriteMessage'] NEQ "">
				<cfset result["message"] = specialDataUpdate['overWriteMessage']>
			</cfif>	 
				
		</cfif>
    </cfif>
   	<cfreturn result>
</cffunction>
<!---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="updateSort" access="remote" returnFormat="json">
    <cfargument name="von" required="yes" type="numeric">
    <cfargument name="nach" required="yes" type="numeric">
    <cfargument name="dropPosition" required="yes" type="string">
    <cfargument name="dbname" required="yes" type="string" default="">
   	<cfset sortStruct = StructNew()>
	<cfset kidStruct = StructNew()>
	<cfset var result		= {}>
	<cfset result['success'] = false>	
		
	<cfif arguments.dbname EQ "r_kategorien_subkategorien">
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				rks.id, k.id kid, k.name kategorie, s.id sid, s.name subkategorie, rks.sortierung
			FROM 
				kategorien k
				LEFT JOIN r_kategorien_subkategorien rks on k.id = rks.kategorie_fk
				LEFT JOIN subkategorien s on rks.subkategorie_fk = s.id
			ORDER BY 
				k.name, rks.sortierung
		</cfquery>
		<cfloop query="qData">
			<cfset sortStruct[qData.id] = qData.sortierung>
			<cfset kidStruct[qData.id] = qData.kid>
		</cfloop>
		<cfif kidStruct[arguments.von] NEQ kidStruct[arguments.nach]>
			<cfset result['message'] = "Umsortierung nur innerhalb der eigenen Gruppe möglich.">
			<cfreturn result>
		</cfif>
	</cfif>	
		
	<cfif arguments.dbname EQ "tagsort">
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				ts2.id, ts2.sortierung, ts2.r_kategorien_subkategorien_fk
			FROM 
				tagsort ts
				LEFT JOIN tagsort ts2 on ts.r_kategorien_subkategorien_fk = ts2.r_kategorien_subkategorien_fk
			WHERE 
				ts.id = #arguments.von#
			ORDER BY 
				ts2.sortierung
		</cfquery>
		<cfloop query="qData">
			<cfset sortStruct[qData.id] = qData.sortierung>
		</cfloop>
	</cfif>

		<cfif isAuth()>
            <cfset sort_neu = sortStruct[arguments.nach]>
			<cfset von = sortStruct[arguments.von]>	
			<cfset nach = sortStruct[arguments.nach]>	
            <cfif nach LT von>
                <cfset betroffenVon = nach>
                <cfset betroffenBis = von>
                <cfif arguments.dropPosition EQ "after">
                    <cfset sort_neu++>
                    <cfset betroffenVon++>
                </cfif>
            <cfelse>
                <cfset betroffenVon = von>
                <cfset betroffenBis = nach>
                <cfif arguments.dropPosition EQ "before">
                    <cfset sort_neu-->
                     <cfset betroffenBis-->
                </cfif>
            </cfif>
            <cfquery name="toSort" datasource="#getConfig('DSN')#">
                SELECT * FROM #arguments.dbname# WHERE sortierung >= #betroffenVon# AND sortierung <= #betroffenBis# AND sortierung != #arguments.von# <cfif arguments.dbname EQ "tagsort"> AND r_kategorien_subkategorien_fk = #qData.r_kategorien_subkategorien_fk#</cfif>
            </cfquery>
             <cfquery name="toUpdate" datasource="#getConfig('DSN')#">
                SELECT id FROM #arguments.dbname# WHERE sortierung = #arguments.von# <cfif arguments.dbname EQ "tagsort"> AND r_kategorien_subkategorien_fk = #qData.r_kategorien_subkategorien_fk#</cfif>
            </cfquery>
            <cfif toSort.recordcount NEQ 0 AND toUpdate.recordcount NEQ 0  >
                <!--- Alle nicht gewählten umsortieren --->
                <cfquery name="q_upd_container" datasource="#getConfig('DSN')#">
                    UPDATE #arguments.dbname# SET  <cfif nach LT von> sortierung = sortierung +1 <cfelse> sortierung = sortierung -1 </cfif> WHERE id IN (#ValueList(toSort.id)#) 
                </cfquery>
                <!--- Gewählten auf richtige position setzen --->
                <cfquery name="q_upd_container" datasource="#getConfig('DSN')#">
                    UPDATE #arguments.dbname# SET sortierung = #sort_neu# WHERE id = #toUpdate.id#
                </cfquery>
            </cfif>
			<cfset result['success'] = true>
		</cfif>
   	<cfreturn result>
</cffunction>
</cfsilent>
<!---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfcomponent>