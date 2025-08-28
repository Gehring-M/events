<cfcomponent>

    <cfinclude template="../functions.cfm" />
    <cfinclude template="../../ameisen/functions.cfm" />

    <cffunction name="newEventMail" access="remote" returnformat="json">
        <cfargument name="eventID" type="numeric" required="true">

        <cfif eventID NEQ 0>

            <cfquery name="newEvent" datasource="#getConfig('DSN')#">
                SELECT *, k.name AS kontaktName, k.mail AS kontaktMail
                FROM veranstaltung AS v
                JOIN r_veranstaltung_kontakt AS rvk 
                ON v.id = rvk.veranstaltung_fk
                JOIN kontakt AS k 
                ON rvk.kontakt_fk = k.id
                JOIN r_veranstaltung_region AS rvr 
                ON v.id = rvr.veranstaltung_fk
                JOIN region AS r 
                ON rvr.region_fk = r.id
                WHERE v.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#eventID#">; 
            </cfquery>

            <!--- show in email response --->
            <cfset object = {}>
            <cfset object['id'] = newEvent.id>
            <cfset object['parent_fk'] = newEvent.parent_fk>
            <cfset object['name'] = newEvent.name>
            <cfset object['von'] = newEvent.von>
            <cfset object['bis'] = newEvent.bis>
            <cfset object['uhrzeitvon'] = newEvent.uhrzeitvon>
            <cfset object['uhrzeitbis'] = newEvent.uhrzeitbis>
            <cfset object['ort_fk'] = newEvent.ort_fk>
            <cfset object['veranstaltungsort'] = newEvent.veranstaltungsort>
            <cfset object['adresse'] = newEvent.adresse>
            <cfset object['plz'] = newEvent.plz>
            <cfset object['ort'] = newEvent.ort>
            <cfset object['latitude'] = newEvent.latitude>
            <cfset object['longitude'] = newEvent.longitude>
            <cfset object['beschreibung'] = newEvent.beschreibung>
            <cfset object['preis'] = newEvent.preis>
            <cfset object['bilder'] = newEvent.bilder>
            <cfset object['link'] = newEvent.link>
            <cfset object['uploads'] = newEvent.uploads>
            <cfset object['kinder'] = newEvent.kinder>
            <cfset object['tipp'] = newEvent.tipp>
            <cfset object['visible'] = newEvent.visible>
            <cfset object['extern'] = newEvent.extern>
            <cfset object['duplicate_fk'] = newEvent.duplicate_fk>
            <cfset object['next'] = newEvent.next>
            <cfset object['remote_fk'] = newEvent.remote_fk>
            <cfset object['showteasertext'] = newEvent.showteasertext>
            <cfset object['deactivated'] = newEvent.deactivated>
            <cfset object['deactivatedwhen'] = newEvent.deactivatedwhen>


            <cfmail from="#getConfig('mail.from')#" to="#getConfig('mail.to.freigabe')#" bcc="markus.hasibeder@agindo.at" subject="[Regio Schwaz Kulturkalender] Neue Veranstaltung wurde online eingetragen." type="HTML">	
                Es wurde eine neue Veranstaltung mit dem Namen: <a href="https://events.agindo-services.info/">#newEvent.name# über das Formular eingetragen, bitte diese Veranstaltung prüfen.</a>

                <br>
                Kontaktdaten:
                <ul>
                    <li>Name: #newEvent.kontaktName#</li>
                    <li>Mail: #newEvent.kontaktMail#</li>
                </ul> 
                <br>

                
                <br>Formulardaten: <br>
                <cfdump var="#object#">
            </cfmail>
        <cfelse>
            <cfreturn { "success": false, "message": "eventID is required" }>
        </cfif>

    </cffunction>
</cfcomponent>
