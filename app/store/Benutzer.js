Ext.define('myapp.store.Benutzer', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Benutzer',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	
	url: 'modules/common/retrieve.cfc?method=getBenutzer',
		reader: {
			type: 'json'
		}
	},
	fields: [{
		name: 'recordid'
	},{ 	
		name: 'node_fk'
	},{ 
		name: 'vorname'
	},{ 
		name: 'nachname'
	},{ 
		name: 'email'
	},{ 
		name: 'beschreibung'
	},{ 
		name: 'genre'
	},{ 
		name: 'genre_display'
	},{ 
		name: 'bezirk'
	},{ 
		name: 'bezirk_display'
	},{ 
		name: 'status'
	}]
});