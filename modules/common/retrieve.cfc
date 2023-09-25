<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfcomponent>
<cfinclude template="/ameisen/functions.cfm">
<cfinclude template="/modules/functions.cfm">
<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="getMainMenu" access="remote" returnFormat="json">

	<!--- Return array erstellen --->
	<cfset var mainmenu		= ArrayNew(1)>
	<cfset var submenu		= ArrayNew(1)>
	<cfset var subsubmenu	= ArrayNew(1)>
	<cfset var item			= StructNew()>
	<cfset var subitem		= StructNew()>
	<cfset var subsubitem	= StructNew()>
	<cfset var result		= StructNew()>

	<!--- Menü auslesen --->
	<cfset qItems = getMenuItems(getNodeId(resolveVPath('verwaltungsclient')))>
		
	<!--- Handlernamen auslesen --->
	<cfset qAdditionalInfos = getStructuredContent(templateid=2,whereclause="lhandlername.data!=''")>
	
	<!--- zum return array hinzufügen --->
	<cfloop query="qItems">

		<!--- Hauptmenü schreiben --->
		<cfset item = StructNew()>
		<cfset item["pagetitle"] = qItems.pagetitle>
		<cfset item["node_fk"] = qItems.node_fk>

		<!--- Handlername suchen --->

		<cfset arraypos = ListFind(ValueList(qAdditionalInfos.id), ToString(qItems.id))>

		<cfif arraypos gte 1>
			<cfset item["handler"] = qAdditionalInfos['handlername'][arraypos]>
			<cfset item["controller"] = qAdditionalInfos['controller'][arraypos]>
		</cfif>

		<!--- Submenü auslesen --->
		<cfset qSubItems = getMenuItems(qItems.node_fk)>

		<!--- Speicher Array anlegen --->
		<cfset submenu	= ArrayNew(1)>

		<!--- Submenü durchloopen --->
		<cfloop query="qSubItems">
			<cfset subitem = StructNew()>
			<cfset subitem["pagetitle"] = qSubItems.pagetitle>
			<cfset subitem["node_fk"] = qSubItems.node_fk>

			<!--- Handlername suchen --->

			<cfset arraypos = ListFind(ValueList(qAdditionalInfos.id), ToString(qSubItems.id))>

			<cfif arraypos gte 1>
				<cfset subitem["handler"] = qAdditionalInfos['handlername'][arraypos]>
				<cfset subitem["controller"] = qAdditionalInfos['controller'][arraypos]>
			</cfif>

				<!--- Subsubmenü auslesen --->
				<cfset qSubSubItems = getMenuItems(qSubItems.node_fk)>
				<!--- Speicher Array anlegen --->
				<cfset subsubmenu	= ArrayNew(1)>

				<!--- Subsubmenü durchloopen --->
				<cfloop query="qSubSubItems">
				
					<cfset subsubitem = StructNew()>
					<cfset subsubitem["pagetitle"] = qSubSubItems.pagetitle>
					<cfset subsubitem["node_fk"] = qSubSubItems.node_fk>

					<!--- Handlername suchen --->

					<cfset arraypos = ListFind(ValueList(qAdditionalInfos.id), ToString(qSubSubItems.id))>

					<cfif arraypos gte 1>
						<cfset subsubitem["handler"] = qAdditionalInfos['handlername'][arraypos]>
						<cfset subsubitem["controller"] = qAdditionalInfos['controller'][arraypos]>
					</cfif>

					<cfset ArrayAppend(subsubmenu, subsubitem)>
				
				</cfloop>

			<!--- Subsubmenü dem Submenü hinzufügen --->
			<cfif qSubSubItems.recordcount gte 1>
				<cfset subitem["submenuitems"] = subsubmenu>
			</cfif>
			
			<!--- Items dem Submenü anhängen --->
			<cfset ArrayAppend(submenu, subitem)>
		</cfloop>

		<!--- Submenü dem Menü anhängen --->
		<cfif qSubItems.recordcount gte 1>
			<cfset item["submenuitems"] = submenu>
		</cfif>

		<!--- Items dem Menü anhängen --->
		<cfset ArrayAppend(mainmenu, item)>

	</cfloop>

	<cfif qItems.recordcount neq "">
		<cfset result['menuitems'] = mainmenu>
	</cfif>

	<cfreturn result>

</cffunction>

<!--------------------------------------------------------------------------------->
<!--- diese Funktion gibt die Information zurück ob der user angemeldet ist und falls ja wie der username etc. lautet --->
<!--------------------------------------------------------------------------------->

<cffunction name="getAuthStatus" access="remote" returntype="struct" returnFormat="JSON" output="no">
       
	<cfset var returnStruct = StructNew()>
	<cfset var tmpStruct = StructNew()>
	<cfset var myAllowedSites = "">

	<!--- success ist wichtig, wird zwar nicht als store information gebraucht, aber wenn ein formular eine abfrage hierhermacht (login) dann muss ein success true zurueckkommen --->
	<cfset returnStruct['success'] = true>
	<cfset returnStruct['message'] = "">
	<cfset tmpStruct['isauth'] = false>
	<cfset tmpStruct['username'] = "">
	<cfset tmpStruct['displayname'] = "">

	<!--- alle Berechtigungen initial auf false setzen --->

	<cfset tmpStruct['ameisen'] = false>
	
	<cfif isAuth()>   
		<!--- Erlaubte Seiten in Authstore mitspeichern --->
		<cfset qItems = getMenuItems(getNodeId(resolveVPath('verwaltungsclient')))>
		<cfset myAllowedSites = ListAppend(myAllowedSites,lcase(ValueList(qItems.label)))>
		<cfloop query="qItems">
			<cfset qSubItems = getMenuItems(qItems.node_fk)>
			<cfif qSubItems.recordcount neq 0>
				<cfset myAllowedSites = ListAppend(myAllowedSites,ValueList(qSubItems.label))>
			</cfif>
		</cfloop>
		<cfset tmpStruct['isauth'] = true>
		<cfset tmpStruct['username'] = session.user.name>
		<cfset tmpStruct['vorname'] = session.user.data.vorname>
		<cfset tmpStruct['nachname'] = session.user.data.nachname>
		<cfset tmpStruct['handler'] = "Veranstaltungen">
		<cfset tmpStruct['controller'] = "Common">
		<cfset tmpStruct['user_fk'] = session.user.data.userid>
		<cfset tmpStruct['allowedSites'] = ","&myAllowedSites&",">
		<cfset tmpStruct['mygroups'] = ValueList(session.user.groups.username)>

		<!--- Administrator freischalten --->
		<cfif isAdmin()>
			<cfset tmpStruct['administrator'] = true>
		</cfif>

	<cfelse>
		<cfset returnStruct['success'] = false>
		<cfset returnStruct['message'] = "Sie haben nicht die erforderliche Berechtigung diese Applikation zu starten.">
	</cfif>
			
	<cfset returnStruct['userinformation'] = tmpStruct>
	<cfreturn returnStruct>
    
