Ext.define('myapp.store.Typ', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Typ',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	url: 'modules/common/retrieve.cfc?method=getTyp',
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