<cfif svnExists()>
	<cfinclude template="ameisen/edithandler/svnWarning.cfm">
	<cfelse>
	<cflocation addtoken="no" url="/page.cfm?vpath=verwaltungsclient">
</cfif>