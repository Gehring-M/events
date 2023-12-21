<cfcomponent>
    <cfinclude template="../functions.cfm" />
    <cfinclude template="../../ameisen/functions.cfm" />
    <cffunction  name="get" access="remote"  returnformat="JSON">
        <cfif isAdmin()>

            <cftry>
                <cfhttp url="http://regioschwaz.piwo.intern/modules/remote/export.cfc?method=get" method="post" result="res" >
                  <!---  <cfhttpparam type="header" name="X-Api-Key" value="#getConfig('nexyo.api-key')#" >--->
                </cfhttp>
                
                <cfcatch type="any" >
                    <cfdump var="#cfcatch#">
                    <cfabort>
                </cfcatch>
            </cftry>
            <cfif res.status_code neq "200" >
                <cfabort>
            </cfif>
            
        <cfset ndata = deserializeJSON(res.filecontent)>
       <cfset out = []>
        <cfloop array="#ndata#" item="item">
            <cfset data = structNew() >
            <cfset vdata = structNew() >
            <cfset vdata['name'] =  item.name>
            <cfset vdata['beschreibung'] = item.description >
            <cfset vdata["kinder"]=item.typicalAgeRange eq "0-99" ?1:0>
            <cfset vdata["von"]=ParseDateTime(item.startDate)>
            <cfset vdata["bis"]=item.endDate neq ""?ParseDateTime(item.endDate):"">
            <cfset vdata["preis"]=item.isAccessibleForFree ? 0:1>
            <cfset vdata["link"]=item.url>
            <cfset vdata["adresse"]=item.location.streetAddress>
            <cfset vdata["plz"]=item.location.postalCode>
            <cfset vdata["ort"]=item.location.addressLocality>
            <cfset vdata["bilder"]=item.image>
            <cfset vdata["extern"]=2>
            <cfset vdata["visible"]=1>
            <cfset data["veranstaltung"]=vdata>

            <cfset qError = formatAndValidateStructuredFields(nodetype=2102, instance=0, data=vdata) >

            <cfif qError.recordCount neq "0" >
            <cfabort>
            </cfif>
            <cfset id = exists(2102,vdata.name)>
            <cfif id>
                <cfset vdata["id"]=id>
            </cfif>
            <cfif item.performer neq "">
            <cfset adata = structNew() >
            <cfset adata["name"]=item.performer>
            <cfset qError = formatAndValidateStructuredFields(nodetype=2103, instance=0, data=adata) >
            <cfif qError.recordCount neq "0" >
                <cfabort>
            </cfif>
            <cfset data["artist"]=adata>
        </cfif>
        <cfif arrayToList(item.organizer) neq "">
            <cfset vvdata = structNew() >
            <cfset vvdata["name"]=arrayToList(item.organizer)>
            
                <cfset qError = formatAndValidateStructuredFields(nodetype=2101, instance=0, data=vvdata) >
                <cfif qError.recordCount neq "0" >
                    <cfabort>
                </cfif>
                <cfset data["veranstalter"]=vvdata>
            </cfif>



            <cfset arrayAppend(out, data)>
        </cfloop>


        
        
            <cfreturn out>
    </cfif>
    </cffunction>
    <cffunction  name="exists" access="private">
        <cfargument  name="type">
        <cfargument name ="name">
        <cfset e =getStructuredContent(nodetype=type , whereClause="name='#name#'")>
        <cfif e.recordCount eq 0>
            <cfreturn 0> 
        <cfelse>
            <cfreturn QueryGetRow(e,1).id>
        </cfif>
       
    </cffunction>
</cfcomponent>