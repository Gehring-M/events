Ext.define('myapp.store.SubVeranstaltungen', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	remoteSort: false,
	remoteFilter: true,
	storeId: 'SubVeranstaltungen',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getVeranstaltungen',
		reader: {
			type: 'json'
		},
		filterParam: 'sub',
		encodeFilters: function(filters) {
            // Assuming filters[0] is the one you need to encode as 'sub'
			return filters[0].value;
		}
	},
	
	fields: [{
		name: 'recordid'
	},{ 
		name: 'opened'	
	},{ 	
		name: 'children'
	},{ 	
		name: 'name'
	},{ 
		name: 'parent_fk'	
	},{ 
		name: 'parent_name'	
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
		name: 'link'
	},{ 
		name: 'bilder'
	},{ 
		name: 'uploads'
	},{ 
		name: 'optionstyle'
	},{ 
		name: 'typ_fk'
	},{ 
		name: 'region_fk'
	},{ 
		name: 'region'
	},{ 
		name: 'tipp'
	},{ 
		name: 'kinder'
	},{ 
		name: 'visible'
	},{ 
		name: 'ev_always_active'
	},{ 
		name: 'extern'
	},{ 
		name: 'duplicate_fk'
	}]
});