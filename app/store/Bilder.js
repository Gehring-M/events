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