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
        url: 'modules/kb/artists.cfc?method=fetchArtistsPublic',
        reader: {
            type: 'json',
            root: 'artists'
        }
    },

    fields: 
    [
        {
            name: 'artist_id',
            type: 'int'
        },{
            name: 'user_id',
            type: 'int'
        },{
            name: 'name',
            type: 'string'
        },{
            name: 'description',
            type: 'string'
        },{
            name: 'approved',
            type: 'int'
        },{
            name: 'rejected',
            type: 'int'
        },{
            name: 'need_action',
            type: 'int'
        }
    ]
});
