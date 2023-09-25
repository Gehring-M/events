Ext.define('myapp.store.Downloads', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Downloads',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getDownloads',
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
		name: 'downloadlink'
	},{
		name: 'extension'
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