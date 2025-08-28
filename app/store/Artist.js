Ext.define('myapp.store.Artist', {
  extend: 'Ext.data.Store',
	autoLoad: true,
	storeId: 'Artist',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getArtists',
		reader: {
			type: 'json'
		}
	},
	
	listeners: {
		load: function(store, records, successful) {
			if (successful) {
				// apply client-side filter to hide deactivated entries
				store.filter('deactivated', 0);
			}
		}
	},

	
	fields: [{
		name: 'recordid'
	},{ 
		name: 'checked'	
	},{ 
		name: 'user_fk'	
	},{ 
		name: 'name'	
	},{ 
		name: 'vorname'	
	},{ 
		name: 'ansprechperson'	
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
		name: 'link'
	},{ 
		name: 'beschreibung'
	},{ 
		name: 'bilder'
	},{ 
		name: 'uploads'
	},{ 
		name: 'geprueft'
	},{
		name: 'deactivated'
	},{
		name: 'deactivatedwhen'
	}]
});