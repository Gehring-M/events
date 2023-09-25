<cfcomponent>
<cfinclude template="/ameisen/functions.cfm" >
<cfinclude template="/modules/functions.cfm" >
<cfoutput>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->

<cffunction name="editTags" access="remote" returnFormat="json">
	<cfargument name="veranstaltung_fk" type="numeric" required="yes">
	<cfargument name="tag_fk" type="numeric" required="yes">
	<cfargument name="status" type="boolean" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfif arguments.status>
			<cfset myData = StructNew()>
			<cfset myData['veranstaltung_fk'] = arguments.veranstaltung_fk>
			<cfset myData['tag_fk'] = arguments.tag_fk>
			<cfset saveStructuredContent(nodetype=2116,data=myData)>
		<cfelse>
			<cfquery datasource="#getConfig('DSN')#">
				DELETE FROM r_veranstaltung_tag WHERE veranstaltung_fk = '#arguments.veranstaltung_fk#' AND tag_fk = '#arguments.tag_fk#'
			</cfquery>
		</cfif>
		<cfset result["success"] = true>				
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="setSession" access="remote" returnFormat="json">
	<cfargument name="typ" type="string" required="yes">
	<cfargument name="id" type="numeric" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = true>
	<cfif isAuth()>
		<cfif !StructKeyExists(session,arguments.typ)>
			<cfset session[arguments.typ] = 0>
		</cfif>	
		<cfset session[arguments.typ] = arguments.id>	
	</cfif>
	<cfreturn result>
</cffunction>	
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="checkNewData" access="remote" returnFormat="json">
	<cfargument name="veranstaltung_fk" type="numeric" required="yes">
	<cfargument name="fieldname" type="string" required="yes">
	<cfargument name="existing" type="string" required="no" default="">
	<cfset var result		= {}>
    <cfset result["reload"] = false>
	<cfif isAuth()>
		<cfquery name="qCheck" datasource="#getConfig('DSN')#">
			SELECT * FROM veranstaltung WHERE id = '#arguments.veranstaltung_fk#'
		</cfquery>
		<cfif ListLen(arguments.existing) NEQ ListLen(qCheck['#arguments.fieldname#'])>
			 <cfset result["reload"] = true>
		</cfif>	
	</cfif>
	<cfreturn result>
</cffunction>	
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
		
<cffunction name="editKategorie" access="remote" returnFormat="json">
	<cfargument name="artist_fk" type="numeric" required="yes">
	<cfargument name="kategorie_fk" type="numeric" required="yes">
	<cfargument name="status" type="boolean" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfif arguments.status>
			<cfset myData = StructNew()>
			<cfset myData['artist_fk'] = arguments.artist_fk>
			<cfset myData['kategorie_fk'] = arguments.kategorie_fk>
			<cfset saveStructuredContent(nodetype=2114,data=myData)>
		<cfelse>
			<cfquery datasource="#getConfig('DSN')#">
				DELETE FROM r_artist_kategorie WHERE artist_fk = '#arguments.artist_fk#' AND kategorie_fk = '#arguments.kategorie_fk#'
			</cfquery>
		</cfif>
		<cfset result["success"] = true>				
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfoutput>
</cfcomponent>