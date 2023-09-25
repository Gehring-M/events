Ext.define('myapp.store.Tags', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Tags',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=qTags',
		reader: {
			type: 'json'
		}
	},
	fields: [{
		name: 'recordid'
	},{
		name: 'name'
	},{
		name: 'checked'
	}]
});