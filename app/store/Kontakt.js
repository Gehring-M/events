Ext.define('myapp.store.Kontakt', {
    extend: 'Ext.data.Store',
    autoLoad: false,
    storeId: 'Kontakt',
    proxy: {
    type: 'ajax',
    timeout: 300000,
    pageParam: false, 
    startParam: false, 
    limitParam: false,
    noCache: true,
    url: 'modules/common/retrieve.cfc?method=getKontakts',
    reader: {
        type: 'json'
        }
    },
    fields: [{
        name: 'recordid'
    },{
        name: 'name'
    },{
        name: 'accepted_dp'
    },{
        name: 'accepted_ds'
    }]
});