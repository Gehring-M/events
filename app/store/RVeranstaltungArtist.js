Ext.define('myapp.store.RVeranstaltungArtist', {
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
		name: 'veranstaltung_fk'	
	},{ 
		name: 'artist_fk'	
	},{ 
		name: 'name'	
	},{ 
		name: 'uhrzeitvon',
		type: 'date'	
	},{ 
		name: 'uhrzeitbis',
		type: 'date'	
	},{ 
		name: 'ort_fk'
	},{ 
		name: 'veranstaltungsort'
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
	}]
});