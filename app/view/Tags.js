Ext.define('oegb.view.Tags', {
	extend: 'Ext.form.Panel',
	alias: 'widget.Tags',
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
				region: 'center',
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
				windowName:'tags',
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
					width: 300,
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
					windowName:'tags',
					nodeType:2106
				}],
				
			}]
		});
		me.callParent(arguments);
	}

});