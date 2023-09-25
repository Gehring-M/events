Ext.define('myapp.store.MainMenu', {
  extend: 'Ext.data.Store',
	//autoLoad: true,
	autoLoad: false,
	storeId: 'MainMenu',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	url: 'modules/common/retrieve.cfc?method=getMainMenu',
		reader: {
			type: 'json',
			root: 'menuitems'
		}
	},
	fields: [
		{
			name: 'pagetitle'
		},
		{
			name: 'handler'
		},
		{
			name: 'controller'
		},
		{
			name: 'submenuitems'
		},
		{
			name: 'node_fk'
		}
	 ]
});