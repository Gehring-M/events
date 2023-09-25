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
				<cfif arguments.nodeType LTE 2>
					
					
					
					
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstaltung WHERE id = '#session['vaid']#'
					</cfquery>
					<cfif ListFind(qCheck.bilder,'#arguments.records#') GT 0>
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE veranstaltung SET bilder = '#ListDeleteAt(qCheck.bilder,ListFind(qCheck.bilder,'#arguments.records#'))#' WHERE id = '#session['vaid']#'
						</cfquery>
					</cfif>		
					<cfif ListFind(qCheck.uploads,'#arguments.records#') GT 0>
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE veranstaltung SET uploads = '#ListDeleteAt(qCheck.uploads,ListFind(qCheck.uploads,'#arguments.records#'))#' WHERE id = '#session['vaid']#'
						</cfquery>
					</cfif>		
					
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM artist WHERE id = '#session['aid']#'
					</cfquery>
					<cfif ListFind(qCheck.bilder,'#arguments.records#') GT 0>
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE artist SET bilder = '#ListDeleteAt(qCheck.bilder,ListFind(qCheck.bilder,'#arguments.records#'))#' WHERE id = '#session['aid']#'
						</cfquery>
					</cfif>		
					<cfif ListFind(qCheck.uploads,'#arguments.records#') GT 0>
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE artist SET uploads = '#ListDeleteAt(qCheck.uploads,ListFind(qCheck.uploads,'#arguments.records#'))#' WHERE id = '#session['aid']#'
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