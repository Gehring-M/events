<!--- Handle CORS FIRST before anything else --->
<cfif StructKeyExists(CGI, "HTTP_ORIGIN")>
    <cfset var origin = CGI.HTTP_ORIGIN>
    <cfset var whiteOrigins = "https://kulturbezirk-test.agindo-services.info">
    
    <cfif ListFind(whiteOrigins, origin, ",") OR Find('.intern', origin) GT 0>
        <cfheader name="Access-Control-Allow-Origin" value="#origin#">
        <cfheader name="Access-Control-Allow-Methods" value="GET, POST, PUT, DELETE, OPTIONS">
        <cfheader name="Access-Control-Allow-Headers" value="Content-Type, Authorization, X-Requested-With, Accept">
        <cfheader name="Access-Control-Allow-Credentials" value="true">
        <cfheader name="Access-Control-Max-Age" value="3600">
        
        <cfif CGI.REQUEST_METHOD EQ "OPTIONS">
            <cfheader statuscode="200" statustext="OK">
            <cfabort>
        </cfif>
    </cfif>
</cfif>

<cfinclude template="ameisen/ameisenSetApplication.cfm">
<cfinclude template="ameisen/ameisenApplication.cfm">
<cfparam name="session['vaid']" type="numeric" default="0">
<cfparam name="session['aid']" type="numeric" default="0">
