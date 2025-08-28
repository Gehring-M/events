<cfcomponent>
<cfinclude template="/ameisen/functions.cfm">
<cfinclude template="/modules/functions.cfm">	
<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="deleteRecord" access="remote" returnFormat="json">

	<cfargument name="records" required="yes" type="string">
    <cfargument name="nodeType" required="yes" type="numeric">
	
	<cfset var result		 = {}>
    <cfset result["success"] = false>
	<cfset result["message"] = "Der Datensatz konnte nicht gelöscht werden.">
		
    <cfset allowed = true>

	<!--- check authentication --->
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
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstalter  WHERE id = '#session['vid']#'
					</cfquery>
					<cfif ListFind(qCheck.bilder,'#arguments.records#') GT 0>
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE veranstalter SET bilder = '#ListDeleteAt(qCheck.bilder,ListFind(qCheck.bilder,'#arguments.records#'))#' WHERE id = '#session['vid']#'
						</cfquery>
					</cfif>		
					<cfif ListFind(qCheck.uploads,'#arguments.records#') GT 0>
						<cfquery datasource="#getConfig('DSN')#">
							UPDATE veranstalter SET uploads = '#ListDeleteAt(qCheck.uploads,ListFind(qCheck.uploads,'#arguments.records#'))#' WHERE id = '#session['vid']#'
						</cfquery>
					</cfif>		
				</cfif>	
				<cfloop list="#arguments.records#" index="cRecord">
					<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstaltung WHERE FIND_IN_SET("#cRecord#",bilder) OR FIND_IN_SET("#cRecord#",uploads)
					</cfquery>
					<cfif qDelCheck.recordcount EQ 0>
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM artist WHERE FIND_IN_SET("#cRecord#",bilder) OR FIND_IN_SET("#cRecord#",uploads)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
								SELECT * FROM veranstalter WHERE FIND_IN_SET("#cRecord#",bilder) OR FIND_IN_SET("#cRecord#",uploads)
							</cfquery>
							<cfif qDelCheck.recordcount EQ 0>
								<cfset deleteStructuredContent(cRecord)>
							</cfif>	
						</cfif>	
					</cfif>	
				</cfloop>
			<cfelse>

				<!--- #############################
					  #   VERANSTALTUNG LÖSCHEN   #
					  ############################# --->

				<cfif arguments.nodeType EQ 2102>
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstaltung WHERE id IN ('#arguments.records#') OR parent_fk IN ('#arguments.records#') ORDER BY parent_fk desc
					</cfquery>
					<!--- Bilder einer Veranstaltung löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.bilder))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstaltung WHERE FIND_IN_SET("#cRecord#",bilder)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!--- Uploads einer Veranstaltung löschen --->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.uploads))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstaltung WHERE FIND_IN_SET("#cRecord#",uploads)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!--- Veranstaltung(en) löschen --->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.id))#" index="cRecord">
						<cfquery name="qDelEvent" datasource="#getConfig('DSN')#">
							UPDATE veranstaltung 
							SET 
								deactivated = 1,
								deactivatedwhen = CURRENT_TIMESTAMP
							WHERE 
								id = <cfqueryparam cfsqltype="cf_sql_integer" value="#cRecord#">;
						</cfquery>
					</cfloop>

				<!--- ############################
					  #   VERANSTALTER LÖSCHEN   #
					  ############################ --->

				<cfelseif arguments.nodeType EQ 2101>
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM veranstalter WHERE id IN ('#arguments.records#')
					</cfquery>
					<!--- Bilder eines Veranstalters löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.bilder))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstalter WHERE FIND_IN_SET("#cRecord#",bilder)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!--- Uploads eines Veranstalters löschen--->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.uploads))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM veranstalter WHERE FIND_IN_SET("#cRecord#",uploads)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!--- Veranstalter löschen --->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.id))#" index="cRecord">
						<cfquery name="qDelOrganizer" datasource="#getConfig('DSN')#">
							UPDATE veranstalter 
							SET 
								deactivated = 1,
								deactivatedwhen = CURRENT_TIMESTAMP
							WHERE 
								id = <cfqueryparam cfsqltype="cf_sql_integer" value="#cRecord#">;
						</cfquery>
					</cfloop>

				<!--- ########################
					  #   KÜNSTLER LÖSCHEN   #
					  ######################## --->

				<cfelseif arguments.nodeType EQ 2103>
					<cfquery name="qCheck" datasource="#getConfig('DSN')#">
						SELECT * FROM artist WHERE id IN ('#arguments.records#')
					</cfquery>
					<cflog file="delete-Record" text="Bilder: #qCheck.bilder#">
					<!--- Bilder eines Künstlers löschen --->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.bilder))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM artist WHERE FIND_IN_SET("#cRecord#", bilder)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!--- Uploads eines Künstlers löschen --->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.uploads))#" index="cRecord">
						<cfquery name="qDelCheck" datasource="#getConfig('DSN')#">
							SELECT * FROM artist WHERE FIND_IN_SET("#cRecord#", uploads)
						</cfquery>
						<cfif qDelCheck.recordcount EQ 0>
							<cfset deleteStructuredContent(cRecord)>
						</cfif>
					</cfloop>
					<!--- Künstler löschen --->
					<cfloop list="#ListRemoveDuplicates(ValueList(qCheck.id))#" index="cRecord">
						<cfquery name="qDelArtist" datasource="#getConfig('DSN')#">
							UPDATE artist 
							SET 
								deactivated = 1,
								deactivatedwhen = CURRENT_TIMESTAMP
							WHERE 
								id = <cfqueryparam cfsqltype="cf_sql_integer" value="#cRecord#">;
						</cfquery>
					</cfloop>

				<!--- ################
					  #   FALLBACK   #
					  ################ --->

				<cfelse>		
					<cfloop list="#arguments.records#" index="cRecord">
						<cfset deleteFlatContent(nodetype=arguments.nodeType,instanceid=cRecord)>
					</cfloop>
				</cfif>		

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