<!--- Abwärtskompatibilität --->
<cfif StructKeyExists(form,'user')>
	<cfset form['username'] = form['user']>
</cfif>
<cfif StructKeyExists(form,'pass')>
	<cfset form['password'] = form['pass']>
</cfif>
<cfif StructKeyExists(form,'file') AND StructKeyExists(form,'username') AND StructKeyExists(form,'password')>
	<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	Authentifizierung:
	------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfset authStruct = authenticate(form['username'],form['password'],'page')>
	<cfif authStruct.authenticated>
		<!--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
		Fallback: in die erste verfügbare MA-Kategorie hochladen.
		--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
		<cfset qCategories = getStructuredContent(nodetype=1201,parentIds=0,maxrows=1)>
		<cfif qCategories.recordcount eq 1>
			<cfset infoStruct = uploadIntoMediaArchive("file",1301,qCategories.node_fk,"automatisch")>
			<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			Pagetitle soll wie der Dateiname sein!
			------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
			<cfset dataStruct = StructNew()>
			<cfset dataStruct['pagetitle'] = getStructuredInstance(infoStruct['instanceid']).originalfilename>
			<cfset pagetitleInfoStruct = saveStructuredContent(instance=infoStruct['instanceid'],data=dataStruct)>
			<!----------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
			<cfoutput>#infoStruct['instanceid']#</cfoutput>
		<cfelse>
			ERROR: no media archive category found!
		</cfif>
	<cfelse>
		<cfheader statuscode="403" statustext="ERROR: invalid login data.">
		ERROR: Login failed.
	</cfif>
<cfelse>
	<cfheader statuscode="401" statustext="ERROR: missing login data.">
	ERROR: missing login data.
</cfif>