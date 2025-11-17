<!--- Handle CORS Headers --->
<cfif StructKeyExists(CGI, "HTTP_ORIGIN")>
    <cfset var origin = CGI.HTTP_ORIGIN>
    <cfset var whiteOrigins = "https://kulturbezirk-test.agindo-services.info">
    
    <cfif ListFind(whiteOrigins, origin, ",") OR Find('.intern', origin) GT 0>
        <cfheader name="Access-Control-Allow-Origin" value="#origin#">
        <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">
        <cfheader name="Access-Control-Allow-Credentials" value="true">
    </cfif>
</cfif>

<cftry>
  <cfinclude template="ameisen/ameisenOnRequestEnd.cfm">
  <cfcatch type="any">
		<cfif isGinny()>
			<cfrethrow>
		</cfif>
  </cfcatch>
</cftry>