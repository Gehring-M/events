Ext.define('myapp.store.RVeranstaltungKontakt', {
    extend: 'Ext.data.Store',
      autoLoad: false,
      storeId: 'RVeranstaltungKontakt',
      proxy: {
      type: 'ajax',
      timeout: 300000,
      pageParam: false, 
      startParam: false, 
      limitParam: false,
      noCache: true,
      url: 'modules/common/retrieve.cfc?method=RVeranstaltungKontakt',
          reader: {
              type: 'json'
          }
      },
      
      fields: [{
          name: 'recordid'
      },{ 
          name: 'veranstaltung_fk'	
      },{ 
          name: 'kontakt_fk'	
      },{ 
          name: 'name'	
      },{ 
        name: 'mail'	
    },{ 
          name: 'accepted_dp',
      },{ 
        name: 'accepted_ds',
      }]
  });