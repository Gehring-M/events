Ext.define('myapp.store.Bilder', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Bilder',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getBilder',
		reader: {
			type: 'json'
		}
	},

	/**
	 * DEBUGGING
	 * 
	listeners: {
		load: function(store, records, successful) {
			console.log('LOAD BILDER STORE');
			console.log(records);
		},
		add: function(store, records, index) {
			console.log('Records added to Bilder store:', records);
		},
		remove: function(store, records, index, isMove) {
			console.log('Records removed from Bilder store:', records);
		},
		update: function(store, record, operation, modifiedFieldNames) {
			console.log('Record updated in Bilder store:', record);
		},
		clear: function(store) {
			console.log('Bilder store cleared');
		}
	},
	*/

	fields: [{
		name: 'recordid'
	},{
		name: 'name'
	},{
		name: 'createdwhen'
	},{
		name: 'titel'
	},{
		name: 'beschreibung'
	},{
		name: 'vorschaubild'
	},{
		name: 'previewable'
	},{
		name: 'bild'
	},{
		name: 'hei'
	},{
		name: 'wid'
	},{
		name: 'resolution'
	}]
});