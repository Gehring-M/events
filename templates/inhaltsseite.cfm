<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<cfsilent>
	<cfimport prefix="am" taglib="../ameisen/tags/util">
	<cfimport prefix="am" taglib="../ameisen/tags/lcontent">
</cfsilent>
<cfoutput>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
		<title>#getPageTitle()#</title>
		<meta name="description" content="#getInstanceText('metadescription')#" />
		<meta name="keywords" content="#getInstanceText('metakeywords')#" />
		<meta name="author" content="agindo interaktives marketing">
		<link href="/css/style.css" rel="stylesheet" type="text/css">
		<!---
		<cfset loadJavascript("/ameisen/js/mootools_core.js")>
		<cfset loadJavascript("/ameisen/js/mootools_more.js")>
		--->
	</head>
	
	<body>
		
		<am:text field="inhalt" />
		
	</body>
</cfoutput>
</html>
