<cfinclude template="ameisen/ameisenSetApplication.cfm">
<cfinclude template="ameisen/ameisenApplication.cfm">
<cfcontent reset="yes" type="text/html; charset=utf-8">

<!----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SOLR: Suche
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- <cfparam name="Application['solr']" default="#StructNew()#"> --->

<cfset host = "#getConfig('solrHost')#" >
<cfset port = "#getConfig('solrPort')#" >

<cfif host neq "" AND (NOT StructKeyExists(Application,'solrJavaLoaded') OR Application['solrJavaLoaded'] neq true OR (StructKeyExists(url,'reset') AND url['reset'] eq true))>
	<cfset paths = arrayNew(1)>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/solr-solrj-4.0.0.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/commons-io-2.4.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/commons-codec-1.7.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/slf4j-api-1.5.6.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/slf4j-jdk14-1.5.6.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/jcl-over-slf4j-1.5.6.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/httpclient-4.2.1.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/httpcore-4.2.2.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/httpmime-4.2.1.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/stax-api-1.0.1.jar")>
	<cfset ArrayAppend(paths,ExpandPath('/') & "cfsolrlib/solrj-lib/wstx-asl-4.0.0.jar")>

	<cfset solrloader = createObject("component", "cfsolrlib.javaloader.JavaLoader").init(loadpaths=paths, loadColdFusionClassPath=true) >

	<cfset application.solrInstance = createObject("component","cfsolrlib.components.cfsolrlib") />
	<cfset application.solrInstance.init(	solrloader, host, port, "/solr/" & getConfig('solrCore') ) />


	<cfset tikapath = ArrayNew(1)>
	<cfset ArrayAppend(tikapath,ExpandPath('/') & "cfsolrlib/solrj-lib/tika-app-1.17.jar")>
	<cfset tikaloader = createObject("component", "cfsolrlib.javaloader.JavaLoader").init(loadpaths=tikapath, loadColdFusionClassPath=false) >
	<cfset application.tika = tikaloader.create("org.apache.tika.Tika").init() >
	
	<cfset application['solrJavaLoaded'] = true>
</cfif>


