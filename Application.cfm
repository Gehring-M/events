<!--- Handle CORS FIRST before anything else --->
<cfset origin = "*">
<cfif StructKeyExists(CGI, "HTTP_ORIGIN")>
    <cfset origin = CGI.HTTP_ORIGIN>
</cfif>

<!--- Always set CORS headers for any origin --->
<cfheader name="Access-Control-Allow-Origin" value="#origin#">
<cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
<cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">
<cfheader name="Access-Control-Allow-Credentials" value="true">
<cfheader name="Access-Control-Max-Age" value="3600">

<!--- Handle OPTIONS preflight for all requests --->
<cfif UCase(CGI.REQUEST_METHOD) EQ "OPTIONS">
    <cfheader statuscode="200" statustext="OK">
    <cfabort>
</cfif>

<cfinclude template="ameisen/ameisenSetApplication.cfm">
<cfinclude template="ameisen/ameisenApplication.cfm">
<cfparam name="session['vaid']" type="numeric" default="0">
<cfparam name="session['aid']" type="numeric" default="0">
