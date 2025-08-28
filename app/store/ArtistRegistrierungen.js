Ext.define('myapp.store.ArtistRegistrierungen', {
    extend: 'Ext.data.Store',
    storeId: 'ArtistRegistrierungen',
    autoLoad: false,
    proxy: {
        type: 'ajax',
        timeout: 300000,
        pageParam: false,
        startParam: false,
        limitParam: false,
        noCache: true,
        url: 'modules/common/retrieve.cfc?method=getArtistRegistrierungen',
        reader: {
            type: 'json'
        }
    },

    fields: 
    [
        {
            name: 'id'
        },{
            name: 'user_fk'
        },{
            name: 'name'
        },{
            name: 'ansprechperson'
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
            name: 'link'
        },{
            name: 'beschreibung'
        },{
            name: 'bilder'
        },{
            name: 'uploads'
        },{
            name: 'geprueft'
        },{
            name: 'vorname'
        },{
            name: 'approved'
        },{
            name: 'approvedwhen'
        },{
            name: 'createdwhen'
        }
    ]
});
