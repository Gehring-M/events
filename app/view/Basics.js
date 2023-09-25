Ext.define('myapp.view.Basics', {
	extend: 'Ext.form.Panel',
	alias: 'widget.Basics',
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
				region: 'west',
				name:'tags',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Tags',
				store: 'Tags',
				agShowDeleteButton: true,
				windowWidth:500,
				windowHeight:'',
				maxWindowHeight: 400,
				windowName:'tag',
				text:'Tag ändern',
				nodeType:2106,
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [{
					text: 'Name',  dataIndex: 'name',  flex: 1
				}],
				tools:[{
					xtype: 'textfield',
					labelSeparator: ' ',
					name:'gridFilter',
					width: 250,
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Suchbegriff hier eintragen ...',
					agSearchFields: 'name',
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
					text: 'Neuen Tag hinzufügen',
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:400,
					windowHeight:'',
					maxWindowHeight: 400,
					windowName:'tag',
					nodeType:2106
				}]
				
			},{
				
				xtype: 'grid',
				region: 'center',
				name:'kategorien',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Kategorien',
				store: 'Kategorien',
				agShowDeleteButton: true,
				windowWidth:500,
				windowHeight:'',
				maxWindowHeight: 400,
				windowName:'kategorie',
				text:'Kategorie ändern',
				nodeType:2104,
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [{
					text: 'Name',  dataIndex: 'name',  flex: 1
				}],
				tools:[{
					xtype: 'textfield',
					labelSeparator: ' ',
					name:'gridFilter',
					width: 250,
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Suchbegriff hier eintragen ...',
					agSearchFields: 'name',
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
					text: 'Neue Kategorie hinzufügen',
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:400,
					windowHeight:'',
					maxWindowHeight: 400,
					windowName:'kategorie',
					nodeType:2104
				}]
				
			},{
				xtype: 'grid',
				region: 'east',
				name:'typ',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Veranstaltungstypen',
				store: 'Typ',
				agShowDeleteButton: true,
				windowWidth:500,
				windowHeight:'',
				maxWindowHeight: 400,
				windowName:'typ',
				text:'Veranstaltungstyp ändern',
				nodeType:2105,
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [{
					text: 'Name',  dataIndex: 'name',  flex: 1
				}],
				tools:[{
					xtype: 'textfield',
					labelSeparator: ' ',
					name:'gridFilter',
					width: 250,
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Suchbegriff hier eintragen ...',
					agSearchFields: 'name',
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
					text: 'Neuen Typ hinzufügen',
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:400,
					windowHeight:'',
					maxWindowHeight: 400,
					windowName:'typ',
					nodeType:2105
				}]
				
				
			}]
		});
		me.callParent(arguments);
	}

});
