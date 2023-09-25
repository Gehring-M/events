Ext.define('myapp.store.RVeranstaltungVeranstalter', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'RVeranstaltungVeranstalter',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getRVeranstaltungVeranstalter',
		reader: {
			type: 'json'
		}
	},
	
	fields: [{
		name: 'recordid'
	},{ 	
		name: 'name'
	},{ 	
		name: 'veranstalter_fk'
	},{ 	
		name: 'veranstaltung_fk'
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
		name: 'telefon'
	},{ 
		name: 'email'
	},{ 
		name: 'web'
	}]
});