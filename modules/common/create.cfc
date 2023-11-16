<cfcomponent>
<cfinclude template="/ameisen/functions.cfm">
<cfinclude template="/modules/functions.cfm">
<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="addVeranstalterToVeranstaltung" access="remote" returnFormat="json">
	<cfargument name="veranstaltung_fk" type="numeric" required="yes">
	<cfargument name="veranstalter_fk" type="numeric" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfset myData = StructNew()>
		<cfset myData['veranstaltung_fk'] = arguments.veranstaltung_fk>
		<cfset myData['veranstalter_fk'] = arguments.veranstalter_fk>
		<cfset save = saveStructuredContent(nodetype=2111,data=myData)>
		<cfset result["success"] = true>
		<cfset result["recordid"] = save['instanceid']>
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="addArtistToVeranstaltung" access="remote" returnFormat="json">
	<cfargument name="veranstaltung_fk" type="numeric" required="yes">
	<cfargument name="artist_fk" type="numeric" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfset myData = StructNew()>
		<cfset myData['veranstaltung_fk'] = arguments.veranstaltung_fk>
		<cfset myData['artist_fk'] = arguments.artist_fk>
		<cfset myData['longitude'] = 0.0000000000>
		<cfset myData['latitude'] = 0.0000000000>
		<cfset save = saveStructuredContent(nodetype=2110,data=myData)>
		<cfset result["success"] = true>	
		<cfset result["recordid"] = save['instanceid']>
	</cfif>
	<cfreturn result>
</cffunction>
<cffunction name="addRegionToVeranstaltung" access="remote" returnFormat="json">
	<cfargument name="veranstaltung_fk" type="numeric" required="yes">
	<cfargument name="region_fk" type="numeric" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfset myData = StructNew()>
		<cfset myData['veranstaltung_fk'] = arguments.veranstaltung_fk>
		<cfset myData['region_fk'] = arguments.region_fk>
		<cfset myData['longitude'] = 0.0000000000>
		<cfset myData['latitude'] = 0.0000000000>
		<cfset save = saveStructuredContent(nodetype=2118,data=myData)>
		<cfset result["success"] = true>	
		<cfset result["recordid"] = save['instanceid']>
	</cfif>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfsilent>
</cfcomponent>