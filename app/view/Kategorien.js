Ext.define('oegb.view.Kategorien', {
	extend: 'Ext.form.Panel',
	alias: 'widget.Kategorien',
	layout: {
		type: 'border'
	},
	flex: 1,
	style: 'backgroundColor: #d1d1d1',

	initComponent: function(){
		var me = this,
		myController = oegb.app.getController('Common');
		Ext.applyIf(me, {
			items: [{
				
				xtype: 'grid',
				region: 'west',
				name:'kategorien',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Kategorien',
				collapsible: true,
				store: 'Kategorien',
				agShowDeleteButton: true,
				windowWidth:500,
				windowHeight:'',
				maxWindowHeight: 400,
				windowName:'kategorie',
				text:'Kategorien ändern',
				nodeType:2101,
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [{
						text: 'Kategorien',  dataIndex: 'name',  flex: 1, menuDisabled: true, sortable: false,
						renderer: function(value,data,record) {
						//	data.tdCls ='tdRootTag';
							if (record.data.parent_fk != "") {
						//		data.tdCls ='tdSubTag';
								return value;
							} else {
								val = value;
								if (record.data.children > 0) val = val+' ('+record.data.children+')';
								return val;
							}
						}
					}
				],
				tools:[{
					xtype: 'button',
					text: 'Neue Kategorie hinzufügen',
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:400,
					windowHeight:'',
					maxWindowHeight: 400,
					windowName:'kategorie',
					nodeType:2101
				}],
			},{
				xtype: 'grid',
				region: 'center',
				name:'kategorien',
				specialname:'r_kategorien_subkategorien',
				flex: 2,
				split: true,
				autoScroll: true,
				title: 'Verknüpfung Kategorien zu Subkategorien',
				collapsible: false,
				store: 'RKategorienSubkategorien',
				agShowDeleteButton: true,
				windowWidth:500,
				windowHeight:'',
				maxWindowHeight: 400,
				windowName:'kategorie',
				text:'Kategorien ändern',
				agDoNotShowSaveButton: true,
				nodeType:2103,
				viewConfig: {
            		enableTextSelection: true,
					plugins: {
						ptype: 'gridviewdragdrop',
						dragText: 'Sortierung ändern'
					}
				},
				columns: [{
						text: 'Kategorien',  dataIndex: 'name',  flex: 1, menuDisabled: true, sortable: false,
						renderer: function(value,data,record) {
							data.tdCls ='tdRootTag';
							if (record.data.parent_fk != null) {
								data.tdCls ='tdSubTag';
								return value;
							} else {
								val = value;
								if (record.data.children > 0) val = val+' ('+record.data.children+')';
								return val;
							}
						}
					},{ 
						xtype: 'componentcolumn', 
						sortable: false,
						menuDisabled: true,
						width: 190,
						renderer: function(value,data,record) {
							if (record.data.parent_fk == null) {
								return {
									xtype: 'button',
									text: 'Subkategorie zuweisen',
									agRecord: record,
									windowWidth:400,
									windowHeight:'',
									maxWindowHeight: 400,
									windowName:'kategorienbaum',
									nodeType:2103
								};
							} else {
								return {
									xtype: 'button',
									text: 'Tag Sortierung festlegen',
									agRecord: record,
									cls: 'button-grey',
									name: 'setTagSort'
								};
							}
						}
					}
				],
				
				tools:[{
					xtype: 'displayfield',
					text: 'Neue Kategorie hinzufügen',
					height: 24,
					margin:'0 0 0 10',
					windowWidth:400,
					windowHeight:'',
					maxWindowHeight: 400,
					windowName:'kategorie',
					nodeType:2101
				}],
				
			},{
				xtype: 'grid',
				region: 'east',
				name:'tags',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Subkategorie',
				collapsible: true,
				store: 'Subkategorien',
				agShowDeleteButton: true,
				windowWidth:500,
				windowHeight:'',
				maxWindowHeight: 400,
				windowName:'kategorie',
				text:'Kategorien ändern',
				nodeType:2102,
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [{
						xtype:'checkcolumn', name:'checked', dataIndex: 'checked', width: 38,  menuDisabled:true, resizable: false, sortable: false, hidden: true
					},{ 
						text: 'Subkategorien',  dataIndex: 'name',  flex: 1, menuDisabled: true, sortable: false
					}
				],
				
				tools:[{
					xtype: 'button',
					text: 'Neue Subkategorie hinzufügen',
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:400,
					windowHeight:'',
					maxWindowHeight: 400,
					windowName:'subkategorie',
					nodeType:2102
				}]
				
				
			}]
		});
		me.callParent(arguments);
	}

});
