<cfif isAdmin()>
<cfsilent>
	<head>
		<link href="../ameisen/amstyle.css" rel="stylesheet" type="text/css">
	</head>
</cfsilent>
<cfinclude template="../ameisen/gui/ameisen_html_head.cfm">
<cfset LoadStyleSheet("/ameisenPlugins/pluginstyles.css")>

<cfparam name="url['pluginmode']" default="uebersicht">
<cfset errormessages = ArrayNew(1)>
<cfset infomessages = ArrayNew(1)>
<cfset successmessages = ArrayNew(1)>

<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Überprüfungen diverser Eingaben, Speicher-Vorgänge, etc. - Meldungen in den entsprechenden Arrays hinzufügen.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!---
<cfset ArrayAppend(errormessages,"Das ist Fehlermeldung 1")>
<cfset ArrayAppend(infomessages,"Das ist Infomeldung 1")>
<cfset ArrayAppend(successmessages,"Das ist Successmeldung 1")>
--->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>

<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Beginn Ausgabe
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<div class="cmstable">
	<div class="cmstabledivhead">Navigation</div>
	<div class="cmstabledivcontent">
		<a href="#CGI.SCRIPT_NAME#" class="buttonline">Export</a>
		<a href="#CGI.SCRIPT_NAME#?pluginmode=import" class="buttonline">Import</a>

	</div>
</div>
<cfif ArrayLen(errormessages) OR ArrayLen(infomessages) OR ArrayLen(successmessages)>
	<div class="cmstable">
		<cfloop list="error,info,success" index="cMessagemode">
			<cfswitch expression="#cMessagemode#">
				<cfcase value="error"><cfset cMessageClass = "errorBox"></cfcase>
				<cfcase value="info"><cfset cMessageClass = "infoBoxImportant"></cfcase>
				<cfcase value="success"><cfset cMessageClass = "successBox"></cfcase>
			</cfswitch>
			<cfset cArray = Evaluate("#cMessagemode#messages")>
			<cfif ArrayLen(cArray)>
				<div class="#cMessageClass#">
					<cfloop from="1" to="#ArrayLen(cArray)#" index="cMessage">
						#cArray[cMessage]#<cfif cMessage neq ArrayLen(cArray)><br /></cfif>
					</cfloop>
				</div>
			</cfif>
		</cfloop>
	</div>
</cfif>
<cfswitch expression="#url['pluginmode']#">
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<cfcase value="uebersicht">
<div class="cmstable">
	<div class="cmstabledivhead">
		<button class="buttonline" onclick="window.open('http://#cgi.http_host#/modules/remote/export.cfc?method=get', '_blank')">Exportieren</button>
	</div>

</div>
</cfcase>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<cfcase value="import">
	<div class="cmstable">
		<div class="cmstabledivhead">
			<button class="buttonline" onclick="window.open('http://#cgi.http_host#/modules/remote/import.cfc?method=get', '_blank')">Importieren</button>
		</div>
	
	</div>
	</cfcase>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
</cfswitch>
</cfoutput>
</cfif>