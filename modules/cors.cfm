<cfparam name="requestdata" type="struct" />
<cfset origin = "" />
<cfset whiteOrigins = "https://www.regio-schwaz.tirol" />

<cfif StructKeyExists(requestdata,'origin')>
    <cfset origin = requestdata['origin'] />
</cfif>

<cfif ListFind(whiteOrigins,origin,",") OR Find('.intern',origin)>
<cfheader name="Access-Control-Allow-Origin" value="#origin#" />
</cfif>


