<cftry>
  <cfinclude template="ameisen/ameisenOnRequestEnd.cfm">
  <cfcatch type="any">
		<cfif isGinny()>
			<cfrethrow>
		</cfif>
  </cfcatch>
</cftry>