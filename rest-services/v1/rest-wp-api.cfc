component rest="true" restpath="/v1" {

	include "../../ameisen/functions.cfm";
	url['neverdebug'] = "yes";

	remote function regiosz() httpmethod="get" {
		
		var heute = now();
		var whereclause = "1=1";
			whereclause = whereclause & " AND ( ";
			whereclause = whereclause & " von <= #heute# AND bis >= #heute# ";
			whereclause = whereclause & " OR ( von >= #heute# AND bis >= #heute# ) ";
			whereclause = whereclause & " OR ( von >= #heute# AND bis IS NULL ) ";
			whereclause = whereclause & " ) ";
		var qEvents = getStructuredContent(nodetype=2102, whereclause=#whereclause#, orderclause="von asc");
		
		var eventArray = [];
		var eventData = {};
		var eventTags = [];
		var qTags = queryNew('id');
		var qVeranstaltungTag = queryNew('id');
		var qParentEvent = queryNew('id');

		for (var qEventsRow in qEvents) {
			if (qEventsRow.visible eq 1) {
				eventTags = [];
				qVeranstaltungTag = getStructuredContent(nodetype=2115, whereclause="veranstaltung_fk = #qEventsRow.node_fk#");
				qParentEvent = getStructuredContent(nodetype=2102,nodeids=qEventsRow.parent_fk);

				for (var qVeranstaltungTagRow in qVeranstaltungTag) {
					qTags = getStructuredContent(nodetype=2105, whereclause="id = #qVeranstaltungTagRow.typ_fk#");
					arrayAppend(eventTags, qTags.pagetitle);
				}
				
				eventData = {};
				eventData['id'] = qEventsRow.id;
				eventData['parent_fk'] = qEventsRow.parent_fk;
				if (!isNull(qEventsRow.parent_fk)){
					eventData['parent_event'] = qParentEvent.name;
				}
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
				eventData['ev_always_active'] = qEventsRow.ev_always_active;
				eventData['visible'] = qEventsRow.visible;
				eventData['tipp'] = qEventsRow.tipp;
				eventData['typs'] = arrayToList(eventTags, ', ');
				
				arrayAppend(eventArray, eventData);
			}
		}
		return eventArray;
}	
}