component rest="true" restpath="/v1" {

    include "../../ameisen/functions.cfm";
    url['neverdebug'] = "yes";

    remote string function regiosz() httpmethod="get" {
        var qEvents = getStructuredContent(2102);
        var eventArray = [];
        var eventData = {};

        for (var qEventsRow in qEvents) {
            if (qEventsRow.visible eq 1) {
                var eventTags = [];
                var qVeranstaltungTag = getStructuredContent(nodetype=2116, whereclause="veranstaltung_fk = #qEventsRow.node_fk#");
                
                for (var qVeranstaltungTagRow in qVeranstaltungTag) {
                    var qTags = getStructuredContent(nodetype=2106, whereclause="id = #qVeranstaltungTagRow.tag_fk#");
                    arrayAppend(eventTags, qTags.pagetitle);
                }
                
                eventData = {};
                eventData['id'] = qEventsRow.id;
                eventData['parent_fk'] = qEventsRow.parent_fk;
                eventData['pagetitle'] = qEventsRow.pagetitle;
                eventData['beschreibung'] = qEventsRow.beschreibung;
                eventData['preis'] = qEventsRow.preis;
                eventData['link'] = qEventsRow.link;
                eventData['von'] = qEventsRow.von;
                eventData['bis'] = qEventsRow.bis;
                eventData['uhrzeitvon'] = qEventsRow.uhrzeitvon;
                eventData['uhrzeitbis'] = qEventsRow.uhrzeitbis;
                eventData['veranstaltungsort'] = qEventsRow.veranstaltungsort;
                eventData['ort'] = qEventsRow.ort;
                eventData['ortplz'] = qEventsRow.plz;
                eventData['adresse'] = qEventsRow.adresse;
                eventData['kinder'] = qEventsRow.kinder;
                eventData['tipp'] = qEventsRow.tipp;
                eventData['tags'] = arrayToList(eventTags, ',');
                
                arrayAppend(eventArray, eventData);
            }
        }

        var jsonString = serializeJSON(eventArray);
        return jsonString;
    }
}