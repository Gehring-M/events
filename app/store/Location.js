Ext.define('myapp.store.Location', {
    extend: 'Ext.data.Store',
      autoLoad: false,
      storeId: 'Location',
      proxy: {
      type: 'ajax',
      timeout: 300000,
      pageParam: false, 
      startParam: false, 
      limitParam: false,
      noCache: true,
      url: 'modules/common/retrieve.cfc?method=getLocations',
          reader: {
              type: 'json'
          }
      },
      
      fields: [{
          name: 'recordid'
      },{ 
          name: 'veranstaltungsort'
      },{ 
          name: 'adresse_display'
      },{ 
          name: 'adresse'
      },{ 
          name: 'plz'
      },{ 
          name: 'ort'
      },{ 
          name: 'latitude'
      },{ 
          name: 'longitude'
      }]
  });