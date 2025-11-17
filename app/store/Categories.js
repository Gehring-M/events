Ext.define('myapp.store.Categories', {
  extend: 'Ext.data.Store',
	autoLoad: false,
	storeId: 'Categories',
    /** 
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
    */

	fields: [{
		name: 'recordid'
	},{
		name: 'name'
	}]
})