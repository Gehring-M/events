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
<cffunction name="duplicateVeranstaltungSub" access="remote" returnFormat="json">
	<cfargument name="veranstaltung_fk" type="numeric" required="yes">
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfif isAuth()>
		<cfset myData = StructNew()>
		<cfset myData['veranstaltung_fk'] = arguments.veranstaltung_fk>
		<cfset todupe=getStructuredContent(nodetype=2102, instanceids=myData['veranstaltung_fk'])>
		<cfset to=QueryGetRow(todupe, 1)>
		<cfset StructDelete(to,"node_fk")>
		<cfset StructDelete(to,"id")>
		<cfset to["parent_fk"]=myData['veranstaltung_fk']>
		<cfset to["veranstaltung_fk"]="">
	<cfset save = saveStructuredContent(nodetype=2102,data=to)>

	<cfset to["node_fk"]=save.nodeid>
	<cfset to["id"]=save.nodeid>
		<cfset out = structNew()>
	<cfset typ=getStructuredContent(nodetype=2115, whereclause="veranstaltung_fk in (#myData['veranstaltung_fk']#)")>
	<cfif typ.recordCount gt 0>
		<cfset to["typ_fk"]=QueryGetRow(typ,1).typ_fk>
	<cfset out["typ_fk"]=QueryGetRow(typ,1).typ_fk>
	<cfelse>
		<cfset out["typ_fk"]=1>
		<cfset to["typ_fk"]=1>
</cfif>
<cfset out["veranstaltung_fk"]=myData['veranstaltung_fk']>
<cfset save = saveStructuredContent(nodetype=2115,data=out)>
	</cfif>
	<cfreturn to>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfsilent>
</cfcomponent>