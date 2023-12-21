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
				title: 'Veranstalter',
				region: 'center',
				name: 'veranstalter',
				layout: 'fit',
				flex: 4,
				split: true,
				autoScroll: true,
				collapsible: true,
				store: 'Veranstalter',
				windowWidth:'800px',
				maxWindowHeight: '90%',
				windowName:'veranstalter',
				text:'Veranstalter bearbeiten',
				agShowDeleteButton: true,
				agShowDuplicateButton: true,
				nodeType:2101,
				viewConfig: {
            		enableTextSelection: true
				},
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [
					{
						xtype: 'componentcolumn', 
						sortable: false,
						menuDisabled: true,
						dataIndex: 'id',
						width: 190,
						
						renderer: function(value1,data1,record1) {
					
							
								return {
								
										xtype: 'button',
										text: 'Neue Veranstaltung',
										width: 200,
										height: 24,
										margin:'0 0 0 10',
										cls: 'btn-gray',
										windowWidth:'800px',
										maxWindowHeight: '90%',
										windowName:'veranstaltungen',
										nodeType:2102,
										listeners:{
										click:function(value,data,record){
											setTimeout(()=>console.log(Ext.ComponentQuery.query('[xtype=window]')[0].down("[xtype=hiddenfield]").setValue(record1.data.recordid)), 500)
											
										}
									
								
									
									}
								
									
								
								
							}
						},
			
						
					},
					{ text: 'Name',  dataIndex: 'name', flex: 1, },
					{ text: 'Ansprechperson',  dataIndex: 'ansprechperson', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Adresse',  dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'PLZ',  dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Ort',  dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Telefon',  dataIndex: 'telefon', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Email',  dataIndex: 'email', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Web',  dataIndex: 'web', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Link',  dataIndex: 'link', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					
				],
				
				tools:[{
					xtype: 'textfield',
					labelSeparator: ' ',
					name:'filterText',
					width: 210,
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Suchbegriff für Volltextsuche',
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
					text: 'Veranstalter suchen',
					width: 180,
					height: 24,
					name:'btnSuche',
					agAction:'suchen',
					margin:'0 0 0 5',
					cls: 'btn-gray'
				},{	
					xtype: 'button',
					text: 'Reset',
					width: 65,
					height: 24,
					name:'btnReset',
					agAction:'reset',
					margin:'0 0 0 5',
					cls: 'btn-red'
				
				},{
					xtype: 'displayfield',
					width: 2,
					height: 24,
					margin:'0 3 0 12',
					cls: 'button-grey'
				},{
					xtype: 'button',
					text: 'Neuen Veranstalter anlegen',
					width: 200,
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:'800px',
					maxWindowHeight: '90%',
					windowName:'veranstalter',
					nodeType:2101
				}]
				
			},{		
				
				xtype: 'tabpanel',
				border: false,
				flex: 2,
				region: 'south',
				split: true,
				margin:'0 0 0 0',
				bodyStyle: {
					backgroundColor: '#bcbbc3'
				},
				name:'veranstalterdetails',
				items: [{
					xtype: 'fieldcontainer',
					layout: 'hbox',
					margin: '0 0 0 5',
					title: 'Bilder',
					width: '100%',
					height: '100%',
					items: [{
						xtype: 'grid',
						border: true,
						flex: 1,
						store: 'Bilder',
						name: 'Bilder',
						height: '100%',
						windowWidth:600,
						windowHeight:'',
						maxWindowHeight: 500,
						windowName:'bilder',
						text:'Bilder  bearbeiten / löschen',
						nodeType:1,
						agShowDeleteButton: true,
						margin:'0 0 0 0',
						viewConfig: {
							enableTextSelection: false,
						},
						columns: [
							{ text: 'Vorschau',  dataIndex: 'vorschaubild', align: 'center', width: 118,
								renderer: function(value){
									if (value!="") {
										return '<div><span></span><img src="' + value + '" class="pointer"/></div>';
									} else {
										return 'Nicht verfübar';
									}
								}
							},
							{ text: 'Hochgeladen am',  dataIndex: 'createdwhen', width: 150, xtype: 'datecolumn', format:'d.m.Y', align: 'center'},
							{ text: 'Titel',  dataIndex: 'titel', flex: 1 },
							{ text: 'Beschreibung',  dataIndex: 'beschreibung', flex: 1 },
							{ text: 'Auflösung',  dataIndex: 'resolution', width: 110, align: 'center' },
							{ text: 'Ansehen', align: 'center' , width: 90,
								renderer: function(value,data,record) { 
									data.tdCls = 'tdHover';
									return'<img src="img/eye.png" title="Diese Datei ansehen" alt="Diese Datei ansehen">';
								} 
							},
							{ text: 'Download', align: 'center' , width: 90,
								renderer: function(value,data,record) { 
									data.tdCls = 'tdHover';
									return'<img src="img/download.png" title="Diese Datei laden" alt="Diese Datei laden">';
								} 
							}
						],
						bbar:[{
							xtype: 'textfield',
							labelSeparator: ' ',
							labelWidth: 140,
							width: 360,
							name:'gridFilter',
							margin:'0 0 0 0',
							labelClsExtra: 'whiteBold',
							emptyText: 'Schnellfilter für Bilder',
							enableKeyEvents: true,
							agSearchFields: 'beschreibung,titel',
							listeners: {
								keyup: {
									fn: function(el,event) {
										if (event.getCharCode() == 27) {
											el.setValue('');
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
							cls: 'btn-red'
						},{	
							xtype: 'displayfield',
							flex: 1
						
						}]
					},{	
						xtype: 'panel',
						border: false,
						height: 1000,
						margin:'0 0 0 0',
						padding:'0 0 0 0',
						width: 480,
						html: '<iframe src="/modules/multiupload.cfm?typ=bilder&bereich=veranstalter" width="490" height="1000"></iframe>'
					}]

				},{ 	
					xtype: 'fieldcontainer',
					layout: 'hbox',
					margin: '0 0 0 5',
					title: 'Downloads',
					width: '100%',
					height: '100%',
					items: [{
						xtype: 'grid',
						border: true,
						flex: 1,
						store: 'Downloads',
						name: 'Downloads',
						height: '100%',
						windowWidth:600,
						windowHeight:'',
						maxWindowHeight: 500,
						windowName:'downloads',
						text:'Download bearbeiten / löschen',
						nodeType:2,
						agShowDeleteButton: true,
						margin:'0 0 0 0',
						viewConfig: {
							enableTextSelection: false,
						},
					
						columns: [
							{ text: 'Vorschau',  dataIndex: 'vorschaubild', align: 'center', width: 118,
								renderer: function(value){
									return '<div style="text-align: center" ><img src="' + value + '" /></div>';
								}
							},
							{ text: 'Hochgeladen am',  dataIndex: 'createdwhen', width: 150, xtype: 'datecolumn', format:'d.m.Y', align: 'center'},
							{ text: 'Titel',  dataIndex: 'titel', flex: 1 },
							{ text: 'Beschreibung',  dataIndex: 'beschreibung', flex: 1 },
							{ text: 'Auflösung',  dataIndex: 'resolution', width: 110, align: 'center' },
							{ text: 'Dateityp',  dataIndex: 'extension', width: 80, align: 'center'},
							{ text: 'Ansehen', align: 'center' , width: 90,
								renderer: function(value,data,record) { 
									if (record.data.previewable=="yes") {
										data.tdCls = 'tdHover';
										return'<img src="img/eye.png" title="Diese Datei ansehen" alt="Diese Datei ansehen">';
									} else {
										return'<img src="img/noeye.png" title="Diese Datei laden" alt="Diese Datei laden">';
									}
								} 
							},
							{ text: 'Download', align: 'center' , width: 90,
								renderer: function(value,data,record) { 
									data.tdCls = 'tdHover';
									return'<img src="img/download.png" title="Diese Datei laden" alt="Diese Datei laden">';
								} 
							}
						],
						bbar:[{
							xtype: 'textfield',
							labelSeparator: ' ',
							labelWidth: 140,
							width: 360,
							name:'gridFilter',
							margin:'0 0 0 0',
							labelClsExtra: 'whiteBold',
							emptyText: 'Schnellfilter für Dokumente',
							enableKeyEvents: true,
							agSearchFields: 'beschreibung,titel',
							listeners: {
								keyup: {
									fn: function(el,event) {
										if (event.getCharCode() == 27) {
											el.setValue('');
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
							cls: 'btn-red'
						},{	
							xtype: 'displayfield',
							flex: 1
						
						}]
					},{
						xtype: 'panel',
						border: false,
						height: 1000,
						margin:'0 0 0 0',
						padding:'0 0 0 0',
						width: 480,
						html: '<iframe src="/modules/multiupload.cfm?typ=uploads&bereich=veranstalter" width="490" height="1000"></iframe>'
					}]

				}]
			}]
		});
		me.callParent(arguments);
	}

});
