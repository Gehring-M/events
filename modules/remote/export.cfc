<cfcomponent>
<cfinclude template="../functions.cfm" />
<cfinclude template="../../ameisen/functions.cfm" />
<cffunction  name="get" access="remote"  returnformat="JSON">
    <cfif isAdmin()>
    <cfset data=getStructuredContent(nodeType=2102, whereclause="veranstaltung.parent_fk is null AND veranstaltung.extern=1 AND visible=1")>
    <cfset outout=ArrayNew()>
    <cfloop query="data">
        <cfset out=structNew()>
        <cfset out["@type"]="Event">
        <cfset out["name"]=data.name>
        <cfset out["description"]=data.beschreibung>
        <cfset out["typicalAgeRange"]=data.kinder eq 1 ?"0-99":"18-99">
        <cfset out["startDate"]=data.von>
        <cfset out["endDate"]=data.bis>
        <cfset out["duration"]=(data.uhrzeitbis eq null OR data.uhrzeitvon eq null) ? null: timeFormat(createTimespan(0, 0, DateDiff("n",data.uhrzeitvon,data.uhrzeitbis),0))>
        <cfset out["isAccessibleForFree"]=data.preis eq "">
        <cfset out["url"]=data.link>
        <cfset out["location"]={"streetAddress":data.adresse, "@type": "PostalAddress","postalCode":data.plz, "adressRegion":"Tirol", "addressCountry": "AT", "addressLocality": data.ort}>
        <cfset out["inLanguage"]="Deutsch">
        <cfquery name="qArtist" datasource="#getConfig('DSN')#">
            SELECT * FROM artist a JOIN r_veranstaltung_artist r ON a.id=r.artist_fk WHERE r.veranstaltung_fk=#data.id#
        </cfquery>
        <cfset out["performer"]=qArtist.name>
        <cfquery name="qTag" datasource="#getConfig('DSN')#">
            SELECT * FROM tag a JOIN r_veranstaltung_tag r ON a.id=r.tag_fk WHERE r.veranstaltung_fk=#data.id#
        </cfquery>  
        <cfset out["keywords"]=ListToArray(valueList( qTag.name))>
        <cfquery name="qVeranstalter" datasource="#getConfig('DSN')#">
            SELECT * FROM veranstalter a JOIN r_veranstaltung_veranstalter r ON a.id=r.veranstalter_fk WHERE r.veranstaltung_fk=#data.id#
        </cfquery>  
        <cfset out["organizer"]=ListToArray(valueList( qVeranstalter.name))>
        <cfset out["image"]=getMediaArchiveUploadsFlat(data.id, "bilder", 2102).recordCount gt 0?QueryGetRow(getMediaArchiveUploadsFlat(data.id, "bilder", 2102),1).path:"">
        <cfset out["subEvent"]=_get(data.id)>
        <cfset arrayAppend(outout, out)>
    </cfloop>
    <cfreturn outout>
</cfif>
</cffunction>


<cffunction  name="_get"   returnformat="JSON">
    <cfargument  name="id">
    <cfif isAdmin()>
    <cfset data1=getStructuredContent(nodeType=2102, whereclause="veranstaltung.parent_fk = #id#")>
    <cfset outout1=ArrayNew()>
    <cfloop query="data1">
        <cfset out1=structNew()>
        <cfset out1["@type"]="Event">
        <cfset out1["name"]=data1.name>
        <cfset out1["description"]=data1.beschreibung>
        <cfset out1["typicalAgeRange"]=data1.kinder eq 1 ?"0-99":"18-99">
        <cfset out1["startDate"]=data1.von>
        <cfset out1["endDate"]=data1.bis>
        <cfset out1["duration"]=(data1.uhrzeitbis eq null OR data1.uhrzeitvon eq null) ? null: timeFormat(createTimespan(0, 0, DateDiff("n",data1.uhrzeitvon,data1.uhrzeitbis),0))>
        <cfset out1["isAccessibleForFree"]=data.preis eq "">
        <cfset out1["url"]=data1.link>
        <cfset out1["location"]={"streetAddress":data1.adresse, "@type": "PostalAddress","postalCode":data1.plz, "adressRegion":"Tirol", "addressCountry": "AT", "addressLocality": data1.ort}>
        <cfset out1["inLanguage"]="Deutsch">
        <cfquery name="qArtist1" datasource="#getConfig('DSN')#">
        SELECT * FROM artist a JOIN r_veranstaltung_artist r ON a.id=r.artist_fk WHERE r.veranstaltung_fk=#data1.id#
        </cfquery>
        <cfset out1["performer"]=qArtist1.name>
        <cfquery name="qTag" datasource="#getConfig('DSN')#">
            SELECT * FROM tag a JOIN r_veranstaltung_tag r ON a.id=r.tag_fk WHERE r.veranstaltung_fk=#data1.id#
        </cfquery>  
        <cfset out1["keywords"]=ListToArray(valueList( qTag.name))>
     
        <cfquery name="qVeranstalter" datasource="#getConfig('DSN')#">
            SELECT * FROM veranstalter a JOIN r_veranstaltung_veranstalter r ON a.id=r.veranstalter_fk WHERE r.veranstaltung_fk=#data1.id#
        </cfquery>  
        <cfset out1["organizer"]=ListToArray(valueList( qVeranstalter.name))> 
        <cfset out1["image"]=getMediaArchiveUploadsFlat(data1.id, "bilder", 2102).recordCount gt 0?QueryGetRow(getMediaArchiveUploadsFlat(data1.id, "bilder", 2102),1).path:"">
        <cfset arrayAppend(outout1, out1)>
    </cfloop>
    <cfreturn outout1>
</cfif>
</cffunction>
</cfcomponent>