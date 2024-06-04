Ext.define('myapp.controller.Common', {
	extend: 'Ext.app.Controller',

	views: [
		'Veranstaltungen',
		'Veranstalter',
		'Basics',
		'Artist'
	],

	stores: [
		'Auth',
		'Laender',
		'SubVeranstaltungen',
		'Veranstaltungen',
		'Artist',
		'Veranstalter',
		'RVeranstaltungArtist',
		"RVeranstaltungKontakt",
		'RVeranstaltungVeranstalter',
		'Tags',
		'Bilder',
		'Downloads',
		'Kategorien',
		'Typ',
		'Region'
	],

	refs: [{
		ref: 'Veranstaltungen',
		selector: 'Veranstaltungen',
		xtype: 'Veranstaltungen',
		autoCreate: true
	}, {
		ref: 'Basics',
		selector: 'Basics',
		xtype: 'Basics',
		autoCreate: true
	}, {
		ref: 'Veranstalter',
		selector: 'Veranstalter',
		xtype: 'Veranstalter',
		autoCreate: true
	}, {
		ref: 'Artist',
		selector: 'Artist',
		xtype: 'Artist',
		autoCreate: true
	}],

	init: function () {
		var authStore = this.getAuthStore();
		var myBilderStore = this.getBilderStore();
		var myDownloadStore = this.getDownloadsStore();
		var myVAStore = this.getVeranstaltungenStore();


		me = this,
			this.myAuthStore = authStore
		this.myFunctions = myapp.app.getController('Funktionen');
		this.isAdministrator = (authStore.findExact('administrator', true) == 0) ? true : false;
		this.user_fk = authStore.getAt(0).data.user_fk;
		this.cVeranstaltung = 0;
		this.cArtist = 0;
		this.cVeranstalter = 0;
		this.myTimeOut = 5000;
		this.timerActive = false;
		this.timerTyp = "";

		if (this.inited) {
			return;
		}


		// patienten store nach x sek neu laden
		setInterval(function () {
			var existingData = [];
			if (me.timerActive) {
				var myStore = myBilderStore;
				if (me.timerTyp == "uploads") {
					var myStore = myDownloadStore;
				}
				Ext.each(myStore.data.items, function (cItem) {
					existingData.push(cItem.data.recordid);
				});
				Ext.Ajax.request({
					url: '/modules/common/services.cfc?method=checkNewData',
					params: {
						veranstaltung_fk: me.cVeranstaltung,
						artist_fk: me.cArtist,
						veranstalter_fk: me.cVeranstalter,
						fieldname: me.timerTyp,
						existing: existingData
					},
					success: function (response) {
						var jsonParse = Ext.JSON.decode(response.responseText);
						if (jsonParse['reload']) {
							myStore.reload();
						}
					}
				});

			}
		}, this.myTimeOut);

		this.inited = true;


		this.control({

			'gridview': {
				drop: function (node, data, overModel, dropPosition, dropHandlers) {


					me.onChangeSort(data.records[0].data.recordid, overModel.data.recordid, dropPosition, data.view.up('grid').specialname, data.view.up('grid').getStore(), data.view.up('grid'));
				}
			},
			'grid': {
				itemdblclick: this.onDblClickGrid,
				itemclick: this.onClickGrid,
				select: this.onGridRowSelected,
				cellclick: this.onCellClicked,
		
			},
			'button': {
				click: this.onClickButton
			},
			'tabpanel': {
				tabchange: this.loadStoreOnTabChange
			},
			'combobox': {
				blur: this.onBlurCombobox,
				beforequery: this.onBeforeQuery
			},
			'textfield[name=gridFilter]': {
				change: this.onKeyUpTextfield
			},

			'#btnTagToDoc': {
				click: this.onStartTagging
			},
			'#btnDocToTag': {
				click: this.onStartTagging
			},
			'filefield': {
				change: this.onSelectFile

			}

		});
	},


	//------------------------------------------------------------------------
	//Allgemeine Funktionen
	//------------------------------------------------------------------------	

	onOpenFile: function (el) {
		myDataID = el.agRecord.upload;
		if (myDataID == undefined) {
			myDataID = el.agRecord.data.upload;
		}
		window.open("/data.cfm?dataid=" + myDataID + "&download=yes");
	},

	onSelectFile: function (el) {
		el.up('window').down('hiddenfield[name=originalfilename]').setValue(el.getValue())
	},

	onCellClicked: function (gridview, markup, cellnumber, rec) {

		if (gridview.up('grid').name == "veranstaltungen") {
			this.cVeranstaltung = rec.data.recordid;
		}
		if (gridview.up('grid').name == "artist") {
			this.cArtist = rec.data.recordid;
		}
		if (gridview.up('grid').name == "veranstalter") {
			this.cVeranstalter = rec.data.recordid;
		}

		if ((gridview.up('grid').name == "Downloads" || gridview.up('grid').name == "Bilder") && cellnumber == gridview.up('grid').columns.length - 1) {
			myDataID = rec.data.recordid;
			if (myDataID != null) {
				window.open("/data.cfm?dataid=" + myDataID + "&download=yes");
			}
		}

		if ((gridview.up('grid').name == "Downloads" || gridview.up('grid').name == "Bilder") && (cellnumber == gridview.up('grid').columns.length - 2 || cellnumber == 0)) {
			if (rec.data.previewable == "yes") {
				var myWindow = Ext.create('Ext.window.Window', {
					title: 'Vorschau',
					layout: 'fit',
					closable: true,
					width: rec.data.wid,
					height: rec.data.hei,
					modal: true,
					items: [{
						xtype: 'panel',
						bodyPadding: 0,
						html: '<img style="width: 100%" src="' + rec.data.bild + '"/>'
					}]
				}).show();
			}
		}

		if (gridview.up('grid').name == "veranstaltungen" && cellnumber == 0) {
			var tmpID = rec.data.recordid;
			var status = !rec.data.opened;
			// if (rec.data.parent_fk == null) {
			// 	rec.store.removeFilter('filterOpened');
			// 	rec.set('opened', status);
			// 	Ext.each(rec.store.data.items, function (cItem) {
			// 		if (cItem.data.parent_fk == tmpID) {
			// 			cItem.set('opened', status);
			// 		}
			// 	});
			// 	rec.store.addFilter({
			// 		id: 'filterOpened',
			// 		filterFn: function (record) {
			// 			if (record.data.opened || record.data.parent_fk == null) {
			// 				return true;
			// 			} else {
			// 				return false;
			// 			}
			// 		}
			// 	});
			// 	gridview.up('grid').store.each(record => {
			// 		let pfk = record.get("parent_fk")
			// 		let open = record.get("opened")
			// 		if (pfk !== null && open) {
			// 			gridview.up('grid').store.remove(record, true)
			// 			gridview.up('grid').store.insert(gridview.up("grid").store.find("recordid", pfk) + 1, record)
			// 		}

			// 	})
			// }
		}

		if (gridview.up('grid').name == "tagzuweisung" && cellnumber == 0) {
			var me = this,
				status = !rec.data.checked,
				myView = this.getVeranstaltungen();

			Ext.Ajax.request({
				url: '/modules/common/services.cfc?method=editTags',
				params: {
					veranstaltung_fk: me.cVeranstaltung,
					tag_fk: rec.data.recordid,
					status: status
				},
				success: function (response) {
					var jsonParse = Ext.JSON.decode(response.responseText);
				}
			});
			rec.set('checked', status);

		}

		if (gridview.up('grid').name == "kategoriezuweisung" && cellnumber == 0) {

			var me = this,
				status = !rec.data.checked,
				myView = this.getArtist();

			Ext.Ajax.request({
				url: '/modules/common/services.cfc?method=editKategorie',
				params: {
					artist_fk: me.cArtist,
					kategorie_fk: rec.data.recordid,
					status: status
				},
				success: function (response) {
					var jsonParse = Ext.JSON.decode(response.responseText);
				}
			});
			rec.set('checked', status);

		}

	},

	loadDetailsOnGridClick: function (el, record) {
		var myElement = el.up('form').down('tabpanel'),
			nextGrid = "",
			myStore = "";
		if (myElement != null) {
			var myStore = myElement.activeTab.getStore();
		} else {
			var nextGrid = el.up('grid').nextSibling('grid');
			if (nextGrid != null) {
				var myStore = nextGrid.getStore();
			}
		}
		filterField = "miete_fk";
		filterValue = record.data.recordid;

		if (myStore != "") {
			myStore.load({
				params: {
					filterField: filterField,
					filterValue: filterValue
				}
			});
		}
	},

	onBeforeQuery: function (el) {

		var myComboStore = el.combo.getStore();
		if (el.combo.up('window') != undefined) {
			var myGridStore = el.combo.up('window').gridStore;
		} else if (el.combo.up('grid') != undefined) {
			var myGridStore = el.combo.up('grid').getStore();
		} else {
			var myGridStore = el.combo.getStore();
		}
		var myProxy = myComboStore.proxy.url,
			myFKColName = el.combo.name,
			withoutRecords = [];
		if (el.combo.hasOwnProperty('withoutRecordColName')) myFKColName = el.combo.withoutRecordColName;
		if (myProxy != undefined && myGridStore != undefined) {
			Ext.Array.each(myGridStore.data.items, function (cItem) {
				withoutRecords.push(cItem.data[myFKColName]);
			});
			el.combo.getStore().setProxy({
				url: myProxy,
				type: 'ajax',
				actionMethods: {
					read: 'POST'
				},
				extraParams: {
					withoutRecords: withoutRecords
				}
			});
		}
	},

	loadStoreOnTabChange: function (el) {
		me = this;
		this.timerActive = false;
		this.timerTyp = "";

		if (el.activeTab.xtype == "grid") {
			el.activeTab.getStore().load({
				params: {
					veranstaltung_fk: this.cVeranstaltung,
					artist_fk: this.cArtist,
					veranstalter_fk: this.cVeranstalter
				}
			});
		} else {
			myGrid = el.activeTab.down('grid');
			myStore = myGrid.getStore();
			if (myStore.storeId == "Bilder") {
				me.timerActive = true;
				me.timerTyp = 'bilder';
			}
			if (myStore.storeId == "Downloads") {
				me.timerActive = true;
				me.timerTyp = 'uploads';
			}
			myStore.load({
				params: {
					veranstaltung_fk: this.cVeranstaltung,
					artist_fk: this.cArtist,
					veranstalter_fk: this.cVeranstalter
				},
				callback: function (response) {
					if (myGrid.name == "Bilder" || myGrid.name == "Downloads") {
						setTimeout(function () {
							myGrid.headerCt.getGridColumns()[0].setWidth(118);
						}, 250);
					}
				}, scope: this
			});
		}

	},

	onKeyUpTextfield: function (el, a, b, c) {

		var myGrid = el.up('grid');
		var myFilter = el.getValue().toLowerCase();
		var myStore = myGrid.store;
		var opendParents = []

		if (myFilter.length > 2) {
			el.addCls('filter-yellow');
			myStore.removeFilter('filter-' + myGrid.name);
			myStore.addFilter({
				id: 'filter-' + myGrid.name,
				filterFn: function (record) {
					show = false;
					Ext.each(el.agSearchFields.split(","), function (myField) {
						if (record.data[myField] != null) {
							if (record.data[myField].toLowerCase().indexOf(myFilter) >= 0) show = true;
						}
					});
					if (show) {
						return true;
					} else {
						return false;
					}
				}
			});

			if (myStore.data.length == 1) {
				myGrid.getView().select(0);
				if (myGrid.hasOwnProperty('agLoadDetailsOnSelect') && myGrid.agLoadDetailsOnSelect != '') {
					this.loadDetailsOnGridSelect(el, myStore.data.items[0]);
				}
				setTimeout(function () {
					el.focus();
				}, 250);
			}
		} else {
			el.removeCls('filter-yellow');
			myStore.removeFilter('filter-' + myGrid.name);
		}
	},

	onBlurCombobox: function (el, record) {
		this.resetProxy(el);
		me = this;
		if (el.queryMode == "remote" && isNaN(el.getValue())) {
			if (el.name == "addVeranstalter") {
				tmpVal = el.getValue();
				var myStore = el.getStore(),
					myRow = myStore.findExact('name', tmpVal);
				if (myRow != -1) {
					myRecord = myStore.getAt(myRow);
					el.setValue(myRecord.data.recordid);
				} else {
					Ext.Msg.confirm('Veranstalter unbekannt', 'Dieser Veranstalter ist nicht in der Datenbank. Möchten Sie den Veranstalter anlegen?', function (elem) {
						if (elem === 'yes') {
							myFakeButton = el.up('form').down('button[name=addNewVeranstalter]');
							myWindow = me.myFunctions.onOpenWindow(myFakeButton, '');
							myWindow.down('textfield').setValue(tmpVal);
							myWindow.down('textfield[name=adresse]').focus();
							myWindow.down('hiddenfield[name=vkid]').setValue(me.cVeranstaltung);
							el.setValue();
						}
					}, this);
				}
			} else if (el.name == "addArtist") {

				tmpVal = el.getValue();
				var myStore = el.getStore(),
					myRow = myStore.findExact('name', tmpVal);
				if (myRow != -1) {
					myRecord = myStore.getAt(myRow);
					el.setValue(myRecord.data.recordid);
				} else {
					Ext.Msg.confirm('Künstler unbekannt', 'Dieser Künstler ist nicht in der Datenbank. Möchten Sie den Künstler anlegen?', function (elem) {
						if (elem === 'yes') {
							myFakeButton = el.up('form').down('button[name=addNewArtist]');
							myWindow = me.myFunctions.onOpenWindow(myFakeButton, '');
							myWindow.down('textfield').setValue(tmpVal);
							myWindow.down('textfield[name=adresse]').focus();
							el.setValue();
						}
					}, this);
				}

			} else {
				el.setValue();
				Ext.Msg.alert('Details', 'Bitte suchen Sie mittels Texteingabe im Feld "' + el.agFieldLabel + '" bzw. wählen Sie dann eine Option aus der Auswahlliste aus.');
			}

		}
	},

	resetProxy: function (el) {
		var myProxyURL = el.getStore().proxy.url;
		if (myProxyURL != undefined) {
			el.getStore().setProxy({
				url: myProxyURL,
				type: 'ajax',
				actionMethods: {
					read: 'POST'
				}
			});
		}
	},

	onClickButton: function (el, record) {
		var me = this;
		if (el.hasOwnProperty('windowName')) {
			myStore = el.up('form').down('grid').getStore();
			myGrid = el.up('form').down('grid');
			if (el.hasOwnProperty('gridNodeTypeForForeignKey')) {
				myGrid = el.up('form').down('grid[nodeType=' + el.gridNodeTypeForForeignKey + ']');
				myStore = myGrid.getStore();
			}
			if (!el.hasOwnProperty('nameForeignKey') || myStore.data.length > 0) {
				myWindow = this.myFunctions.onOpenWindow(el, record);
				console.log(myWindow)
				myWindow.down('textfield').focus();
				if (el.hasOwnProperty('agVerknuepfungErstellen')) {
					myWindow.down('hiddenfield[name=vkid]').setValue(me.cVeranstaltung);
				}
				if (el.hasOwnProperty('nameForeignKey')) {
					myRecord = myGrid.getSelectionModel().getCurrentPosition().record.data,
						recordID = myRecord.recordid;
					myWindow.down('hiddenfield[name=' + el.nameForeignKey + ']').setValue(recordID);
					isteditierbar = myGrid.getSelectionModel().getCurrentPosition().record.data.editierbar;
					if (isteditierbar != undefined && isteditierbar == false) {
						myWindow.down('button[name=btnSaveWindow]').setDisabled(true);
						myWindow.down('button[name=btnSaveWindowAndNew]').setDisabled(true);
						myWindow.down('button[name=btnDeleteWindow]').setDisabled(true);
					}
					if (el.nameForeignKey == 'parent_fk' && el.nodeType == 2102) {
						myWindow.down('datefield[name=von]').setValue(myRecord.von);
					}
				}
			}
			if (el.nodeType == 2102) {
				myWindow.down("checkbox[name='visible']").setValue(1)
			}
		}

		if (el.hasOwnProperty('agAction')) {
			if (el.agAction == "suchen") {
				myForm = el.up('form');
				myFields = myForm.getValues();
				myGrid = myForm.down('grid'),
					myStore = myGrid.getStore();

				myStore.load({
					params: myFields,
					callback: function (response) {
						if (response.length > 0) {
							myGrid.getView().select(0);
							if (el.hasOwnProperty('agLoadDetailsOnClick') && el.agLoadDetailsOnClick) {
								this.loadDetailsOnGridSelect(myGrid.getView(), response[0]);
							}
						}
					}, scope: this
				});

			} else if (el.agAction == "reset") {
				myForm = el.up('form');
				myFields = myForm.getValues();
				Ext.each(Object.keys(myFields), function (myField) {
					myForm.down('[name=' + myField + ']').setValue();
				});
				myForm.down('grid').getStore().removeAll();
			}
		}
		if (el.name == 'gridFilterReset') {
			el.previousSibling().setValue();
		}

		if (el.name == 'addVeranstalter') {
			if (this.cVeranstaltung == 0 || el.previousSibling().getValue() == null) {
				Ext.Msg.alert('Systemnachricht', 'Bitte wählen Sie eine Veranstaltung sowie einen Veranstalter aus.');
			} else {
				var myStore = el.up('grid').getStore();
				Ext.Ajax.request({
					url: '/modules/common/create.cfc?method=addVeranstalterToVeranstaltung',
					params: {
						veranstaltung_fk: this.cVeranstaltung,
						veranstalter_fk: el.previousSibling().getValue()
					},
					success: function (response) {
						var jsonParse = Ext.JSON.decode(response.responseText);
						if (!jsonParse['success']) {
							Ext.Msg.alert('Systemnachricht', 'Bitte melden Sie sich an.');
						} else {
							myStore.load({
								params: {
									veranstaltung_fk: me.cVeranstaltung,
								}
							});
						}
						el.previousSibling().setValue();
					}
				});
			}
		}
		if (el.name == 'addArtist' || el.name == 'addNewArtist') {
			if (this.cVeranstaltung == 0 || el.previousSibling().getValue() == null) {
				Ext.Msg.alert('Systemnachricht', 'Bitte wählen Sie eine Veranstaltung sowie einen Künstler aus.');
			} else {
				var myGrid = el.up('grid'),
					myStore = myGrid.getStore();

				Ext.Ajax.request({
					url: '/modules/common/create.cfc?method=addArtistToVeranstaltung',
					params: {
						veranstaltung_fk: this.cVeranstaltung,
						artist_fk: el.previousSibling().getValue()
					},
					success: function (response) {
						var jsonParse = Ext.JSON.decode(response.responseText);
						if (!jsonParse['success']) {
							Ext.Msg.alert('Systemnachricht', 'Bitte melden Sie sich an.');
						} else {
							myStore.load({
								params: {
									veranstaltung_fk: me.cVeranstaltung,
								},
								callback: function (res) {
									Ext.each(res, function (cRec, index) {
										if (cRec.data.recordid == jsonParse['recordid']) {
											myGrid.getView().select(index)
											myRecord = cRec;
										}
									});
									me.onDblClickGrid(myGrid.getView(), myRecord);
								}
							});
						}
						el.previousSibling().setValue();
					}
				});
			}
		}

		if (el.name == 'btnExport') {
			this.exportVeranstaltungen();
		}

	},

	onEnterSuchen: function (el) {
		mySearchButton = el.up('form').down('button[agAction=suchen]');
		this.onClickButton(mySearchButton, '');
	},

	onDblClickGrid: function (el, record) {
		var myStore = el.up('grid').getStore(),
			editierbar = true;
		if (record.data.editierbar != undefined && record.data.editierbar == false) {
			editierbar = false;
		}
		if (el.up('grid').hasOwnProperty('nameForeignKey')) {
			isteditierbar = el.up('form').down('grid').getSelectionModel().getCurrentPosition().record.data.editierbar;
			if (isteditierbar != undefined && isteditierbar == false) {
				editierbar = false;
			}
		}

		if (el.up('grid').hasOwnProperty('windowName') && (!el.up('grid').hasOwnProperty('nameForeignKey') || myStore.data.length > 0)) {

			if (editierbar) myWindow = this.myFunctions.onOpenWindow(el.up('grid'), record, '');
			if (!editierbar) {
				myWindow.down('button[name=btnSaveWindow]').setDisabled(true);
				myWindow.down('button[name=btnSaveWindowAndNew]').setDisabled(true);
				myWindow.down('button[name=btnDeleteWindow]').setDisabled(true);
			}
		}

	},

	onClickGrid: function (el, record, row) {
		var myGrid = el.up('grid');
		if (myGrid.hasOwnProperty('agLoadDetailsOnSelect') && myGrid.agLoadDetailsOnSelect != '') {
			this.loadDetailsOnGridSelect(el, record);
		}
	},

	onGridRowSelected: function (el, record, row) {

		if (el.view.up('grid').name == "veranstaltungen"  || el.view.up('grid').name == "SubVeranstaltungen") {
			this.cVeranstaltung = record.data.recordid;
			this.cArtist = 0;
			this.cVeranstalter = 0;
			Ext.Ajax.request({
				url: '/modules/common/services.cfc?method=setSession',
				params: {
					typ: 'vaid',
					id: this.cVeranstaltung,
				}
			});
			myTabPanel = el.view.up('grid').up('form').down('tabpanel');

			if (myTabPanel.activeTab.xtype == "grid") {
				myStore = myTabPanel.activeTab.getStore();
				myGrid = myTabPanel.activeTab;
			} else {
				myStore = myTabPanel.activeTab.down('grid').getStore();
				myGrid = myTabPanel.activeTab.down('grid');
			}
			if (myStore.storeId !== "SubVeranstaltungen") {
				myStore.load({

					params: {
						veranstaltung_fk: this.cVeranstaltung,
					},
					callback: function (response) {
						if (myGrid.name == "Bilder" || myGrid.name == "Downloads") {
							setTimeout(function () {
								myGrid.headerCt.getGridColumns()[0].setWidth(118);
							}, 250);
						}
					}, scope: this
				});
			}
			else if(el.view.up('grid').name !== "SubVeranstaltungen"){
				myStore.clearFilter(true);  // Clear any existing filters

				myStore.filter({
					property: 'parent_fk',
					value: this.cVeranstaltung
				});
			}
		}

		if (el.view.up('grid').name == "artist") {
			this.cArtist = record.data.recordid;
			this.cVeranstaltung = 0;
			this.cVeranstalter = 0;
			Ext.Ajax.request({
				url: '/modules/common/services.cfc?method=setSession',
				params: {
					typ: 'aid',
					id: this.cArtist,
				}
			});
			myTabPanel = el.view.up('grid').up('form').down('tabpanel');

			if (myTabPanel.activeTab.xtype == "grid") {
				myStore = myTabPanel.activeTab.getStore();
				myGrid = myTabPanel.activeTab;
			} else {
				myStore = myTabPanel.activeTab.down('grid').getStore();
				myGrid = myTabPanel.activeTab.down('grid');
			}

			myStore.load({
				params: {
					artist_fk: this.cArtist,
				},
				callback: function (response) {
					if (myGrid.name == "Bilder" || myGrid.name == "Downloads") {
						setTimeout(function () {
							myGrid.headerCt.getGridColumns()[0].setWidth(118);
						}, 250);
					}
				}, scope: this
			});
		}

		if (el.view.up('grid').name == "veranstalter") {
			this.cVeranstalter = record.data.recordid;
			this.cVeranstaltung = 0;
			this.cArtist = 0;
			Ext.Ajax.request({
				url: '/modules/common/services.cfc?method=setSession',
				params: {
					typ: 'vid',
					id: this.cVeranstalter,
				}
			});
			myTabPanel = el.view.up('grid').up('form').down('tabpanel');

			if (myTabPanel.activeTab.xtype == "grid") {
				myStore = myTabPanel.activeTab.getStore();
				myGrid = myTabPanel.activeTab;
			} else {
				myStore = myTabPanel.activeTab.down('grid').getStore();
				myGrid = myTabPanel.activeTab.down('grid');
			}

			myStore.load({
				params: {
					veranstalter_fk: this.cVeranstalter,
				},
				callback: function (response) {
					if (myGrid.name == "Bilder" || myGrid.name == "Downloads") {
						setTimeout(function () {
							myGrid.headerCt.getGridColumns()[0].setWidth(118);
						}, 250);
					}
				}, scope: this
			});
		}

	},

	loadDetailsOnGridSelect: function (el, record) {

		var myGrid = el.up('grid'),
			loadGridName = myGrid.agLoadDetailsOnSelect,
			loadGrid = el.up('grid').up('container').down('grid[name=' + loadGridName + ']'),
			loadGridStore = "";

		if (loadGrid != null) {
			loadGridStore = loadGrid.getStore();
		}
		if (loadGridStore != "") {
			loadGridStore.load({
				params: {
					filterField: myGrid.agLoadDetailsOnSelectTargetID,
					filterValue: record.data[myGrid.agLoadDetailsOnSelectSourceID]
				},
				callback: function (response) {
					if (loadGrid != "" && myGrid.hasOwnProperty('agLoadDetailsOnSelect') && loadGridName != '') {
						if (response.length > 0) {
							loadGrid.getView().select(0);
							this.loadDetailsOnGridSelect(loadGrid.getView(), response[0]);
						} else {
							loadGrid.getStore().removeAll();
							this.removeDetailsOnGridSelect(loadGrid.getView());
						}
					}
				}, scope: this
			});
		}

	},

	removeDetailsOnGridSelect: function (el) {
		var myGrid = el.up('grid'),
			loadGridName = myGrid.agLoadDetailsOnSelect,
			loadGrid = el.up('grid').up('container').down('grid[name=' + loadGridName + ']');

		if (loadGrid != null) {
			Ext.each(loadGrid.query('button'), function (cBut) {
				cBut.setDisabled(true);
			})
			loadGrid.getStore().removeAll();
			this.removeDetailsOnGridSelect(loadGrid.getView());
		}
	},

	//------------------------------------------------------------------------
	//Dokumentensuche
	//------------------------------------------------------------------------

	actionVeranstaltungen: function () {

		var myVeranstaltungenStore = this.getVeranstaltungenStore(),
			myView = this.getVeranstaltungen();
		myVeranstaltungenStore.removeFilter('filterOpened');
		myVeranstaltungenStore.load({
			callback: function (response) {
				if (response.length > 0) {
					myView.down('grid[name=veranstaltungen]').getView().select(0);
				}
				
			}
		});
		this.application.setMainView(myView);
	},

	actionArtist: function () {
		var myView = this.getArtist();
		this.getArtistStore().load({
			callback: function (response) {
				if (response.length > 0) {
					myView.down('grid[name=artist]').getView().select(0);
				}
			}
		});
		this.application.setMainView(myView);
		setTimeout(function () {
			if (myView.down('grid[name=artist]').getSelectionModel().getCurrentPosition() == undefined) {
				myView.down('grid[name=artist]').getView().select(0);
			}
		}, 500);
	},

	actionBasics: function () {
		this.getTagsStore().load();
		this.getKategorienStore().load();
		this.getTypStore().load();
		this.getRegionStore().load();
		this.application.setMainView(this.getBasics());
	},

	actionVeranstalter: function () {
		var me = this;
		var myView = this.getVeranstalter();
		var myTabPanel = myView.down('tabpanel');
		this.timerActive = false;
		this.timerTyp = "";
		this.getVeranstalterStore().load({
			callback: function (response) {
				if (response.length > 0) {
					myView.down('grid[name=veranstalter]').getView().select(0);
					me.cVeranstalter = response[0].data.recordid;
					if (myTabPanel.activeTab.xtype == "grid") {
						myTabPanel.activeTab.getStore().load({
							params: {
								veranstaltung_fk: me.cVeranstaltung,
								artist_fk: me.cArtist,
								veranstalter_fk: me.cVeranstalter
							}
						});
					} else {
						myGrid = myTabPanel.activeTab.down('grid');
						myStore = myGrid.getStore();
						if (myStore.storeId == "Bilder") {
							me.timerActive = true;
							me.timerTyp = 'bilder';
						}
						if (myStore.storeId == "Downloads") {
							me.timerActive = true;
							me.timerTyp = 'uploads';
						}
					}
				}
			}
		});
		this.application.setMainView(myView);
		setTimeout(function () {
			if (myView.down('grid[name=veranstalter]').getSelectionModel().getCurrentPosition() == undefined) {
				myView.down('grid[name=veranstalter]').getView().select(0);
			}
		}, 500);
	},

	exportVeranstaltungen: function () {
		var myView = this.getVeranstaltungen(),
			me = this,
			csvContent = '',
			noCsvSupport = ('download' in document.createElement('a')) ? false : true,
			sdelimiter = noCsvSupport ? "<td>" : "",
			edelimiter = noCsvSupport ? "</td>" : ";",
			snewLine = noCsvSupport ? "<tr>" : "",
			enewLine = noCsvSupport ? "</tr>" : "\r\n",
			printableValue = '',
			myGrid = myView.down('grid[name=veranstaltungen]'),
			myStore = myGrid.getStore();
		myVisibleColumns = [],
			myColumnLabels = {};
		disabledColumns = "opened,checked,button";

		csvContent += snewLine;

		if (myStore.data.items.length < 1) {
			Ext.Msg.alert('Systemnachricht', 'Die Ansicht entählt keine Daten und kann daher nicht exportiert werden.' + '<br /><br />');
		} else {
			// sichtbare spalten zuweisen    

			Ext.Array.push(myVisibleColumns, 'recordid');
			myColumnLabels['recordid'] = 'ID';

			Ext.Array.each(myGrid.columns, function (cCol) {
				if (disabledColumns.indexOf(cCol.dataIndex) == -1) {
					Ext.Array.push(myVisibleColumns, cCol.dataIndex);
					myColumnLabels[cCol.dataIndex] = cCol.text;
				}

			});

			Ext.Array.push(myVisibleColumns, 'parent_name');
			myColumnLabels['parent_name'] = 'Gehört zu';
			Ext.Array.push(myVisibleColumns, 'parent_fk');
			myColumnLabels['parent_fk'] = 'Parent ID';

			Ext.Object.each(myStore.data.items[0].data, function (key) {
				if (myVisibleColumns.indexOf(key) != -1) {
					csvContent += sdelimiter + myColumnLabels[key] + edelimiter;
				}
			});
			csvContent += enewLine;
			for (var i = 0; i < myStore.data.items.length; i++) {
				/* Put the record object in somma seperated format */
				csvContent += snewLine;
				Ext.Object.each(myStore.data.items[i].data, function (key, value) {
					//csvContent += sdelimiter +  i + edelimiter;
					if (myVisibleColumns.indexOf(key) != -1) {
						printableValue = ((noCsvSupport) && value == '') ? '&nbsp;' : value;
						printableValue = String(printableValue).replace(/,/g, "");
						printableValue = String(printableValue).replace(";", ",");
						printableValue = String(printableValue).replace("#", "");
						printableValue = String(printableValue).replace("\"", "'");
						printableValue = String(printableValue).replace(/(\r\n|\n|\r)/gm, "");
						if (key == "von" || key == "bis") {
							printableValue = Ext.Date.format(value, 'd.m.Y');
						}
						if (key == "uhrzeitvon" || key == "uhrzeitbis") {
							printableValue = Ext.Date.format(value, 'H:i');
						}
						if (printableValue == "null") {
							printableValue = "";
						}

						csvContent += sdelimiter + printableValue + edelimiter;
					}
				});
				csvContent += enewLine;

			}

			if ('download' in document.createElement('a')) {
				var mycsvlink = document.createElement("a");
				mycsvlink.setAttribute("href", "data:text/csv;charset=utf-8,\uFEFF" + encodeURI(csvContent));
				mycsvlink.setAttribute("download", "Veranstaltungen.csv");
				document.body.appendChild(mycsvlink);
				mycsvlink.click();
				document.body.removeChild(mycsvlink);
			} else {
				var newWin = open('windowName', "_blank");
				newWin.document.write('<table border=1>' + csvContent + '</table>');
			}
		}
	}

});
