<cfcomponent>
    <cfinclude template="../functions.cfm" />
    <cfinclude template="../../ameisen/functions.cfm" />
    <cffunction  name="newVeranstaltung" access="remote"  returnformat="json">
        <cfset requestdata = GetHttpRequestData().headers />
        <cfset returnData = structNew()>
        <cfinclude template="../cors.cfm" />

        <cfset url["extern"]=2>
        <cfset url["visible"]=0>
        <cfset url["tipp"]=0>
        <cfset url["longitude"]=0>
        <cfset url["latitude"]=0>

        <cfset kid=Structnew()>
        <cfif structKeyExists(url,"kname") AND not url["kname"] eq "" AND structKeyExists(url,"kmail") AND not url["kmail"] eq "" AND structKeyExists(url,"accepted_dp") AND not url["accepted_dp"] eq "" AND structKeyExists(url,"accepted_ds") AND not url["accepted_ds"] eq "">
            <!---check if email already exists--->
            <cfset check = getStructuredContent(nodeType=2120, whereclause="mail='#url["kmail"]#'")>
            <cfif check.recordCount gt 0>
                <cfset kid=QueryGetRow(check,1)>
            <cfelse>
                <cfset kid= saveStructuredContent(nodeType=2120, data={"name":url["kname"], "mail":url["kmail"], "accepted_dp":url["accepted_dp"], "accepted_ds":url["accepted_ds"] })>
            </cfif>
            <cfelse>
                <cfreturn url>
    </cfif>
 
        <cfset region_fk="">
        <cfif structKeyExists(url,"region") AND not url["region"] eq "">
        <cfset region_fk=url.region>
        </cfif>
        <cfset test = formatAndValidateStructuredFields(nodeType=2102, data=url)>
        <cfset id= saveStructuredContent(nodeType=2102, data=url)>
        <cfmail from="#getConfig('mail.from')#" to="#getConfig('mail.to.freigabe')#"  subject="Neue Veranstaltung wurde eingetragen." type="HTML">	
            Es wurde eine neue Veranstaltung mit dem Namen: <a href="https://events.agindo-services.info/">#url["name"]# über das Formular eingetragen, bitte diese Veranstaltung prüfen.</a>
        </cfmail>
        <cfif region_fk neq "">
      <cfset saveStructuredContent(nodeType=2117, data={"region_fk":region_fk, "veranstaltung_fk": id.nodeid})>
        </cfif>
        <cfset saveStructuredContent(nodeType=2121, data={"kontakt_fk":kid.id, "veranstaltung_fk": id.nodeid})>
        <cflocation url='https://www.regio-schwaz.tirol/kulturkalender/'>

    </cffunction>
</cfcomponent>