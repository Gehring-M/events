Ext.define('myapp.store.Veranstaltungen', {
  extend: 'Ext.data.Store',
	autoLoad: {
		params: {
			filterVon: Ext.Date.format(new Date(new Date().getFullYear(), (new Date().getMonth() - 6), 1), 'Y-m-d'),
			filterBis: Ext.Date.format(new Date(new Date().getFullYear(), 11, 31), 'Y-m-d')
		}
	},
	remoteSort: false,
	storeId: 'Veranstaltungen',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	groupField:"parent_fk",
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getVeranstaltungen',
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
		name: 'showteasertext'
	},{ 
		name: 'visible'
	},{ 
		name: 'next'
	},{ 
		name: 'extern'
	},{ 
		name: 'duplicate_fk'
	},{
		name: 'deactivated'
	},{
		name: 'deactivatedwhen'
	},{
		name: 'changed_by_kbsz'
	},{
		name: 'import_status'
	},{
		name: 'geodatenpool_id'
	}]
});