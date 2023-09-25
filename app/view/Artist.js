Ext.define('myapp.view.Artist', {
	extend: 'Ext.form.Panel',
	alias: 'widget.Artist',
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
				title: 'Künstler',
				region: 'center',
				name: 'artist',
				layout: 'fit',
				flex: 4,
				split: true,
				autoScroll: true,
				collapsible: true,
				store: 'Artist',
				windowWidth:'800px',
				maxWindowHeight: '90%',
				windowName:'artist',
				text:'Künstler bearbeiten',
				agShowDeleteButton: true,
				agShowDuplicateButton: true,
				nodeType:2103,
				viewConfig: {
            		enableTextSelection: true
				},
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [
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
					text: 'Künstler suchen',
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
					text: 'Neun Künster anlegen',
					width: 200,
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:'800px',
					maxWindowHeight: '90%',
					windowName:'artist',
					nodeType:2103
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
				name:'kuenstlerdetails',
				items: [{
					xtype: 'grid',
					name:'kategoriezuweisung',
					flex: 1,
					split: true,
					autoScroll: true,
					title: 'Kategorie',
					collapsible: true,
					store: 'Kategorien',
					plugins: [{
						ptype: 'bufferedrenderer',
						trailingBufferZone: 20, 
						leadingBufferZone: 50  
					}],	
					columns: [{
							width:28, hideable: false, menuDisabled:true, resizable: false, dataIndex: 'checked', sortable: false,
							renderer: function(value,data,record) {
								data.tdCls ='tdPointer';
								if (record.data.checked) {
									return'<img src="img/icons/checked.png" style="margin-left: 1px; margin-top: 1px">';
								} else {
									return'<img src="img/icons/unchecked.png" style="margin-left: 1px; margin-top: 1px">';
								}
							}
						},{ 
							text: 'Tags', dataIndex: 'name', flex: 1, menuDisabled: true, sortable: false
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
						emptyText: 'Schnellfilter nach Kategorie',
						enableKeyEvents: true,
						agSearchFields: 'name',
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
					},{	
						xtype: 'button',
						text: 'Neue Kategorie hinzufügen',
						height: 24,
						margin:'0 5 0 0',
						width: 200,
						windowWidth:400,
						windowHeight:'',
						maxWindowHeight: 400,
						windowName:'kategorie',
						nodeType:2104,
						cls: 'btn-orange'
					}]
				},{ 	
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
						html: '<iframe src="/modules/multiupload.cfm?typ=bilder" width="490" height="1000"></iframe>'
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
						html: '<iframe src="/modules/multiupload.cfm?typ=uploads" width="490" height="1000"></iframe>'
					}]

				}]
				
				
				
				
				/*
			},{	
				xtype: 'grid',
				region: 'east',
				name:'kategorienbaum',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Kategorien',
				collapsible: true,
				store: 'RKategorienSubkategorien',
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [{
						xtype:'checkcolumn', name:'checked', dataIndex: 'checked', width: 38,  menuDisabled:true, resizable: false, sortable: false, hidden: true
					},{ 
						width:16, hideable: false, menuDisabled:true, resizable: false, dataIndex: 'opened', sortable: false,
						renderer: function(value,data,record) {
							if (record.data.parent_fk == null && record.data.children > 0) {
								data.tdCls ='tdPointer';
								if (record.data.opened) {
									return'<img src="img/opened.png" style="margin-left: -2px; margin-top: 6px">';
								} else {
									return '<img src="/img/closed.gif" style="margin-left: -2px; margin-top: 6px">';
								}
								
							}
						}
					},{ 	
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
						width:40, hideable: false, menuDisabled:true, resizable: false, dataIndex: 'kategorieChecked', sortable: false,
						renderer: function(value,data,record) {
							if (record.data.parent_fk != null) {
								data.tdCls ='tdPointer';
								if (record.data.kategorieChecked) {
									return'<img src="img/icons/checked.png" style="margin-left: 1px; margin-top: 4px">';
								} else {
									return'<img src="img/icons/unchecked.png" style="margin-left: 1px; margin-top: 4px">';
								}
							}
						}
					}
				],
				tools:[{
					xtype: 'textfield',
					labelSeparator: ' ',
					labelWidth: 140,
					width: 160,
					name:'gridFilter',
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Tabellenfilter',
					enableKeyEvents: true,
					agSearchFields: 'name,subnames',
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
					cls: 'btn-gray'
				}]
				
				
			},{
				
				
				xtype: 'grid',
				region: 'east',
				name:'tagzuweisung',
				flex: 1,
				split: true,
				autoScroll: true,
				title: 'Tags',
				collapsible: true,
				store: 'Laender',
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20, 
					leadingBufferZone: 50  
				}],	
				columns: [{
						text: 'Tags',  dataIndex: 'name',  flex: 1, menuDisabled: true, sortable: false
					},{ 
						width:40, hideable: false, menuDisabled:true, resizable: false, dataIndex: 'tagChecked', sortable: false,
						renderer: function(value,data,record) {
							data.tdCls ='tdPointer';
							if (record.data.tagChecked) {
								return'<img src="img/icons/checked.png" style="margin-left: 1px; margin-top: 2px">';
							} else {
								return'<img src="img/icons/unchecked.png" style="margin-left: 1px; margin-top: 2px">';
							}
						}
					}
				],
				tools:[{
					xtype: 'textfield',
					labelSeparator: ' ',
					labelWidth: 140,
					width: 160,
					name:'gridFilter',
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Tabellenfilter',
					enableKeyEvents: true,
					agSearchFields: 'name',
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
					cls: 'btn-gray'
				}],
				
				bbar:[{
					xtype: 'button',
					text: 'Neuen Tag hinzufügen',
					height: 30,
					margin:'0 5 0 0',
					flex: 1,
					windowWidth:400,
					windowHeight:'',
					maxWindowHeight: 400,
					windowName:'tags',
					nodeType:2106,
					cls: 'btn-gray'
				}]
			
				*/	
			}]
		});
		me.callParent(arguments);
	}

});
