Ext.define('oegb.store.Artist', {
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
	
	fields: [{
		name: 'recordid'
	},{ 
		name: 'checked'	
	},{ 
		name: 'user_fk'	
	},{ 
		name: 'name'	
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
	}]
});