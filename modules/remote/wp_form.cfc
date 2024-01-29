<cfcomponent>
    <cfinclude template="../functions.cfm" />
    <cfinclude template="../../ameisen/functions.cfm" />
    <cffunction  name="newVeranstaltung" access="remote"  returnformat="json">
        <cfset requestdata = GetHttpRequestData().headers />
        <cfset returnData = structNew()>
        <cfinclude template="../cors.cfm" />

        <cfset form["extern"]=2>
        <cfset form["visible"]=0>
        <cfset form["tipp"]=0>
        <cfset form["longitude"]=0>
        <cfset form["latitude"]=0>

        <cfset kid=Structnew()>
        
        <cfif structKeyExists(form,"kname") AND form["kname"] neq "" AND structKeyExists(form,"kmail") AND form["kmail"] neq "" AND structKeyExists(form,"accepted_dp") AND form["accepted_dp"] neq "" AND structKeyExists(form,"accepted_ds") AND form["accepted_ds"] neq "" AND  isCorrectEmail(form["kmail"])>
            <!---check if email already exists--->
            <cfset check = getStructuredContent(nodeType=2120)>
            <cfquery dbtype="query" name="kexists">
            SELECT * FROM check WHERE mail='#form["kmail"]#'
            </cfquery>
            <cfif kexists.recordCount gt 0>
                <cfset kid=QueryGetRow(kexists,1).node_fk>
            <cfelse>
                <cfset kid= saveStructuredContent(nodeType=2120, data={"name":form["kname"], "mail":form["kmail"], "accepted_dp":form["accepted_dp"], "accepted_ds":form["accepted_ds"] }).nodeid>
            </cfif>
        <cfelse>
        </cfif>
 
        <cfset region_fk="">
        <cfif structKeyExists(form,"region") AND form["region"] neq "">
            <cfset region_fk=form.region>
        </cfif>
        <cfset test = formatAndValidateStructuredFields(nodeType=2102, data=form)>
        <cfset id= saveStructuredContent(nodeType=2102, data=form)>
        <cfmail from="#getConfig('mail.from')#" to="#getConfig('mail.to.freigabe')#"  subject="Neue Veranstaltung wurde eingetragen." type="HTML">	
            Es wurde eine neue Veranstaltung mit dem Namen: <a href="https://events.agindo-services.info/">#form["name"]# über das Formular eingetragen, bitte diese Veranstaltung prüfen.</a>
        </cfmail>
        <cfif region_fk neq "">
            <cfset saveStructuredContent(nodeType=2117, data={"region_fk":region_fk, "veranstaltung_fk": id.nodeid})>
        </cfif>
    
        <cfset saveStructuredContent(nodeType=2121, data={"kontakt_fk":kid, "veranstaltung_fk": id.nodeid})>
        <cflocation url='https://www.regio-schwaz.tirol/kulturkalender/danke'>

    </cffunction>
</cfcomponent>