</cffunction>

<!--------------------------------------------------------------------------------->
<!--- diese Funktion gibt die Felder der windows zurück --->
<!--------------------------------------------------------------------------------->
<cffunction name="getWindowFields" access="remote" returnFormat="json">
   
	<cfset var returnArray = ArrayNew(1)>
	<cfset var storeArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	<cfset var myFields = QueryNew('id')>
	
	<cfif isAuth()>
		<!--- Alle Felder der Fenster auslesen --->
		<cfset myFields = getStructuredContent(nodetype=2199)>
		<cfset myWindows = getStructuredContent(nodetype=2198)>
		
        <cfprocessingdirective suppresswhitespace="true">
			<cfloop query="myFields">
				<cfset tmpStruct = {}>
				<cfset tmpStruct["windowname"]		= LCase(myWindows['windowname'][ListFind(ValueList(myWindows.id),myFields.windowname)])>
				<cfset tmpStruct["xtype"]			= myFields.xtype>
				<cfset tmpStruct["fieldlabel"]		= myFields.fieldlabel>
				<cfset tmpStruct["name"]			= myFields.name_db>
				<!--- Wenn ein Beistrich im storenamen gefunden wird, handelt es sich um keinen "echten" store und es wird ein array aufgebaut--->
				<cfif Find(",",myFields.store) neq 0>
					<cfset storeArray = ArrayNew(1)>
					<cfloop list="#myFields.store#" delimiters="|" index="cItem">
						<cfset ArrayAppend(storeArray,[ListFirst(cItem),ListLast(cItem)])>
					</cfloop>
					<cfset tmpStruct["store"]			= storeArray>
				<cfelse>
					<cfset tmpStruct["store"]			= myFields.store>
				</cfif>
				<cfset tmpStruct["displayfield"]	= myFields.displayfield>
				<cfset tmpStruct["valuefield"]		= myFields.valuefield>
				<cfset tmpStruct["mandatory"]		= myFields.mandatory>
				<cfset tmpStruct["emptytext"]		= myFields.emptytext>
				<cfset tmpStruct["value"]			= myFields.value>
				<cfset tmpStruct["querymode"]		= myFields.querymode>
				<cfset tmpStruct["height"]			= myFields.height>
				<cfset tmpStruct["sortierung"]		= myFields.sort>
				<cfset tmpStruct["mehrfachauswahl"]	= myFields.mehrfachauswahl>
				<cfset tmpStruct["readonly"]		= myFields.readonly>
				<cfset tmpStruct["hidden"]			= myFields.hidden>
				<cfset tmpStruct["mehrfachauswahl_convert"]	= myFields.mehrfachauswahl_convert>
				<cfset tmpStruct["showenptycombobutton"]	= myFields.showenptycombobutton>
				<cfset tmpStruct["showselectallcombobutton"]= myFields.showselectallcombobutton>
				<cfset tmpStruct["flags"]= myFields.flags>
				<cfset tmpStruct["tab"]= myFields.tab>
				<cfset tmpStruct["tabname"]= getContentLabel('windowfields','tab',myFields.tab)>
				<cfset tmpStruct["maxlength"]		= myFields.maxlength>
						
				<cfset ArrayAppend(returnArray, tmpStruct)>
			</cfloop>
        </cfprocessingdirective>
		
   </cfif>
    <cfreturn returnArray>
</cffunction>
<!--------------------------------------------------------------------------------->
<!--- diese Funktion gibt alle Länder zurück --->
<!--------------------------------------------------------------------------------->
<cffunction name="getLaender" access="remote" returnFormat="json">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	<cfset var qCountries = QueryNew('')>
   	
     <cfprocessingdirective suppresswhitespace="true">
  	
		<!--- Länder auslesen --->
        <cfset qCountries = getCountries()>
        
		<cfset tmpStruct = {}>
        <cfset tmpStruct["laenderkuerzel"]	= "at">
        <cfset tmpStruct["name"]			= "Österreich">
        <cfset ArrayAppend(returnArray, tmpStruct)>
        
        <cfset tmpStruct = {}>
        <cfset tmpStruct["laenderkuerzel"]	= "de">
        <cfset tmpStruct["name"]			= "Deutschland">
        <cfset ArrayAppend(returnArray, tmpStruct)>
        
        <cfset tmpStruct = {}>
        <cfset tmpStruct["laenderkuerzel"]	= "it">
        <cfset tmpStruct["name"]			= "Italien">
        <cfset ArrayAppend(returnArray, tmpStruct)>
        
        <cfset tmpStruct = {}>
        <cfset tmpStruct["laenderkuerzel"]	= "">
        <cfset tmpStruct["name"]			= "- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -">
        <cfset ArrayAppend(returnArray, tmpStruct)>
            
        <cfloop query="qCountries">
        	<cfif qCountries.isocode neq "at" AND qCountries.isocode neq "de" AND qCountries.isocode neq "it">
				<cfset tmpStruct = {}>
                <cfset tmpStruct["laenderkuerzel"]	= qCountries.isocode>
                <cfset tmpStruct["name"]			= qCountries.name>
                <cfset ArrayAppend(returnArray, tmpStruct)>
            </cfif>
        </cfloop>
	
    </cfprocessingdirective>  
	
    <cfreturn returnArray>
    
</cffunction>
<!--------------------------------------------------------------------------------->					
					
