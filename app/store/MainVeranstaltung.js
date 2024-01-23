Ext.define('myapp.store.MainVeranstaltungen', {
    extend: 'Ext.data.Store',
      autoLoad: false,
      remoteSort: false,
      storeId: 'MainVeranstaltungen',
      proxy: {
      type: 'ajax',
      timeout: 300000,
      pageParam: false, 
      startParam: false, 
      limitParam: false,
      groupField:"parent_fk",
      noCache: true,
      filter: record=>record.get("parent_fk")===null,
      url: 'modules/common/retrieve.cfc?method=getVeranstaltungen',
          reader: {
              type: 'json'
          }
      },
      
      fields: [{
          name: 'recordid'
      },{ 	
          name: 'children'
      },{ 	
          name: 'name'
      },{ 
          name: 'parent_fk'	
      }]
  });