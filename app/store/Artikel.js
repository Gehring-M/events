Ext.define('myapp.store.Artikel', {
    extend: 'Ext.data.Store',
    autoLoad: true,
    storeId: 'Artikel',
    proxy: {
        type: 'ajax',
        timeout: 300000,
        pageParam: false, 
        startParam: false, 
        limitParam: false,
        noCache: true,
        url: 'modules/common/retrieve.cfc?method=getArtikel',
        reader: {
            type: 'json'
        }
    },
    fields: [
        { name: 'recordid', type: 'int' },       // corresponds to <type>integer</type>
        { name: 'datum', type: 'date' },         // corresponds to <type>date</type>
        { name: 'titel', type: 'string' },       // corresponds to <type>textshort</type>
        { name: 'teaser', type: 'string' },      // corresponds to <type>image</type>
        { name: 'bilder', type: 'string' },        // corresponds to <type>image</type>
        { name: 'anriss', type: 'string' },      // corresponds to <type>textlong</type>
        { name: 'inhalt', type: 'string' },      // corresponds to <type>richtext</type>
        { name: 'tag_fk', type: 'auto' },  // corresponds to <type>genericelement</type>
        { name: 'link', type: 'string' }      ,  // corresponds to <type>textlong</type>
        { name: "start", type: "date",},
        { name: "stop", type: "date", },
    ]
});