<cffunction name="getVeranstaltungen" access="remote" returnFormat="json" output="yes">
	
	<cfargument name="filterText" type="string" required="no" default="">
	<cfargument name="filterVon" type="string" required="no" default="">
	<cfargument name="filterBis" type="string" required="no" default="">
		
	<cfargument name="filterOrt" type="string" required="no" default="">
	<cfargument name="filterBezirk" type="string" required="no" default="">
		
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
	<cfset var qSearch = QueryNew('id')>
	<cfset var result = structNew() >

	<!---	
	<cfset var sTagNamen = StructNew()>
	<cfset var sTagIDs = StructNew()>
	<cfset var sKategorieNamen = StructNew()>
	<cfset var sKategorieIDs = StructNew()>
	<cfset qTagDoks = QueryNew('dokument_fk')>	
	<cfset qKategorienDoks = QueryNew('dokument_fk')>	
	<cfset lSolrDoks = "">	
	--->
		
	<cfif isAuth()>
		
		<cfif arguments.filterText NEQ "" OR arguments.filterVon NEQ "" OR arguments.filterBis NEQ "">
			<cfquery name="qSearch" datasource="#getConfig('DSN')#">
				SELECT *, if(parent_fk is null,id,parent_fk) as finalid 
				FROM veranstaltung 
				WHERE 
					1=1
					<cfif arguments.filterText NEQ "">
						AND name like '%#arguments.filterText#%'
					</cfif>
					<cfif arguments.filterVon NEQ "">
						AND von >= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.filterVon#">
					</cfif>
					<cfif arguments.filterBis NEQ "">
						AND von <= <cfqueryparam cfsqltype="CF_SQL_DATE" value="#arguments.filterBis#">
					</cfif>
			</cfquery>
		</cfif>
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				v1.*, v2.name parent_name
			FROM 
				veranstaltung v1
				LEFT JOIN veranstaltung v2 on v1.parent_fk = v2.id
			WHERE
				1=1
				<cfif arguments.filterText NEQ "" OR arguments.filterVon NEQ "" OR arguments.filterBis NEQ "">	
					<cfif qSearch.recordcount NEQ 0>
						AND v1.id IN(#ValueList(qSearch.finalid)#) OR v1.parent_fk IN(#ValueList(qSearch.finalid)#)
					<cfelse>
						AND 1=2
					</cfif>	
				</cfif>	
			ORDER BY 
				v1.von, v1.uhrzeitvon
		</cfquery>
			
		<cfquery name="qVATyp" datasource="#getConfig('DSN')#">
			SELECT * FROM r_veranstaltung_typ 
		</cfquery>
	
					
		<cfloop query="qData">
			
			<cfif qData.parent_fk EQ "">
			
				<cfquery name="qSubData" dbtype="query">
					SELECT * FROM qData WHERE parent_fk = '#qData.id#'
				</cfquery>
				<cfquery name="tmpVATyp" dbtype="query">
					SELECT * FROM qVATyp WHERE veranstaltung_fk = '#qData.id#'
				</cfquery>
				<cfset tmpStruct = {}>
				<cfset tmpStruct["recordid"] = qData.id>
				<cfset tmpStruct["parent_fk"] = null>
				<cfset tmpStruct["children"] = qSubData.recordcount>
				<cfset tmpStruct["opened"] = 1>
				<cfset tmpStruct["name"] = qData.name>
				<cfset tmpStruct["parent_name"] = qData.parent_name>
				<cfset tmpStruct["von"] = qData.von>
				<cfset tmpStruct["bis"] = qData.bis>
				<cfset tmpStruct["uhrzeitvon"] = qData.uhrzeitvon>
				<cfset tmpStruct["uhrzeitbis"] = qData.uhrzeitbis>
				<cfset tmpStruct["ort_fk"] = qData.ort_fk>
				<cfset tmpStruct["ort_name"] = qData.ort_fk>
				<cfset tmpStruct["bezirk"] = qData.ort_fk>
				<cfset tmpStruct["veranstaltungsort"] = qData.veranstaltungsort>
				<cfset tmpStruct["adresse"] = qData.adresse>
				<cfset tmpStruct["plz"] = qData.plz>
				<cfset tmpStruct["ort"] = qData.ort>
				<cfset tmpStruct["latitude"] = qData.latitude>
				<cfset tmpStruct["longitude"] = qData.longitude>
				<cfset tmpStruct["beschreibung"] = qData.beschreibung>
				<cfset tmpStruct["preis"] = qData.preis>
				<cfset tmpStruct["bilder"] = qData.bilder>
				<cfset tmpStruct["link"] = qData.link>
				<cfset tmpStruct["uploads"] = qData.uploads>
				<cfset tmpStruct["optionstyle"]	= "font-weight: bold; border-bottom: 1px dotted ##e6e6e6; padding: 1px 6px;">		
				<cfset tmpStruct["typ_fk"]	= valueList(tmpVATyp.typ_fk)>
				<cfset ArrayAppend(returnArray, tmpStruct)>
				
				<cfloop query="qSubData">
					<cfquery name="tmpVATyp" dbtype="query">
						SELECT * FROM qVATyp WHERE veranstaltung_fk = '#qSubData.id#'
					</cfquery>
					<cfset tmpStruct = {}>
					<cfset tmpStruct["recordid"] = qSubData.id>
					<cfset tmpStruct["parent_fk"] = qSubData.parent_fk>
					<cfset tmpStruct["opened"] = 1>
					<cfset tmpStruct["children"] = 0>
					<cfset tmpStruct["name"] = qSubData.name>
					<cfset tmpStruct["parent_name"] = qSubData.parent_name>
					<cfset tmpStruct["von"] = qSubData.von>
					<cfset tmpStruct["bis"] = qSubData.bis>
					<cfset tmpStruct["uhrzeitvon"] = qSubData.uhrzeitvon>
					<cfset tmpStruct["uhrzeitbis"] = qSubData.uhrzeitbis>
					<cfset tmpStruct["ort_fk"] = qSubData.ort_fk>
					<cfset tmpStruct["ort_name"] = qSubData.ort_fk>
					<cfset tmpStruct["bezirk"] = qSubData.ort_fk>
					<cfset tmpStruct["veranstaltungsort"] = qSubData.veranstaltungsort>
					<cfset tmpStruct["adresse"] = qSubData.adresse>
					<cfset tmpStruct["plz"] = qSubData.plz>
					<cfset tmpStruct["ort"] = qSubData.ort>
					<cfset tmpStruct["latitude"] = qSubData.latitude>
					<cfset tmpStruct["longitude"] = qSubData.longitude>
					<cfset tmpStruct["beschreibung"] = qSubData.beschreibung>
					<cfset tmpStruct["preis"] = qSubData.preis>
					<cfset tmpStruct["bilder"] = qSubData.bilder>
					<cfset tmpStruct["link"] = qSubData.link>
					<cfset tmpStruct["uploads"] = qSubData.uploads>
					<cfset tmpStruct["optionstyle"]	= "border-bottom: 1px dotted ##e6e6e6; padding: 1px 6px 1px 24px; background-image: url('/img/ul.png'); background-repeat: no-repeat; background-position: 10px 6px;">	
					<cfset tmpStruct["typ_fk"]	= valueList(tmpVATyp.typ_fk)>
					<cfset ArrayAppend(returnArray, tmpStruct)>
				</cfloop>		

			</cfif>	
				
		</cfloop>
			
	</cfif>				

	<cfreturn returnArray>
    
</cffunction>				
					
<!--------------------------------------------------------------------------------->
<cffunction name="getArtists" access="remote" returnFormat="json" output="no">
	
	<cfargument name="filterText" type="string" required="no" default="">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>		
		
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				a.*
			FROM 
				artist a
			WHERE
				1=1
				<cfif arguments.filterText NEQ "">
					AND a.name like '%#arguments.filterText#%'
				</cfif>	
			ORDER BY 
				a.name
		</cfquery>
		
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.id>
			<cfset tmpStruct["user_fk"] 	= qData.user_fk>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset tmpStruct["ansprechperson"] 	= qData.ansprechperson>
			<cfset tmpStruct["adresse"] 	= qData.adresse>
			<cfset tmpStruct["plz"] 	= qData.plz>
			<cfset tmpStruct["ort"] 	= qData.ort>
			<cfset tmpStruct["latitude"] 	= qData.latitude>
			<cfset tmpStruct["longitude"] 	= qData.longitude>
			<cfset tmpStruct["telefon"] 	= qData.telefon>
			<cfset tmpStruct["email"] 	= qData.email>
			<cfset tmpStruct["web"] 	= qData.web>
			<cfset tmpStruct["link"] 	= qData.link>
			<cfset tmpStruct["beschreibung"] 	= qData.beschreibung>
			<cfset tmpStruct["bilder"] 	= qData.bilder>
			<cfset tmpStruct["uploads"] 	= qData.uploads>
			<cfset tmpStruct["geprueft"] 	= qData.geprueft>
				
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>	
				
<!--------------------------------------------------------------------------------->
<cffunction name="getVeranstalter" access="remote" returnFormat="json" output="no">
	
	<cfargument name="filterText" type="string" required="no" default="">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>		
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				v.*
			FROM 
				veranstalter v
			WHERE
				1=1
				<cfif arguments.filterText NEQ "">
					AND v.name like '%#arguments.filterText#%'
				</cfif>	
			ORDER BY 
				v.name
		</cfquery>
		
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.id>
			<cfset tmpStruct["ort_fk"] 	= qData.ort_fk>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset tmpStruct["adresse"] 	= qData.adresse>
			<cfset tmpStruct["plz"] 	= qData.plz>
			<cfset tmpStruct["ort"] 	= qData.ort>
			<cfset tmpStruct["latitude"] 	= qData.latitude>
			<cfset tmpStruct["longitude"] 	= qData.longitude>
			<cfset tmpStruct["telefon"] 	= qData.telefon>
			<cfset tmpStruct["email"] 	= qData.email>
			<cfset tmpStruct["web"] 	= qData.web>
			<cfset tmpStruct["beschreibung"] 	= qData.beschreibung>
				
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>	
<!--------------------------------------------------------------------------------->
<cffunction name="getRVeranstaltungVeranstalter" access="remote" returnFormat="json" output="no">
	
	<cfargument name="veranstaltung_fk" type="numeric" required="yes">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>		
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				v.*, rvv.veranstaltung_fk, rvv.veranstalter_fk, rvv.id rvvid
			FROM 
				r_veranstaltung_veranstalter rvv
				LEFT JOIN veranstalter v on rvv.veranstalter_fk = v.id
			WHERE
				rvv.veranstaltung_fk = '#arguments.veranstaltung_fk#'
			ORDER BY 
				v.name
		</cfquery>
		
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.rvvid>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset tmpStruct["veranstaltung_fk"] 	= qData.veranstaltung_fk>
			<cfset tmpStruct["veranstalter_fk"] 	= qData.veranstalter_fk>
			<cfset tmpStruct["adresse"] 	= qData.adresse>
			<cfset tmpStruct["plz"] 	= qData.plz>
			<cfset tmpStruct["ort"] 	= qData.ort>
			<cfset tmpStruct["latitude"] 	= qData.latitude>
			<cfset tmpStruct["longitude"] 	= qData.longitude>
			<cfset tmpStruct["telefon"] 	= qData.telefon>
			<cfset tmpStruct["email"] 	= qData.email>
			<cfset tmpStruct["web"] 	= qData.web>
			<cfset tmpStruct["beschreibung"] 	= qData.beschreibung>
				
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>		
<!--------------------------------------------------------------------------------->
<cffunction name="getRVeranstaltungArtist" access="remote" returnFormat="json" output="no">
	
	<cfargument name="filterText" type="string" required="no" default="">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>	
		
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				rva.*, a.name
			FROM 
				r_veranstaltung_artist rva
				LEFT JOIN artist a on rva.artist_fk = a.id
			WHERE
				rva.veranstaltung_fk = '#arguments.veranstaltung_fk#'
			ORDER BY 
				a.name
		</cfquery>
	
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.id>
			<cfset tmpStruct["veranstaltung_fk"] 	= qData.veranstaltung_fk>
			<cfset tmpStruct["artist_fk"] 	= qData.artist_fk>
			<cfset tmpStruct["ort_fk"] 	= qData.ort_fk>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset tmpStruct["uhrzeitvon"] 	= qData.uhrzeitvon>
			<cfset tmpStruct["uhrzeitbis"] 	= qData.uhrzeitbis>
			<cfset tmpStruct["veranstaltungsort"] 	= qData.veranstaltungsort>
			<cfset tmpStruct["adresse"] 	= qData.adresse>
			<cfset tmpStruct["plz"] 	= qData.plz>
			<cfset tmpStruct["ort"] 	= qData.ort>
			<cfset tmpStruct["latitude"] 	= qData.latitude>
			<cfset tmpStruct["longitude"] 	= qData.longitude>
			<cfset tmpStruct["beschreibung"] 	= qData.beschreibung>
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>						
<!--------------------------------------------------------------------------------->					
<cffunction name="qTags" access="remote" returnFormat="json" output="no">
	
	<cfargument name="veranstaltung_fk" type="string" required="no" default="">
	<cfargument name="filterText" type="string" required="no" default="">
		
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>	
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				t.*
				<cfif arguments.veranstaltung_fk NEQ "">
				, rvt.id rvtid
				</cfif>
			FROM 
				tag t
				<cfif arguments.veranstaltung_fk NEQ "">
					LEFT JOIN r_veranstaltung_tag rvt on rvt.tag_fk = t.id AND rvt.veranstaltung_fk = '#arguments.veranstaltung_fk#'
				</cfif>
			WHERE
				1=1
				<cfif arguments.filterText NEQ "">
					AND t.name like '%#arguments.filterText#%'
				</cfif>
				
			ORDER BY 
				t.name
		</cfquery>
		
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.id>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset tmpStruct["checked"] = 1>
			<cfif arguments.veranstaltung_fk NEQ "" AND qData.rvtid EQ "">	
				<cfset tmpStruct["checked"] = 0>
			</cfif>	
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>							
<!--------------------------------------------------------------------------------->				
<cffunction name="getBilder" access="remote" returnFormat="json" output="no">
	<cfargument name="veranstaltung_fk" type="string" required="no" default="0">
  	<cfargument name="artist_fk" type="string" required="no" default="0">
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
	<cfif isAuth()>	
		<cfif arguments.veranstaltung_fk NEQ 0>
			<cfquery name="qData" datasource="#getConfig('DSN')#">
				SELECT bilder FROM veranstaltung WHERE id = "#arguments.veranstaltung_fk#" 
			</cfquery>
		<cfelseif arguments.artist_fk NEQ 0>
			<cfquery name="qData" datasource="#getConfig('DSN')#">
				SELECT bilder FROM artist WHERE id = "#arguments.artist_fk#" 
			</cfquery>
		</cfif>	
		<cfif qData.bilder NEQ "">
			<cfset qData = getStructuredContent(nodetype=1301,instanceids="#qData.bilder#",additionalSelectFields='i.width,i.height')>
			<cfloop query="qData">
				<cfset tmpStruct = {}>
				<cfset tmpStruct["recordid"] 	= qData.id>	
				<cfset tmpStruct["vorschaubild"] = href("instance:"&qData.id)&"&dimensions=100x66&cropmode=cropcenter">	
				<cfif qData.height GT qData.width>
					<cfset tmpStruct["hei"] = 600>
					<cfset tmpStruct["wid"] = 395>	
					<cfset tmpStruct["bild"] = href("instance:"&qData.id)&"&dimensions=395x600&cropmode=cropcenter">	
				<cfelse>
					<cfset tmpStruct["hei"] = 495>
					<cfset tmpStruct["wid"] = 750>	
					<cfset tmpStruct["bild"] = href("instance:"&qData.id)&"&dimensions=750x495&cropmode=cropcenter">	
				</cfif>	
				
				<cfset tmpStruct["createdwhen"] = qData.createdwhen>
				<cfset tmpStruct["titel"] 		= qData.bezeichnung>
				<cfset tmpStruct["beschreibung"] = qData.beschreibung>
				<cfset tmpStruct["previewable"] = "yes">
				<cfset tmpStruct["resolution"] = qData.width&" x "&qData.height>
				<cfset ArrayAppend(returnArray, tmpStruct)>
			</cfloop>
		</cfif>		
	</cfif> 
    <cfreturn returnArray>
</cffunction>						
<!--------------------------------------------------------------------------------->				
<cffunction name="getDownloads" access="remote" returnFormat="json" output="no">
	<cfargument name="veranstaltung_fk" type="string" required="no" default="0">
  	<cfargument name="artist_fk" type="string" required="no" default="0">
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
	<cfif isAuth()>	
	
		<cfif arguments.veranstaltung_fk NEQ 0>
			<cfquery name="qData" datasource="#getConfig('DSN')#">
				SELECT uploads FROM veranstaltung WHERE id = "#arguments.veranstaltung_fk#" 
			</cfquery>
		<cfelseif arguments.artist_fk NEQ 0>
			<cfquery name="qData" datasource="#getConfig('DSN')#">
				SELECT uploads FROM artist WHERE id = "#arguments.artist_fk#" 
			</cfquery>
		</cfif>	
		
		
		<cfif qData.uploads NEQ "">
			<cfset qData = getStructuredContent(nodetype=1301,instanceids="#qData.uploads#",additionalSelectFields='i.width,i.height')>
			<cfloop query="qData">
				
				<cfset myIMG = "/img/icons/else.png">
				<cfif ListFind("pdf,ppt,pptx,doc,docx,xls,xlsx",ListLast(qData.originalfilename,'.'))>
					  <cfset myIMG = "/img/icons/"&ListLast(qData.originalfilename,'.')&".png">	
				</cfif>	
					
				<cfset tmpStruct = {}>	
				<cfset tmpStruct["resolution"] = "">	
				<cfif isPreviewable(qData.id)>
					<cfset myIMG = href("instance:"&qData.id)&"&dimensions=100x66&cropmode=cropcenter">
					<cfif qData.height GT qData.width>
						<cfset tmpStruct["hei"] = 600>
						<cfset tmpStruct["wid"] = 395>	
						<cfset tmpStruct["bild"] = href("instance:"&qData.id)&"&dimensions=395x600&cropmode=cropcenter">	
					<cfelse>
						<cfset tmpStruct["hei"] = 495>
						<cfset tmpStruct["wid"] = 750>	
						<cfset tmpStruct["bild"] = href("instance:"&qData.id)&"&dimensions=750x495&cropmode=cropcenter">	
					</cfif>		
					<cfset tmpStruct["resolution"] = qData.width&" x "&qData.height>
				</cfif>		
				
				<cfset tmpStruct["recordid"] 	= qData.id>
				<cfset tmpStruct["vorschaubild"] = myIMG>
				<cfset tmpStruct["extension"] = "."&lcase(ListLast(qData.originalfilename,'.'))>
				<cfset tmpStruct["downloadlink"] = ListLast(qData.originalfilename,'.')>
				<cfset tmpStruct["createdwhen"] = qData.createdwhen>
				<cfset tmpStruct["titel"] 		= qData.bezeichnung>
				<cfset tmpStruct["beschreibung"] = qData.beschreibung>
				<cfset tmpStruct["previewable"] = isPreviewable(qData.id)>
				<cfset ArrayAppend(returnArray, tmpStruct)>
			</cfloop>
		</cfif>		
	</cfif> 
    <cfreturn returnArray>
</cffunction>						
<!--------------------------------------------------------------------------------->
<cffunction name="getKategorien" access="remote" returnFormat="json" output="no">
	
	<cfargument name="artist_fk" type="string" required="no" default="">
	<cfargument name="filterText" type="string" required="no" default="">
		
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>		
		
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				k.*
				<cfif arguments.artist_fk NEQ "">
				, rak.id rakid
				</cfif>
			FROM 
				kategorie k
				<cfif arguments.artist_fk NEQ "">
					LEFT JOIN r_artist_kategorie rak on k.id=rak.kategorie_fk and rak.artist_fk = '#arguments.artist_fk#'
				</cfif>
			WHERE
				1=1
				<cfif arguments.filterText NEQ "">
					AND k.name like '%#arguments.filterText#%'
				</cfif>
			ORDER BY 
				k.name
		</cfquery>
		
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.id>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset tmpStruct["checked"] = 1>
			<cfif arguments.artist_fk NEQ "" AND qData.rakid EQ "">	
				<cfset tmpStruct["checked"] = 0>
			</cfif>	
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>						
<!--------------------------------------------------------------------------------->
<cffunction name="getTyp" access="remote" returnFormat="json" output="no">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>		
		<cfset qData = getStructuredContent(nodetype=2105,orderclause="name")>
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.id>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>						
					
					
					
					
				
					
					
					
					
					
					
<!--------------------------------------------------------------------------------->
<!--- diese Funktion sucht nach Dokumenten --->
<!--------------------------------------------------------------------------------->
<cffunction name="getDokumente" access="remote" returnFormat="json" output="yes">
	
	<cfargument name="filterText" type="string" required="no" default="">
	<cfargument name="filterKategorie" type="string" required="no" default="">
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
	<cfset var result = structNew() >
	<cfset var sTagNamen = StructNew()>
	<cfset var sTagIDs = StructNew()>
	<cfset var sKategorieNamen = StructNew()>
	<cfset var sKategorieIDs = StructNew()>
	<cfset qTagDoks = QueryNew('dokument_fk')>	
	<cfset qKategorienDoks = QueryNew('dokument_fk')>	
	<cfset lSolrDoks = "">	
	
	<cfif isAuth()>
		
		<cfif arguments.filterKategorie NEQ "" AND !isNumeric(Replace(arguments.filterKategorie,",","","ALL"))>
			<cfreturn returnArray>
		</cfif>	
		
		<cfif LEN(arguments.filtertext) GT 2>	
			
			<cfset extraFields = StructNew()>
			<cfset extraFields['searchterm'] = arguments.filterText>
			<cfset extraFields['searchtype'] = "and">
			<cfinvoke component="modules.solr" method="searchDokumenteInternal" returnvariable="res">
				<cfinvokeargument name="extraArguments" value="#extraFields#">
			</cfinvoke>
			<cfif res.isAuthenticated AND StructKeyExists(res.suchergebnisse,'results')>
				<cfloop array="#res.suchergebnisse['results']#" index="cRes">
					<cfset lSolrDoks = ListAppend(lSolrDoks,cRes['id'])>
				</cfloop>	
				<cfset lSolrDoks = ListRemoveDuplicates(lSolrDoks)>		
			</cfif>	
					
			<cfquery name="qTagDoks" datasource="#getConfig('DSN')#">
				SELECT 
					rdt.dokument_fk
				FROM 
					tags t
					LEFT JOIN r_dokumente_tags rdt on t.id = rdt.tag_fk
				WHERE
					t.name like '%#arguments.filterText#%'
					AND rdt.dokument_fk is not null
				GROUP BY 
					rdt.dokument_fk
			</cfquery>
		</cfif>	

		<cfif arguments.filterKategorie NEQ "">
			<cfquery name="qKategorienDoks" datasource="#getConfig('DSN')#">
				SELECT distinct(dokument_fk) FROM r_dokumente_r_kategorien_subkategorien WHERE r_kategorien_subkategorien_fk IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" list="Yes" value="#arguments.filterKategorie#">)
			</cfquery>
		</cfif>		
			
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				d1.*, d2.titel parentdoctitle
			FROM 
				dokumente d1
				LEFT JOIN dokumente d2 on d1.parent_fk = d2.id
			WHERE
				1=1
				<cfif arguments.filterText NEQ "" OR qTagDoks.recordcount gt 0 OR lSolrDoks NEQ "">
					AND (1=2
					<cfif arguments.filterText NEQ "">
						OR d1.titel like '%#arguments.filterText#%'
					</cfif>	
					<cfif qTagDoks.recordcount gt 0>
						OR d1.id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" list="Yes" value="#ValueList(qTagDoks.dokument_fk)#">)
					</cfif>	
					<cfif lSolrDoks NEQ "">
						OR d1.id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" list="Yes" value="#lSolrDoks#">)
					</cfif>
					)
				</cfif>
				<cfif arguments.filterKategorie NEQ "">
					<cfif qKategorienDoks.recordcount GT 0>
						AND d1.id IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" list="Yes" value="#ValueList(qKategorienDoks.dokument_fk)#">)
					<cfelse>
						AND 1=2
					</cfif>
				</cfif>	
			ORDER BY 
				d1.titel
		</cfquery>
					
		<cfif qData.recordcount NEQ "">	
			<cfquery name="qKategorien" datasource="#getConfig('DSN')#">
				SELECT 
					rdrks.*, k.name kategorie, sk.name subkategorie
				FROM 
					r_dokumente_r_kategorien_subkategorien rdrks
					LEFT JOIN r_kategorien_subkategorien rks on rdrks.r_kategorien_subkategorien_fk = rks.id
					LEFT JOIN kategorien k on rks.kategorie_fk = k.id
					LEFT JOIN subkategorien sk on rks.subkategorie_fk = sk.id
				WHERE
					rdrks.dokument_fk IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" list="Yes" value="#ValueList(qData.id)#">)
				ORDER BY
				rdrks.dokument_fk
			</cfquery>
			<cfloop query="qKategorien">
				<cfif qKategorien['dokument_fk'][currentrow] NEQ qKategorien['dokument_fk'][currentrow-1]>
					<cfset sKategorieNamen[qKategorien.dokument_fk] = qKategorien.kategorie&" > "&qKategorien.subkategorie>
					<cfset sKategorieIDs[qKategorien.dokument_fk] = qKategorien.r_kategorien_subkategorien_fk>
				<cfelse>
					<cfset sKategorieNamen[qKategorien.dokument_fk] = sKategorieNamen[qKategorien.dokument_fk] & " <br>" &qKategorien.kategorie&" > "&qKategorien.subkategorie>
					<cfset sKategorieIDs[qKategorien.dokument_fk] = sKategorieIDs[qKategorien.dokument_fk] & ","&qKategorien.r_kategorien_subkategorien_fk>	
				</cfif>	
			</cfloop>	

			<cfquery name="qTags" datasource="#getConfig('DSN')#">
				SELECT 
					rdt.*, t.name
				FROM 
					r_dokumente_tags rdt
					LEFT JOIN tags t on rdt.tag_fk = t.id
				WHERE
					rdt.dokument_fk IN (<cfqueryparam cfsqltype="CF_SQL_VARCHAR" list="Yes" value="#ValueList(qData.id)#">)
				ORDER BY
					rdt.dokument_fk, t.name
			</cfquery>
				
			<cfloop query="qTags">
				<cfif qTags['dokument_fk'][currentrow] NEQ qTags['dokument_fk'][currentrow-1]>
					<cfset sTagNamen[qTags.dokument_fk] = qTags.name>
					<cfset sTagIDs[qTags.dokument_fk] = qTags.tag_fk>	
				<cfelse>
					<cfset sTagNamen[qTags.dokument_fk] =  sTagNamen[qTags.dokument_fk]&", "&qTags.name>
					<cfset sTagIDs[qTags.dokument_fk] = sTagIDs[qTags.dokument_fk]&","&qTags.tag_fk>
				</cfif>	
			</cfloop>

		</cfif>		
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] = qData.id>
			<cfset tmpStruct["titel"] = qData.titel>
			<cfset tmpStruct["parentdocument"] = qData.parentdoctitle>
			<cfset tmpStruct["start"] = qData.start>
			<cfset tmpStruct["stop"] = qData.stop>
			<cfset tmpStruct["archiv_ab"] = qData.archiv_ab>
			<cfset tmpStruct["createdwhen"] = qData.createdwhen>
			<cfset tmpStruct["filecreatedwhen"] = qData.filecreatedwhen>
			<cfset tmpStruct["changedwhen"] = qData.changedwhen>
			<cfset tmpStruct["version"] = qData.version>
			<cfset tmpStruct["public"] = qData.public>
			<cfset tmpStruct["loginrequired"] = qData.loginrequired>
			<cfset tmpStruct["upload"] = qData.upload>
			<cfset tmpStruct["kategorienamen"] = "">
			<cfset tmpStruct["kategorieids"] = "">
			<cfset tmpStruct["tagnamen"] = "">
			<cfset tmpStruct["tagids"] = "">
			<cfset tmpStruct["personen"] = qData.personen>
			<cfset tmpStruct["link"] = qData.link>
			<cfset tmpStruct["notiz"] = qData.notiz>
			<cfset tmpStruct["abstract"] = qData.abstract>
			<cfset tmpStruct["parent_fk"] = qData.parent_fk>
			<cfif StructKeyExists(sKategorieNamen,qData.id)>	
				<cfset tmpStruct["kategorienamen"] = sKategorieNamen[qData.id]>
			</cfif>	
			<cfif StructKeyExists(sKategorieIDs,qData.id)>	
				<cfset tmpStruct["kategorieids"] = sKategorieIDs[qData.id]>
			</cfif>
			<cfif StructKeyExists(sTagNamen,qData.id)>	
				<cfset tmpStruct["tagnamen"] = sTagNamen[qData.id]>
			</cfif>		
			<cfif StructKeyExists(sTagIDs,qData.id)>	
				<cfset tmpStruct["tagids"] = sTagIDs[qData.id]>
			</cfif>	
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
			
	</cfif>				

	<cfreturn returnArray>
    
