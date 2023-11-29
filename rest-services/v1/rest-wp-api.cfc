<cfcomponent rest="true" restpath="/v1">
    <cfinclude template="../../ameisen/functions.cfm">
    <cfset url['neverdebug'] = "yes">
    
    <cffunction name="regiosz" access="remote" returntype="string" httpMethod="get">
        <cfset qItems = getStructuredContent(2102)>
        <cfset jsonData = []>
        
        <cfloop query="qItems">
            <!--- hier muss ich einen Struct machen  und dan JSON erzeugen --->
            <cfset tempStruct = structNew()>
            <cfset tempStruct['id'] = qItems.id>
            <cfset tempStruct['pagetitle'] = qItems.pagetitle>
            <cfset tempStruct['beschreibung'] = qItems.beschreibung>
            <cfset tempStruct['preis'] = qItems.preis>
            <cfset tempStruct['link'] = qItems.link>
            <cfset tempStruct['von'] = qItems.von>
            <cfset tempStruct['bis'] = qItems.bis>
            <cfset tempStruct['uhrzeitvon'] = qItems.uhrzeitvon>
            <cfset tempStruct['uhrzeitbis'] = qItems.uhrzeitbis>
            <cfset tempStruct['veranstaltungsort'] = qItems.veranstaltungsort>
            <cfset tempStruct['ort'] = qItems.ort>
            <cfset tempStruct['ortplz'] = qItems.plz>
            <cfset tempStruct['adresse'] = qItems.adresse>
            <!--- Füge das Struct zum JSON-Array hinzu --->
            <cfset arrayAppend(jsonData, tempStruct)>
        </cfloop>
       
        <!--- Konvertiere das JSON-Array in einen JSON-String --->
        <cfset jsonString = serializeJSON(jsonData)>
        <cfreturn jsonString>
    </cffunction>
</cfcomponent>