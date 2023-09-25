Ext.define('myapp.store.Kategorien', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Kategorien',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getKategorien',
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