</cffunction>

<!--------------------------------------------------------------------------------->
<cffunction name="getDokumenteParents" access="remote" returnFormat="json" output="no">
	
	<cfargument name="filterText" type="string" required="no" default="">
  
	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
	<cfset var result = structNew() >
	
		
	<cfif isAuth()>
		
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				d.id, d.titel
			FROM 
				dokumente d
			WHERE
				d.parent_fk is null
				AND d.titel like '%#arguments.filterText#%'
			ORDER BY 
				d.titel
		</cfquery>
		
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] = qData.id>
			<cfset tmpStruct["titel"] = qData.titel>
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
			
	</cfif>				

	<cfreturn returnArray>
    
</cffunction>

						
<!--------------------------------------------------------------------------------->
<cffunction name="getSubkategorien" access="remote" returnFormat="json" output="no">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>		
		<cfset qData = getStructuredContent(nodetype=2102,orderclause="name")>
		<cfloop query="qData">
			<cfset tmpStruct = {}>
			<cfset tmpStruct["recordid"] 	= qData.id>
			<cfset tmpStruct["name"] 	= qData.name>
			<cfset ArrayAppend(returnArray, tmpStruct)>
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>								
<!--------------------------------------------------------------------------------->
<!--- Funktion holt alle Kategorienbaum --->
<!--------------------------------------------------------------------------------->
<cffunction name="getRKategorienSubkategorien" access="remote" returnFormat="json" output="no">
	
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
   	
	<cfif isAuth()>	
		
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
			<cfif qData['kid'][currentrow] NEQ qData['kid'][currentrow-1]>
				
				<cfquery name="qSubData" dbtype="query">
					SELECT * FROM qData WHERE kid = '#qData.kid#' AND id  is not null
				</cfquery>	
				
				<cfset tmpStruct = {}>
				<cfset tmpStruct["recordid"] 	= qData.id>
				<cfset tmpStruct["editierbar"] 	= false>
				<cfset tmpStruct["parent_fk"] 	= null>	
				<cfset tmpStruct["kategorie_fk"] = qData.kid>
				<cfset tmpStruct["subkategorie_fk"] 	= qData.sid>
				<cfset tmpStruct["name"] 		= qData.kategorie>	
				<cfset tmpStruct["comboname"] 	= qData.kategorie>	
				<cfset tmpStruct["comboid"] 	= ValueList(qSubData.id)>
				<cfset tmpStruct["children"] 	= qSubData.recordcount>	
				<cfset tmpStruct["opened"] 		= true>	
				<cfset tmpStruct["optionstyle"]	= "font-weight: bold; border-bottom: 1px dotted ##e6e6e6; padding: 1px 6px;">	
				<cfset tmpStruct["subnames"]	= ValueList(qSubData.subkategorie)>	
				<cfset ArrayAppend(returnArray, tmpStruct)>
			
				<cfloop query="qSubData">
					<cfset tmpStruct = {}>
					<cfset tmpStruct["recordid"] 	= qSubData.id>
					<cfset tmpStruct["editierbar"] 	= true>
					<cfset tmpStruct["parent_fk"] 	= qSubData.kid>
					<cfset tmpStruct["subkategorie_fk"] 	= qSubData.sid>
					<cfset tmpStruct["name"] 	= qSubData.subkategorie>
					<cfset tmpStruct["comboname"] 	= qData.kategorie&" > "&qSubData.subkategorie>
					<cfset tmpStruct["comboid"] 	= qSubData.id>
					<cfset tmpStruct["opened"] 		= true>	
					<cfset tmpStruct["kategorieChecked"] = false>	
					<cfset tmpStruct["optionstyle"]	= "border-bottom: 1px dotted ##e6e6e6; padding: 1px 6px 1px 24px; background-image: url('/img/ul.png'); background-repeat: no-repeat; background-position: 10px 6px;">	
					<cfset ArrayAppend(returnArray, tmpStruct)>
				</cfloop>	
						
			</cfif>	
		</cfloop>
		
	</cfif> 
    <cfreturn returnArray>
    
