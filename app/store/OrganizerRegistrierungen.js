Ext.define('myapp.store.OrganizerRegistrierungen', {
    extend: 'Ext.data.Store',
    storeId: 'OrganizerRegistrierungen',
    autoLoad: false,
    proxy: {
        type: 'ajax',
        timeout: 300000,
        pageParam: false,
        startParam: false,
        limitParam: false,
        noCache: true,
        url: 'modules/common/retrieve.cfc?method=getVeranstalterRegistrierungen',
        reader: {
            type: 'json'
        }
    },

    fields: 
    [
        {
            name: 'id'
        },{
            name: 'name'
        },{
            name: 'adresse'
        },{
            name: 'plz'
        },{
            name: 'ort'
        },{
            name: 'ort_fk'
        },{
            name: 'latitude'
        },{
            name: 'longitude'
        },{
            name: 'telefon'
        },{
            name: 'email'
        },{
            name: 'web'
        },{
            name: 'beschreibung'
        },{
            name: 'bilder'
        },{
            name: 'uploads'
        },{
            name: 'approved'
        },{
            name: 'approvedwhen'
        },{
            name: 'createdwhen'
        }
    ]
});
