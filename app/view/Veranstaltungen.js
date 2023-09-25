Ext.define('myapp.view.Veranstaltungen', {
	extend: 'Ext.form.Panel',
	alias: 'widget.Veranstaltungen',
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
				title: 'Veranstaltungen',
				region: 'center',
				name: 'veranstaltungen',
				layout: 'fit',
				flex: 4,
				split: true,
				autoScroll: true,
				collapsible: true,
				store: 'Veranstaltungen',
				windowWidth:'800px',
				maxWindowHeight: '90%',
				windowName:'veranstaltungen',
				text:'Veranstaltung bearbeiten',
				agShowDeleteButton: true,
				agShowDuplicateButton: true,
				nodeType:2102,
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
					},
					{ xtype:'checkcolumn', name:'checked', dataIndex: 'checked', width: 38, hideable: false, menuDisabled:true, resizable: false, sortable: false, menuDisabled: true, hidden: true }, 
					{ text: 'Titel der Veranstaltung',  dataIndex: 'name', flex: 2, menuDisabled: true, sortable: false,
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
					},
					
					{ text: 'Daum von',  dataIndex: 'von', width: 110, xtype: 'datecolumn', format:'d.m.Y', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Datum bis',  dataIndex: 'bis', width: 110, xtype: 'datecolumn', format:'d.m.Y', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Uhrzeit von',  dataIndex: 'uhrzeitvon', width: 110, xtype: 'datecolumn', format:'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Uhrzeit bis',  dataIndex: 'uhrzeitbis', width: 110, xtype: 'datecolumn', format:'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Veranstaltungsort',  dataIndex: 'veranstaltungsort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Adresse',  dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'PLZ',  dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Ort',  dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					{ text: 'Preis',  dataIndex: 'preis', width: 150, menuDisabled: true, menuDisabled: true, sortable: false  },
					{
						xtype: 'componentcolumn', 
						sortable: false,
						menuDisabled: true,
						dataIndex: 'button',
						width: 190,
						renderer: function(value,data,record) {
							if (record.data.parent_fk == null) {
								return {
									xtype: 'button',
									text: 'Neue Subveranstaltung',
									agRecord: record,
									windowWidth:'800px',
									maxWindowHeight: '90%',
									windowName:'veranstaltungen',
									nodeType:2102,
									nameForeignKey:'parent_fk'
								};
							}
						}
						
					},
					
					
					/*
					
					{ align: 'center' , width: 60, text: 'Login',
						renderer: function(value,data,record) { 
							data.tdCls = 'tdHover';
							if (record.data.loginrequired) {
								return'<img src="img/lock.png" title="Dokument scheint nur im eingeloggten Zustand auf." alt="Dokument scheint nur im eingeloggten Zustand auf.">';
							} else {
								return'<img src="img/unlock.png" title="Dokument scheint auch OHNE Login Zustand auf." alt="Dokument scheint auch OHNE Login Zustand auf.">';
							}
					 	} 
					},
					{ text: 'Gehört zu',  dataIndex: 'parent_name', flex: 2, menuDisabled: true},
					{ text: 'Kategorie',  dataIndex: 'kategorienamen', flex: 2, menuDisabled: true, tdCls: 'tdKategorie'	},
					{ text: 'Öffentliche Tags',  dataIndex: 'tagnamen', flex: 1, menuDisabled: true, tdCls: 'tdKategorie',
						renderer: function(value, meta){
								meta.style = 'white-space: normal;'; 
								return value;      
							}
					},
					{ text: 'zuletzt geändert am',  dataIndex: 'changedwhen', width: 160, xtype: 'datecolumn', format:'d.m.Y H:i', align: 'center', menuDisabled: true },
					{ text: 'Im Archiv ab',  dataIndex: 'archiv_ab', width: 140, xtype: 'datecolumn', format:'d.m.Y', align: 'center', menuDisabled: true  },
					{ text: 'Version',  dataIndex: 'version', align: 'center' , width: 100, menuDisabled: true },
					{ align: 'center' , width: 60, text: 'Public',
						renderer: function(value,data,record) { 
							data.tdCls = 'tdHover';
							if (record.data.public) {
								return'<img src="img/public.png" title="Dokument scheint in anderen Portalen auf." alt="Dokument scheint in anderen Portalen auf.">';
							} else {
								return'<img src="img/private.png" title="Dokument scheint NICHT in anderen Portalen auf." alt="Dokument scheint NICHT in anderen Portalen auf.">';
							}
					 	} 
					},
					
					{ align: 'center' , width: 60,
						renderer: function(value,data,record) { 
							if (record.data.upload != null) {
								data.tdCls = 'tdHover';
								return'<img src="img/download.png" title="Diese Datei laden" alt="Diese Datei laden">';
							}
					 	} 
					}
					*/
					
					
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
					xtype: 'datefield',
					name: 'filterVon',
					submitFormat: 'Y-m-d',
					width: 100,
					labelSeparator:'',
					emptyText: 'Beginn',
					margin:'0 0 0 5',
					plugins: [Ext.create('Ext.ux.field.date.plugin.CalendarWeek')]
				},{		
					xtype: 'datefield',
					name: 'filterBis',
					submitFormat: 'Y-m-d',
					width: 100,
					labelSeparator:'',
					emptyText: 'Ende',
					margin:'0 0 0 5',
					plugins: [Ext.create('Ext.ux.field.date.plugin.CalendarWeek')]
				},{
					xtype: 'button',
					text: 'Veranstaltungen suchen',
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
					xtype: 'button',
					text: 'Export',
					name: 'btnExport',
					width: 60,
					height: 24,
					margin:'0 0 0 5',
					cls: 'btn-gray',
				},{
					xtype: 'displayfield',
					width: 2,
					height: 24,
					margin:'0 3 0 12',
					cls: 'button-grey'
				},{
					xtype: 'button',
					text: 'Neue Veranstaltung',
					width: 200,
					height: 24,
					margin:'0 0 0 10',
					cls: 'btn-gray',
					windowWidth:'800px',
					maxWindowHeight: '90%',
					windowName:'veranstaltungen',
					nodeType:2102
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
				name:'veranstaltungsdetails',
				items: [{
					xtype: 'grid',
					border: true,
					flex: 1,
					title:'Veranstalter',
					store: 'RVeranstaltungVeranstalter',
					name: 'RVeranstaltungVeranstalter',
					windowName:'rveranstaltungveranstalter',
					text:'Verknüpfung löschen',
					windowWidth:'200px',
					nodeType:2111,
					agShowDeleteButton: true,
					agShowAbortButton: false,
					agDoNotShowSaveButton: true,
					margin:'0 0 0 0',
					viewConfig: {
						enableTextSelection: false,
					},
					columns: [
						{ text: 'Veranstalter',  dataIndex: 'name', flex: 1 },
						{ text: 'Adresse',  dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'PLZ',  dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Ort',  dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Telefon',  dataIndex: 'telefon', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Email',  dataIndex: 'email', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Web',  dataIndex: 'web', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					],
					bbar:[{
						xtype: 'combobox',
						width: 350,
						name: 'addVeranstalter',
						store: 'Veranstalter',
						displayField: 'name',
						valueField: 'recordid',
						queryMode: 'remote',
						queryDelay: 700,
						minChars:3,
						typeAhead: true,
						hideTrigger: true,
						multiSelect: false,
						queryParam: 'filterText',
						emptyText: 'Veranstalter suchen und hinzufügen',
						tpl: Ext.create('Ext.XTemplate',
							'<ul class="x-list-plain"><tpl for=".">',
								'<li role="option" class="x-boundlist-item" style="{optionstyle}">{name}<br>{adresse}<br>{plz} {ort}<hr></li>',
							'</tpl></ul>'
						)
					},{ 
						xtype: 'button',
						name: 'addVeranstalter',
						text: ' Veranstalter verknüpfen',
						margin:'0 5 0 0',
						width: 250,
						cls: 'btn-green'
					},{ 
						xtype: 'displayfield',
						flex: 1
					},{ 	
						xtype: 'button',
						text: 'Veranstalter nicht gefunden? - Neuen Veranstalter hinzufügen',
						margin:'0 5 0 0',
						width: 400,
						windowWidth:'800px',
						maxWindowHeight: '90%',
						windowName:'veranstalter',
						agVerknuepfungErstellen: true,
						nodeType:2101,
						cls: 'btn-orange',
						name: 'addNewVeranstalter'
					}]
				
				
					
				},{ 
					xtype: 'grid',
					border: true,
					flex: 1,
					title:'Künstler',
					store: 'RVeranstaltungArtist',
					name: 'RVeranstaltungArtist',
					windowWidth:800,
					windowHeight:'',
					maxWindowHeight: 800,
					windowName:'rveranstaltungartist',
					text:'Details bearbeiten',
					nodeType:2110,
					agShowDeleteButton: true,
					margin:'0 0 0 0',
					viewConfig: {
						enableTextSelection: false,
					},
					columns: [
						{ text: 'Künstler',  dataIndex: 'name', flex: 1, },
						
						{ text: 'Uhrzeit von',  dataIndex: 'uhrzeitvon', width: 110, xtype: 'datecolumn', format:'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Uhrzeit bis',  dataIndex: 'uhrzeitbis', width: 110, xtype: 'datecolumn', format:'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Veranstaltungsort',  dataIndex: 'veranstaltungsort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Adresse',  dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'PLZ',  dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false  },
						{ text: 'Ort',  dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false  },
					],
					bbar:[{
						xtype: 'combobox',
						width: 350,
						name: 'addArtist',
						store: 'Artist',
						displayField: 'name',
						valueField: 'recordid',
						queryMode: 'remote',
						queryDelay: 700,
						minChars:3,
						typeAhead: true,
						hideTrigger: true,
						multiSelect: false,
						queryParam: 'filterText',
						emptyText: 'Künstler suchen und hinzufügen',
						tpl: Ext.create('Ext.XTemplate',
							'<ul class="x-list-plain"><tpl for=".">',
								'<li role="option" class="x-boundlist-item" style="{optionstyle}">{name}<br>{adresse}<br>{plz} {ort}<hr></li>',
							'</tpl></ul>'
						)
					},{ 
						xtype: 'button',
						name: 'addArtist',
						text: ' Künstler verknüpfen',
						margin:'0 5 0 0',
						width: 250,
						cls: 'btn-green'
					},{ 
						xtype: 'displayfield',
						flex: 1
					},{ 	
						xtype: 'button',
						text: 'Künstler nicht gefunden? - Neuen Künstler hinzufügen',
						margin:'0 5 0 0',
						width: 400,
						windowWidth:'800px',
						maxWindowHeight: '90%',
						windowName:'artist',
						nodeType:2103,
						cls: 'btn-orange',
						name: 'addNewArtist'
					}]
					
					
				
				},{ 
					xtype: 'grid',
					name:'tagzuweisung',
					flex: 1,
					split: true,
					autoScroll: true,
					title: 'Tags',
					collapsible: true,
					store: 'Tags',
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
						emptyText: 'Schnellfilter nach Tags',
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
						text: 'Neuen Tag hinzufügen',
						height: 24,
						margin:'0 5 0 0',
						width: 200,
						windowWidth:400,
						windowHeight:'',
						maxWindowHeight: 400,
						windowName:'tag',
						nodeType:2106,
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
						html: '<iframe src="/modules/multiupload.cfm?typ=bilder&bereich=veranstaltung" width="490" height="1000"></iframe>'
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
						html: '<iframe src="/modules/multiupload.cfm?typ=uploads&bereich=veranstaltung" width="490" height="1000"></iframe>'
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
