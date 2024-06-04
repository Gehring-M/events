Ext.define('myapp.view.Veranstaltungen', {
	extend: 'Ext.form.Panel',
	alias: 'widget.Veranstaltungen',
	layout: {
		type: 'border'
	},
	flex: 1,
	style: 'backgroundColor: #d1d1d1',

	initComponent: function () {
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
				windowWidth: '800px',

				maxWindowHeight: '90%',
				windowName: 'veranstaltungen',
				text: 'Veranstaltung bearbeiten',
				agShowDeleteButton: true,
				agShowDuplicateButton: true,
				nodeType: 2102,
				viewConfig: {
					getRowClass: function (record, rowIndex, rowParams, store) {
						return record.data.visible !== 1 ? ["Cintern", "Cwp", "Cextern"][record.data.extern - 1] : ["Cintern", "Cwpl", "Cextern"][record.data.extern - 1]

						//you can also use
						//record.data.isChecked == 1 ? 'child-row' : 'adult-row';

					},
					enableTextSelection: true,
				},
				plugins: [{
					ptype: 'bufferedrenderer',
					trailingBufferZone: 20,
					leadingBufferZone: 50
				}],
				columns: [
					
					{
						width: 16, hideable: false, menuDisabled: true, resizable: false, sortable: false,
						renderer: function (value, data, record) {
							if (record.data.parent_fk == null && record.data.children > 0) {
								data.tdCls = 'tdPointer';
					
									return '<img src="/img/closed.gif" style="margin-left: -2px; margin-top: 6px">';
								
							}
						}
					},
					{
						text: 'Titel der Veranstaltung', dataIndex: 'name', flex: 2, menuDisabled: true, sortable: true,
						renderer: function (value, data, record) {


							data.tdCls = 'tdRootTag'

							if (record.data.parent_fk != null) {
								data.tdCls = 'tdSubTag'
								return value;
							} else {
								val = value;
								if (record.data.children > 0) val = val + ' (' + record.data.children + ')';
								return val;
							}
						}

					},

					{ text: 'Daum von', dataIndex: 'von', width: 110, xtype: 'datecolumn', format: 'd.m.Y', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Datum bis', dataIndex: 'bis', width: 110, xtype: 'datecolumn', format: 'd.m.Y', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Uhrzeit von', dataIndex: 'uhrzeitvon', width: 110, xtype: 'datecolumn', format: 'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Uhrzeit bis', dataIndex: 'uhrzeitbis', width: 110, xtype: 'datecolumn', format: 'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Veranstaltungsort', dataIndex: 'veranstaltungsort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Adresse', dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'PLZ', dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Ort', dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Preis', dataIndex: 'preis', width: 150, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Region', dataIndex: 'region', width: 150, menuDisabled: true, menuDisabled: true, sortable: false },

					/*{
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
						
					},*/
					{
						xtype: 'componentcolumn',
						sortable: false,
						menuDisabled: true,
						dataIndex: 'test',
						width: 190,

						renderer: function (value, data, record) {

							if (record.data.parent_fk == null) {
								
								return {
									xtype: 'button',
									text: 'Neue Subveranstaltung',
									test: record.recordid,
									agRecord: record,
									windowWidth: '800px',
									maxWindowHeight: '90%',
									nodeType: 2102,
									nameForeignKey: 'parent_fk',
									listeners: {
										click: function (value, data, record) {

											let scope = this




											Ext.Ajax.request({
												url: '/modules/common/create.cfc?method=duplicateVeranstaltungSub',
												params: {

													veranstaltung_fk: this.agRecord.data.recordid,

												},
												success: function (response, test, x) {

													var jsonParse = Ext.JSON.decode(response.responseText);
													for (let a in jsonParse) {
														if (!jsonParse[a]) {
															delete jsonParse[a]
														}
													}
													jsonParse.recordid = jsonParse.id
													jsonParse.uhrzeitvon = jsonParse.uhrzeitvon?.split("")[1]
													jsonParse.uhrzeitbis = jsonParse.uhrzeitbis?.split("")[1]
													let myWindow =myController.myFunctions.onOpenWindow(scope.up('grid'), { data: jsonParse }, '')
													
													console.log(jsonParse)
															let store = scope.up("grid").up().down("grid[name=SubVeranstaltungen]").getStore()
															console.log(store)
															console.log(store.find("recordid", jsonParse.recordid))
															scope.up("grid").getView().select(scope.up("grid").getStore().find("recordid", jsonParse.parent_fk))
															store.reload({callback:()=>scope.up("grid").up().down("grid[name=SubVeranstaltungen]").getView().select(store.find("recordid", jsonParse.recordid))})
															
															//scope.up("grid").up().down("grid[name=SubVeranstaltungen]").getView().select(store.find("recordid", jsonParse.recordid))
															
											
															
														
													
										




													return jsonParse

												}

											})
										}
									}
								};
							}
							else {
								return {
									xtype: 'button',
									text: 'Umwandeln in Hautpv.',
									test: record.recordid,
									agRecord: record,
									windowWidth: '800px',
									maxWindowHeight: '90%',
									nodeType: 2102,
									//nameForeignKey: 'parent_fk',
									listeners: {
										click: function (value, data, record) {

											let scope = this




											Ext.Ajax.request({
												url: '/modules/common/update.cfc?method=removeparent',
												params: {

													id: this.agRecord.data.recordid,

												},
												success: function (response, test, x) {

													var jsonParse = Ext.JSON.decode(response.responseText);
													for (let a in jsonParse) {
														if (!jsonParse[a]) {
															delete jsonParse[a]
														}
													}

													scope.up('grid').store.reload()



													return jsonParse

												}

											})
										}
									}
								};
							}
						},


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

				tools: [{
					xtype: 'textfield',
					labelSeparator: ' ',
					name: 'filterText',
					width: 210,
					padding: '0px 0px 0px 7px',
					labelClsExtra: 'whiteBold',
					emptyText: 'Suchbegriff für Volltextsuche',
					enableKeyEvents: true,
					listeners: {
						keyup: {
							fn: function (el, event) {
								if (event.getCharCode() == 13) {
									myController.onEnterSuchen(el);
								}
							}
						}
					}
				}, {
					xtype: 'datefield',
					name: 'filterVon',
					submitFormat: 'Y-m-d',
					width: 100,
					labelSeparator: '',
					emptyText: 'Beginn',
					value: new Date(new Date().getFullYear(), 0, 1),
					margin: '0 0 0 5',
					plugins: [Ext.create('Ext.ux.field.date.plugin.CalendarWeek')]
				}, {
					xtype: 'datefield',
					name: 'filterBis',
					submitFormat: 'Y-m-d',
					width: 100,
					labelSeparator: '',
					value: new Date(new Date().getFullYear(), 11, 31),
					emptyText: 'Ende',
					margin: '0 0 0 5',
					plugins: [Ext.create('Ext.ux.field.date.plugin.CalendarWeek')]
				}, {
					xtype: 'button',
					text: 'Veranstaltungen suchen',
					width: 180,
					height: 24,
					id: "dirty123",
					name: 'btnSuche',
					agAction: 'suchen',
					margin: '0 0 0 5',
					cls: 'btn-gray'
				}, {
					xtype: 'button',
					text: 'Reset',
					width: 65,
					height: 24,
					name: 'btnReset',
					agAction: 'reset',
					margin: '0 0 0 5',
					cls: 'btn-red'
				}, {
					xtype: 'button',
					text: 'Export',
					name: 'btnExport',
					width: 60,
					height: 24,
					margin: '0 0 0 5',
					cls: 'btn-gray',
				}, {
					xtype: 'displayfield',
					width: 2,
					height: 24,
					margin: '0 3 0 12',
					cls: 'button-grey'
				}, {
					xtype: 'button',
					text: 'Neue Veranstaltung',
					width: 200,
					height: 24,
					margin: '0 0 0 10',
					cls: 'btn-gray',
					windowWidth: '800px',
					maxWindowHeight: '90%',
					windowName: 'veranstaltungen',
					nodeType: 2102
				}]

			}, {

				xtype: 'tabpanel',
				border: false,
				flex: 2,
				region: 'south',
				split: true,
				margin: '0 0 0 0',
	
				bodyStyle: {
					backgroundColor: '#bcbbc3'
				},
				name: 'veranstaltungsdetails',
				items: [{
					
					xtype: 'grid',
					border: true,
					flex: 1,
					title: 'Sub Veranstaltungen',
					store:"SubVeranstaltungen",
					name: 'SubVeranstaltungen',
					windowName: 'veranstaltungen',
					text: 'Sub Veranstaltung bearbeiten',
					windowWidth: '800px',

					nodeType: 2102,
					agShowDeleteButton: true,
					agShowAbortButton: true,
					agDoNotShowSaveButton: false,
					margin: '0 0 0 0',
					viewConfig: {
						enableTextSelection: false,
					},
					columns: [
						{ text: 'Titel', dataIndex: 'name', flex: 1 },
						{ text: 'Daum von', dataIndex: 'von', width: 110, xtype: 'datecolumn', format: 'd.m.Y', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Datum bis', dataIndex: 'bis', width: 110, xtype: 'datecolumn', format: 'd.m.Y', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Uhrzeit von', dataIndex: 'uhrzeitvon', width: 110, xtype: 'datecolumn', format: 'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Uhrzeit bis', dataIndex: 'uhrzeitbis', width: 110, xtype: 'datecolumn', format: 'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Veranstaltungsort', dataIndex: 'veranstaltungsort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Adresse', dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'PLZ', dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Ort', dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Preis', dataIndex: 'preis', width: 150, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Region', dataIndex: 'region', width: 150, menuDisabled: true, menuDisabled: true, sortable: false },
					],
					bbar: []



				}

					
				

			



			]}]
		});

		me.callParent(arguments);

	}


});
