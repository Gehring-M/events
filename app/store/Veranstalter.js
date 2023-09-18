Ext.define('oegb.store.Veranstalter', {
  extend: 'Ext.data.Store',
	autoLoad: true,
	storeId: 'Veranstalter',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getVeranstalter',
		reader: {
			type: 'json'
		}
	},
	
	fields: [{
		name: 'recordid'
	},{ 
		name: 'ort_fk'	
	},{ 
		name: 'name'	
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
		name: 'telefon'
	},{ 	
		name: 'email'
	},{ 
		name: 'web'
	},{ 
		name: 'beschreibung'
	}]
});