</cffunction>	
						
<cffunction name="getTagsort" access="remote" returnFormat="json" output="no">
	<cfargument name="id" type="numeric" required="yes" default="0">
  	<cfset var returnArray = ArrayNew(1)>
	<cfset var tmpStruct = StructNew()>
	<cfset var cRow = 1>	
	<cfif isAuth()>	
		<cfquery name="qData" datasource="#getConfig('DSN')#">
			SELECT 
				t.id, t.name, ts.sortierung, if (ts.sortierung > 0,'1','2') as specialsort, ts.id recordid, rdrks.id rdrksid, rdt.id rdtid
			FROM 
				r_dokumente_r_kategorien_subkategorien rdrks
				LEFT JOIN r_dokumente_tags rdt on rdrks.dokument_fk = rdt.dokument_fk
				LEFT JOIN tags t on rdt.tag_fk = t.id
				LEFT JOIN tagsort ts on ts.tag_fk = t.id AND ts.r_kategorien_subkategorien_fk = '#arguments.id#'
			WHERE
				rdrks.r_kategorien_subkategorien_fk = '#arguments.id#'
				AND rdt.id is not null
			ORDER by specialsort,ts.sortierung, t.name
		</cfquery>
		
		<cfif qData.recordcount GT 0>
			<cfquery datasource="#getConfig('DSN')#">
				DELETE FROM tagsort WHERE r_kategorien_subkategorien_fk = '#arguments.id#' AND tag_fk NOT IN (#ListAppend(ListRemoveDuplicates(ValueList(qData.id)),0)#)
			</cfquery>
		</cfif>
		<cfloop query="qData">
			<cfif qData['id'][currentrow] NEQ qData['id'][currentrow-1]>
				<cfset tmpStruct = {}>
				<cfset tmpStruct["recordid"] = qData.recordid>	
				<cfif qData['sortierung'][currentrow] NEQ cRow>
					<cfif qData['sortierung'][currentrow] EQ "">
						<cfset saveData = StructNew()>
						<cfset saveData['r_kategorien_subkategorien_fk'] = arguments.id>
						<cfset saveData['tag_fk'] = qData.id>
						<cfset saveData['sortierung'] = cRow>
						<cfset save = saveStructuredContent(nodetype=2109,data=saveData)>
						<cfset tmpStruct["recordid"] = int(save.instanceid)>		
					<cfelse>	
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE tagsort SET sortierung = #cRow# WHERE tag_fk = #qData.id# AND r_kategorien_subkategorien_fk = '#arguments.id#'
						</cfquery>
					</cfif>	
				</cfif>	
				<cfset tmpStruct["name"] 	= qData.name>
				<cfset tmpStruct["sortierung"] 	= cRow>
				<cfset ArrayAppend(returnArray, tmpStruct)>
				<cfset cRow = cRow +1>
			</cfif>	
		</cfloop>
	</cfif> 
    <cfreturn returnArray>
</cffunction>					
<!--------------------------------------------------------------------------------->
</cfsilent>

</cfcomponent>