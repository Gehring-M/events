component rest="true" restpath="/v1" {

	include "../../ameisen/functions.cfm";
	url['neverdebug'] = "yes";

	remote function regiosz() httpmethod="get" {
		
		var heute = now();
		var heuteJahr = createDateTime(year(heute), 1, 1, 0, 0, 0);
		var eventArray = [];
		var eventData = {};
		var eventTags = [];
		var imageUrl = '';
		var qEvents = queryNew('id');
		var qEventsRow = queryNew('id');
		var qVeranstaltungTagRow = queryNew('id');
		var qTags = queryNew('id');
		var qVeranstaltungTag = queryNew('id');
		var qParentEvent = queryNew('id');
		var whereclause = "visible = 1";
			whereclause = whereclause & " AND ( ";
			whereclause = whereclause & " von <= #heuteJahr# AND bis >= #heuteJahr# ";
			whereclause = whereclause & " OR ( von >= #heuteJahr# AND bis >= #heuteJahr# ) ";
			whereclause = whereclause & " OR ( von >= #heuteJahr# AND bis IS NULL ) ";
			whereclause = whereclause & " OR ( ev_always_active = 1 ) ";
			whereclause = whereclause & " ) ";
			qEvents = getStructuredContent(nodetype=2102,whereclause=#whereclause#,orderclause="von asc");

		for (qEventsRow in qEvents) {
			eventTags = [];
			imageUrl = val(qEventsRow.bilder);
			qVeranstaltungTag = getStructuredContent(nodetype=2115, whereclause="veranstaltung_fk = #qEventsRow.node_fk#");
			qParentEvent = getStructuredContent(nodetype=2102,nodeids=qEventsRow.parent_fk);

			for (qVeranstaltungTagRow in qVeranstaltungTag) {
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
			if ( imageUrl != 0 ) {
				eventData['bilder'] = '#isSSL('string')#://#cgi.HTTP_HOST##getpageurl(imageUrl)#';
			}
			eventData['typs'] = arrayToList(eventTags, ', ');
			
			arrayAppend(eventArray, eventData);
		}
		return eventArray;
	}	
}