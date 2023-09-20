<cfcomponent>
<cfinclude template="/ameisen/functions.cfm">
<cfinclude template="/modules/functions.cfm">	
<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="deleteRecord" access="remote" returnFormat="json">

	<cfargument name="records" required="yes" type="string">
    <cfargument name="nodeType" required="yes" type="numeric">
	
	<cfset var result		= {}>
    <cfset result["success"] = false>
	<cfset result["message"] = "Der Datensatz konnte nicht gelöscht werden.">
    
    <cfset allowed = true>
	
	<cfif isAuth()>	
	
        <cfif allowed>
			<cfif arguments.nodeType LT 2100>
				<cfif arguments.nodeType EQ 1>
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstaltung WHERE id = '#session['vaid']#'
					</cfquery>
					
					<cfif ListFind(qCheck.bilder,'#arguments.records#') GT 0>
					
	<!---				<cfcontent type="text/html" reset="yes">
					<cfdump var="#ListDeleteAt(qCheck.bilder,ListFind(qCheck.bilder,'#arguments.records#'))#">
					<cfdump var="#ListFind(qCheck.bilder,'#arguments.records#')#">
						<cfdump var="#qCheck#">
							<cfdump var="#arguments.records#">																				 
						
						
						<cfabort>--->
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE veranstaltung SET bilder = '#ListDeleteAt(qCheck.bilder,ListFind(qCheck.bilder,'#arguments.records#'))#' WHERE id = '#session['vaid']#'
						</cfquery>
					</cfif>		
				</cfif>	
				
				 <cfloop list="#arguments.records#" index="cRecord">
					<cfset deleteStructuredContent(cRecord)>
				</cfloop>
			<cfelse>
				 <cfloop list="#arguments.records#" index="cRecord">
					<cfset deleteFlatContent(nodetype=arguments.nodeType,instanceid=cRecord)>
				</cfloop>
			</cfif>	
				
            <cfset result["success"] = true>
            <cfset result["message"] = "Der Datensatz wurde erfolgreich gelöscht.">
        <cfelse>
            <cfset result["success"] = false>
        </cfif>
    </cfif>
	
   	<cfreturn result>
    
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
</cfsilent>
</cfcomponent>