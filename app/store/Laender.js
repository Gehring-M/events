Ext.define('oegb.store.Laender', {
  extend: 'Ext.data.Store',
	autoLoad: true,
	storeId: 'laender',
	proxy: {
	type: 'ajax',
	pageParam: false, 
	startParam: false, 
	limitParam: false,
	noCache: false,
	timeout: 300000,
	url: 'modules/common/retrieve.cfc?method=getLaender',
		reader: {
			type: 'json'
		}
	},
	fields: [
		{
			name: 'laenderkuerzel'
		},{ 
			name: 'name'
		}
	]
});



					
					