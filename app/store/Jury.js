Ext.define('myapp.store.Jury', {
  extend: 'Ext.data.Store',
	autoLoad: true,
	storeId: 'Jury',
	proxy: {
	type: 'ajax',
	timeout: 300000,
	pageParam: false, 
    startParam: false, 
    limitParam: false,
	noCache: true,
	
	url: 'modules/common/jury.cfc?method=fetchJuryMembers',
		reader: {
			type: 'json',
            root: 'jury_members'
		}
	},
	fields: [{
		name: 'id'
	},{ 
		name: 'name'
	},{ 
		name: 'last_name'
	},{ 
		name: 'email'
	},{ 
		name: 'description'
	},{ 
		name: 'status'
	}]
});