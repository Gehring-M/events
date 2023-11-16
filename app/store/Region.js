Ext.define('myapp.store.Region', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Region',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getRegion',
		reader: {
			type: 'json'
		}
	},
	fields: [{
		name: 'recordid'
	},{
		name: 'name'
	}]
});