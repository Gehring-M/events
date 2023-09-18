Ext.define('oegb.store.Auth', {
	extend: 'Ext.data.Store',
	storeId: 'SystemInfo',
	proxy: {
		type: 'ajax',
		timeout: 300000,
		actionMethods: {
			create : 'POST',
			read   : 'POST',
			update : 'POST',
			destroy: 'POST'
		},
		url: 'modules/common/retrieve.cfc?method=getAuthStatus',
		reader: {
			type: 'json',
			root: 'userinformation'
		}
	},
	fields: [
		{
			name:'isauth'
		},{
			name:'administrator'
		},{
			name:'username'
		},{
			name:'displayname'
		},{
			name:'ameisen'
		},{
			name:'controller'
		},{
			name:'handler'
		},{
			name:'vorname'
		},{
			name:'nachname'
		},{
			name:'allowedSites'
		},{
			name:'user_fk'
		},{
			name:'mygroups'
		}
	]
});