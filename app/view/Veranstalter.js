Ext.define('myapp.view.Veranstalter', {
	extend: 'Ext.form.Panel',
	alias: 'widget.Veranstalter',
	layout: {
		type: 'border'
	},
	flex: 1,
	style: 'backgroundColor: #d1d1d1',

	initComponent: function(){
		var me = this,
		myController = myapp.app.getController('Common');
		Ext.applyIf(me, {
			items: [{
				xtype: 'grid',
				region: 'center',
				name:'veranstalter',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Veranstalter',
				store: 'Veranstalter',
				agShowDeleteButton: true,
				windowWidth:800,
				windowHeight:'',
				maxWindowHeight: 800,
				windowName:'veranstalter',
				text:'Veranstalter ändern',
				nodeType:2101,
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [
					{ text: 'Veranstalter',  dataIndex: 'name', flex: 1 },
					{ text: 'Adresse',  dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'PLZ',  dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Ort',  dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Telefon',  dataIndex: 'telefon', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Email',  dataIndex: 'email', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Web',  dataIndex: 'web', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
				],
				tools:[{
					xtype: 'textfield',
					labelSeparator: ' ',
					name:'gridFilter',
					width: 300,
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Suchbegriff hier eintragen ...',
					agSearchFields: 'name,adresse,email,web,ort',
					enableKeyEvents: true,
					listeners: {
						keyup: {
							fn: function(el,event) {
								if (event.getCharCode() == 13) {
									myController.onEnterSuchen(el);
								}
							}
						}
					}
				},{		
					xtype: 'button',
					text: 'X',
					width: 27,
					height: 24,
					name:'gridFilterReset',
					margin:'0 0 0 0',
					cls: 'btn-gray'
				},{		
					xtype: 'button',
					text: 'Neuen Veranstalter hinzufügen',
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:800,
					windowHeight:'',
					maxWindowHeight: 800,
					windowName:'veranstalter',
					nodeType:2101
				}]
			}]
		});
		me.callParent(arguments);
	}
});