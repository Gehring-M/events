<!--- Handle CORS Headers --->
<!--- CORS is now handled in Application.cfm before request processing --->

<cftry>
  <cfinclude template="ameisen/ameisenOnRequestEnd.cfm">
  <cfcatch type="any">
		<cfif isGinny()>
			<cfrethrow>
		</cfif>
  </cfcatch>
</cftry>