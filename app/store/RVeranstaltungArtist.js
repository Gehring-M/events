Ext.define('oegb.store.RVeranstaltungArtist', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'RVeranstaltungArtist',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getRVeranstaltungArtist',
		reader: {
			type: 'json'
		}
	},
	
	fields: [{
		name: 'recordid'
	},{ 
		name: 'parent_fk'	
	},{ 
		name: 'opened'	
	},{ 	
		name: 'children'
	},{ 	
		name: 'name'
	},{ 
		name: 'von',
		type: 'date'	
	},{ 
		name: 'bis',
		type: 'date'	
	},{ 
		name: 'uhrzeitvon',
		type: 'date'	
	},{ 
		name: 'uhrzeitbis',
		type: 'date'	
	},{ 
		name: 'veranstaltungsort'
	},{ 
		name: 'adresse_display'
	},{ 
		name: 'adresse'
	},{ 
		name: 'plz'
	},{ 
		name: 'ort'
	},{ 
		name: 'latitude'
	},{ 
		name: 'longitude'
	},{ 
		name: 'beschreibung'
	},{ 
		name: 'preis'
	},{ 
		name: 'optionstyle'
	}]
});