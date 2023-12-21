<cfcomponent>
    <cfinclude template="../functions.cfm" />
    <cfinclude template="../../ameisen/functions.cfm" />
    <cffunction  name="newVeranstaltung" access="remote"  returnformat="json">
        <cfset requestdata = GetHttpRequestData().headers />
        <cfinclude template="../cors.cfm" />
        <cfset form["extern"]=2>
        <cfset form["visible"]=0>
        <cfset form["tipp"]=0>
        <cfset form["longitude"]=0>
        <cfset form["latitude"]=0>
        <cfset region_fk="">
        <cfif structKeyExists(form,"region") AND not form["region"] eq "">
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
        <cflocation url='https://www.regio-schwaz.tirol/kulturkalender/'>

    </cffunction>
</cfcomponent>