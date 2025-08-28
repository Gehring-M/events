component rest="true" restpath="/events" {

	include "../../ameisen/functions.cfm";
	url['neverdebug'] = "yes";

	// Hole alle Events
	remote function getEvents(string id="", string category="", string from="", string to="", boolean showPast=false) httpmethod="get" returntype="array" returnformat="json" {
		var heute = now();
		var eventArray = [];
		var eventData = {};
		var eventTags = [];
		var imageIds = 0;
		var currentUrl = '';
		var qEvents = queryNew('id');
		var qEventsRow = queryNew('id');
		var qVeranstaltungTagRow = queryNew('id');
		var qTags = queryNew('id');
		var qVeranstaltungTag = queryNew('id');
		var qParentEvent = queryNew('id');
		var whereclause = "visible = 1";

		// Category-Filter hinzufügen, wenn vorhanden
		if (len(trim(arguments.category)) > 0) {
			var categoryQuery = getStructuredContent(
				nodetype=2105,
				whereclause="pagetitle = '#arguments.category#'",
				columns="id"
			);
			
			var categoryIds = valueList(categoryQuery.id);
			if (len(categoryIds) > 0) {
				whereclause = whereclause & " AND id IN (
					SELECT veranstaltung_fk FROM structcontent_2115 
					WHERE typ_fk IN (#categoryIds#)
				)";
			}
		}

		// ID-Filter hinzufügen, wenn vorhanden
		if (len(trim(arguments.id)) > 0) {
			whereclause = whereclause & " AND id = '#arguments.id#'";
		}

		// Datumsfilter hinzufügen, wenn vorhanden
		if (len(trim(arguments.from)) > 0 || len(trim(arguments.to)) > 0) {
			var fromDate = parseDateTime(arguments.from);
			var toDate = parseDateTime(arguments.to);
			whereclause = whereclause & " AND von >= #fromDate# AND von <= #toDate#";
		}

		qEvents = getStructuredContent(nodetype=2102, whereclause=whereclause, orderclause="von asc");

		for (qEventsRow in qEvents) {
			eventTags = [];
			imageIds = qEventsRow.bilder;
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
			eventData['plz'] = qEventsRow.plz;
			eventData['adresse'] = qEventsRow.adresse;
			eventData['kinder'] = qEventsRow.kinder;
			eventData['ev_always_active'] = qEventsRow.ev_always_active;
			eventData['visible'] = qEventsRow.visible;
			eventData['tipp'] = qEventsRow.tipp;
			if (len(trim(imageIds)) > 0) {
				var imageIdList = [];
				if (len(trim(imageIds)) > 0) {
					imageIdList = listToArray(imageIds, ",");
				}
				for (i = 1; i <= arrayLen(imageIdList); i++) {
					currentUrl = getPreview(parseId(imageIdList[i]),getConfig('remote.bilder'),'keepratio');
					fullUrl = isSSL('string') & "://" & cgi.HTTP_HOST & currentUrl;
					if (i == 1) {
						eventData["bilder"] = fullUrl;
					} else {
						eventData["bilder"] = listAppend(eventData["bilder"], fullUrl);
					}
				}
			}
			eventData['typs'] = arrayToList(eventTags, ', ');
			
			arrayAppend(eventArray, eventData);
		}
		
		// Convert dates to ISO format for JSON
		for (var i = 1; i <= arrayLen(eventArray); i++) {
			if (isDate(eventArray[i].von)) {
				eventArray[i].von = dateFormat(eventArray[i].von, "yyyy-mm-dd");
				eventArray[i].vonDisplay = dateFormat(eventArray[i].von, "dd.mm.yyyy");
			}
			if (isDate(eventArray[i].bis)) {
				eventArray[i].bis = dateFormat(eventArray[i].bis, "yyyy-mm-dd");
				eventArray[i].bisDisplay = dateFormat(eventArray[i].bis, "dd.mm.yyyy");
			}
		}
		
		return eventArray;
	}
}