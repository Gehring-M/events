<cfcomponent>
<cfinclude template="/ameisen/functions.cfm" >
<cfinclude template="/modules/functions.cfm" >
<cfoutput>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="lockunlock" access="remote" returnFormat="json">
	<cfargument name="recordid" type="numeric" required="yes">
	<cfargument name="loginrequired" type="numeric" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfset myData = StructNew()>
		<cfset myData['loginrequired'] = arguments.loginrequired>
		<cfset saveAdmin = saveStructuredContent(nodetype=2104,instance=arguments.recordid,data=myData)>
		<cfset result["success"] = true>				
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="privatepublic" access="remote" returnFormat="json">
	<cfargument name="recordid" type="numeric" required="yes">
	<cfargument name="public" type="numeric" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfset myData = StructNew()>
		<cfset myData['public'] = arguments.public>
		<cfset saveAdmin = saveStructuredContent(nodetype=2104,instance=arguments.recordid,data=myData)>
		<cfset result["success"] = true>				
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="editKategorie" access="remote" returnFormat="json">
	<cfargument name="dokument_fk" type="numeric" required="yes">
	<cfargument name="kategorie_fk" type="numeric" required="yes">
	<cfargument name="status" type="boolean" required="yes">
		
	<cfset kategorieIsUniqe = true>	
		
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		
		<cfif arguments.status>
			<cfif 1 EQ 2>
				<cfquery datasource="#getConfig('DSN')#">
					DELETE FROM r_dokumente_r_kategorien_subkategorien WHERE dokument_fk = '#arguments.dokument_fk#'
				</cfquery>
			</cfif>
			<cfset myData = StructNew()>
			<cfset myData['dokument_fk'] = arguments.dokument_fk>
			<cfset myData['r_kategorien_subkategorien_fk'] = arguments.kategorie_fk>
			<cfset saveStructuredContent(nodetype=2105,data=myData)>
		<cfelse>
			<cfquery datasource="#getConfig('DSN')#">
				DELETE FROM r_dokumente_r_kategorien_subkategorien WHERE dokument_fk = '#arguments.dokument_fk#' AND r_kategorien_subkategorien_fk = '#arguments.kategorie_fk#'
			</cfquery>
		</cfif>
				
		<cfquery name="qKategorien" datasource="#getConfig('DSN')#">
			SELECT 
				rdrks.*, k.name kategorie, sk.name subkategorie
			FROM 
				r_dokumente_r_kategorien_subkategorien rdrks
				LEFT JOIN r_kategorien_subkategorien rks on rdrks.r_kategorien_subkategorien_fk = rks.id
				LEFT JOIN kategorien k on rks.kategorie_fk = k.id
				LEFT JOIN subkategorien sk on rks.subkategorie_fk = sk.id
			WHERE
				rdrks.dokument_fk = '#arguments.dokument_fk#'
		</cfquery>	
		
		<cfset kategorieNamen = "">
		<cfset kategorieIDs = "">
				
		<cfloop query="qKategorien">
			<cfset kategorieNamen = ListAppend(kategorieNamen,qKategorien.kategorie&' > '&qKategorien.subkategorie,'|')>
			<cfset kategorieIDs = ListAppend(kategorieIDs,qKategorien.r_kategorien_subkategorien_fk)>
		</cfloop>
		
		<cfset result["kategorieNamen"] = Replace(kategorieNamen,"|","<br>","ALL")>	
		<cfset result["kategorieIDs"] = kategorieIDs>	
				
		<cfset result["success"] = true>				
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="editTags" access="remote" returnFormat="json">
	<cfargument name="dokument_fk" type="numeric" required="yes">
	<cfargument name="tag_fk" type="numeric" required="yes">
	<cfargument name="status" type="boolean" required="yes">
		
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
			
		<cfif arguments.status>
			<cfset myData = StructNew()>
			<cfset myData['dokument_fk'] = arguments.dokument_fk>
			<cfset myData['tag_fk'] = arguments.tag_fk>
			<cfset saveStructuredContent(nodetype=2107,data=myData)>
		<cfelse>
			<cfquery datasource="#getConfig('DSN')#">
				DELETE FROM r_dokumente_tags WHERE dokument_fk = '#arguments.dokument_fk#' AND tag_fk = '#arguments.tag_fk#'
			</cfquery>
		</cfif>
				
		<cfquery name="qTags" datasource="#getConfig('DSN')#">
			SELECT 
				rdt.*, t.name
			FROM 
				r_dokumente_tags rdt
				LEFT JOIN tags t on rdt.tag_fk = t.id
			WHERE
				rdt.dokument_fk = '#arguments.dokument_fk#'
			ORDER BY
				rdt.dokument_fk, t.name
		</cfquery>		
		
		<cfset tagNamen = "">
		<cfset tagIDs = "">
			
		<cfloop query="qTags">
			<cfset tagNamen =  ListAppend(tagNamen,qTags.name)>
			<cfset tagIDs = ListAppend(tagIDs,qTags.tag_fk)>
		</cfloop>	
				
		<cfset result["tagNamen"] = Replace(tagNamen,",",", ","ALL")>	
		<cfset result["tagIDs"] = tagIDs>	
		<cfset result["success"] = true>				
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="updateSOLR" access="remote" returnFormat="json" output="no">
	<cfargument name="dokument_fk" required="yes" type="numeric">
	<cfset var result		= {}>
	<cfset result["success"] = true>
	<cfset update = updateSOLRIndex(arguments.dokument_fk)>	
	<cfif update NEQ "">
		<cfset result["success"] = false>
	</cfif>
	<cfreturn result>
</cffunction>		
</cfoutput>
</cfcomponent>