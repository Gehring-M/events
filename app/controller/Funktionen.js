const env_test_url = 'https://events-test.agindo-services.info'
const env_live_url = 'https://events.agindo-services.info'


Ext.define('myapp.controller.Funktionen', {
	extend: 'Ext.app.Controller',
	
	views: [
		'WindowFields'
	],
	
	stores: [
		'Auth',
		'WindowFields'
	],
	
	init: function(){
		var authStore = this.getAuthStore();
		this.myFunctions = myapp.app.getController('Funktionen');
		this.myCommonController = myapp.app.getController('Common');
		isAdministrator = (authStore.data.items[0].data.administrator==1) ? true : false;
		
		if (this.inited) {
			return;
		}
		this.inited = true;
		
		this.control({
			'button[name=emptyCombo]': {
				click: this.emptyCombo
			},
			'button[name=selectAllCombo]': {
				click: this.selectAllCombo
			},
			'timefield': {
				blur: this.changeTimefield
			},
			'textfield': {
				keyup: this.onKeyUp
			},
			'button[name=jetzt]': {
				click: this.setNow
			}
		});
	},
	
	onKeyUp: function(el,event){
	
		if (event.getCharCode() == 13) {
	
		}
		
		
	},
		
	setNow: function(el,event){
	 	var jetzt = new Date();
		el.previousSibling().setValue(jetzt);
		el.previousSibling().previousSibling().setValue(jetzt);
	},
	
	createWindow: function(windowWidth,windowHeight,windowTitle,xtype,maxWindowHeight,nodeType,modus,el,record) {
	
		
		var agLabelWidth = 130;
		if (el.agLabelWidth != undefined) {
			agLabelWidth=el.agLabelWidth;
		}
		var btnMargin = agLabelWidth+2;
		
		// Fenster erzeugen
		var myWindow = Ext.create('Ext.window.Window', {
			title: windowTitle,
			gridStore: (el.xtype == "grid") ? el.getStore() : el.up('grid').getStore(),
			width: windowWidth,
			agLabelWidth: agLabelWidth,
			height: windowHeight,
			maxHeight: maxWindowHeight,
			nodeType: nodeType,
			overflowY: 'hidden',
			closable: (modus!=undefined && modus!='') ? false : true,
			layout: 'fit',
			modal: true,
			agRecord: el.agRecord,
			items: [{
				xtype: xtype,
			}],
			bbar:[{
				xtype:'button',
				text:'Fenster schließen',
				margin: '0 5 0 '+btnMargin,
				padding: '5 0',
				flex:1,
				cls: 'btn-green',
				name: 'gelesen',
				hidden: (modus!=undefined && modus!='') ? false : true,
				handler: function() {
			
					myWindow.close();
				}
			},{
				xtype:'button',
				text:'Abbrechen',
				margin: '5 0 0 '+btnMargin,
				padding: '5 0',
				flex:0.75,
				cls: 'btn-orange',
				hidden: (modus!=undefined && modus!='' || ( el.hasOwnProperty('agShowAbortButton')&& !el.agShowAbortButton) ) ? true : false,
				handler: function() {
	
					myWindow.close();
				}
			},{
			 	xtype:'button',
				text:'<b>Löschen</b>',
				name:'btnDeleteWindow',
				margin: (el.agDoNotShowSaveButton) ? '5 10 0 5' : '5 0 0 5',
				padding: '5 0',
				hidden: (el.agShowDeleteButton) ? false : true,
				flex:0.6,
				cls: 'btn-red',
				createNewEntry: false
			},{
			 	xtype:'button',
				text:'<b>Duplizieren</b>',
				name:'btnSaveWindowAndNew',
				margin: '5 0 0 5',
				padding: '5 0',
				hidden: (el.agShowDuplicateButton) ? false : true,
				flex:0.5,
				cls: 'btn-gray',
				createNewEntry: true
			},{
			 	xtype:'button',
				text:'<b>Speichern</b>',
				name:'btnSaveWindow',
				margin: '5 5 0 5',
				padding: '5 0',
				flex:1.2,
				hidden: (el.agDoNotShowSaveButton) ? true : false,
				cls: 'btn-green',
				createNewEntry: false
			},{
				xtype:'button',
				text:'Drucken',
				margin: '5 5 0 0',
				padding: '5 0',
				flex:0.5,
				name:'btnPrintWindow',
				hidden: true,
				handler: function() {
					myWindow.close();
				}
			}]
		});
		
		return myWindow;
		
	},
	
	getWindowFields: function (filterWindowName,rec,modus,tabname,myWindow,ckConfig) {
		
		var myFieldStore = this.getWindowFieldsStore();
		var myFields=[];
		var myRec=[];
		
		Ext.each(myFieldStore.data.items,function(cItem,index){
			if (
				cItem.data.windowname == filterWindowName 
				&& cItem.data.hidden!=1
				&& (modus==undefined || modus=='' || ((modus=='read' && cItem.data.flags.indexOf("dontshowinreadmodus")==-1) || cItem.data.xtype=="file")) 
				&& (tabname=="" || tabname!="" && tabname == cItem.data.tab)
				) {
				switch (cItem.data.xtype) {
					case 'combobox':
						if (cItem.data.mehrfachauswahl=='ja' && rec != undefined && rec[cItem.data.name]!="" && rec[cItem.data.name]?.toString().indexOf(",")!=-1) {
							myRec=[];
							Ext.each(rec[cItem.data.name].split(","), function(cid) {
						
								if (cItem.data.mehrfachauswahl_convert==1) {
									myRec.push(parseInt(cid));
								} else {
									myRec.push(cid);
								}
							});
						} else if (rec != undefined) {
						
							if (rec[cItem.data.name]!="" && cItem.data.mehrfachauswahl_convert==1) {
								myRec = parseInt(rec[cItem.data.name]);   
							} else {
								myRec = rec[cItem.data.name];
							}
						}
						
						//cItem.data.store==="Veranstaltungen" && Ext.data.StoreManager.lookup("Veranstaltungen").addFilter({	id:'isChild',filterFn:(record) =>record.data.parent_fk ===null && record.data.recordid!==rec?.recordid});
						myFields.push({
							xtype: 'fieldcontainer',
							layout: 'hbox',
							name: cItem.data.name,
							width:"100%",
							labelWidth: myWindow.agLabelWidth,
							fieldLabel: cItem.data.fieldlabel,
							disabled: (rec != undefined && rec[cItem.data.name+'_disabled'] != undefined && rec[cItem.data.name+'_disabled'] == true) ? true : false,
							margin: '0 5 5 5',
							items: [{
								anyMatch:true,
								xtype: cItem.data.xtype,
								agFieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
								name:cItem.data.name,
								//emptyCls: (cItem.data.mandatory==1) ? 'errorBorder' : '',
								emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' : (cItem.data.emptytext!='') ? cItem.data.emptytext : '',
								store: cItem.data.store,
								displayField: cItem.data.displayfield,
								valueField: cItem.data.valuefield,
								editable: (cItem.data.querymode=='local' && cItem.data.name!=="parent_fk") ? false : true,
								queryDelay: (cItem.data.querymode=='local') ? 0 : 700,
								minChars: (cItem.data.querymode=='local') ? '' : 3,
								typeAhead: (cItem.data.querymode=='local') ? false : true,
								hideTrigger: (cItem.data.querymode=='local' || cItem.data.showselectallcombobutton==1 || cItem.data.showenptycombobutton==1 ) ? false : true,
								value: (rec != undefined) ? myRec!==-1?myRec:"" : cItem.data.value!==-1?cItem.data.value:"",
								queryMode: cItem.data.querymode,
								queryParam: 'filterText',
								agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
								multiSelect: (cItem.data.mehrfachauswahl=='ja') ? true : false,
								readOnly: (cItem.data.readonly==1 || modus=='read' || (rec != undefined && cItem.data.flags != null && cItem.data.flags.indexOf("readonlyineditmodus")!=-1) ) ? true : false,
								flex: 1,
								//width: (tabname!='') ? '694px' : '',
								disabled: (rec != undefined && rec[cItem.data.name+'_disabled'] != undefined && rec[cItem.data.name+'_disabled'] == true || (rec != undefined && cItem.data.flags != null && cItem.data.flags.indexOf("disableineditmodus")!=-1)) ? true : false,
								queryCaching: false
							},{
								xtype: 'button',
								text:'Alle wählen',
								margin: '0 0 0 5',
								name: 'selectAllCombo',
								disabled: (cItem.data.readonly==1) ? true : false,
								hidden: (cItem.data.showselectallcombobutton==1 && modus!='read') ? false : true,
								tooltip:'Alle wählen'
							},{
								xtype: 'button',
								text:'X',
								margin: '0 0 0 5',
								name: 'emptyCombo',
								disabled: (cItem.data.readonly==1) ? true : false,
								hidden: (cItem.data.showenptycombobutton==1  && modus!='read') ? false : true,
								tooltip:'Wert leeren'
							}]
						});
						
					break;
					
					case 'textfield':
					case 'textarea':
					case 'displayfield':
						myFields.push({
							xtype: cItem.data.xtype,
							fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
							name:cItem.data.name,
							//emptyCls: ( cItem.data.mandatory == 1 && rec == "" || (rec != "" && cItem.data.mandatory == 1 && cItem.data.name.indexOf('passwor') == -1)) ? 'errorBorder' : '',
							emptyText: ( cItem.data.mandatory == 1 && rec == "" || (rec != "" && cItem.data.mandatory == 1 && cItem.data.name.indexOf('passwor') == -1)) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' : (cItem.data.emptytext!='') ? cItem.data.emptytext :'',
							value: (rec != undefined) ? rec[cItem.data.name] : cItem.data.value,
							height: (cItem.data.height!='') ? cItem.data.height : '', 
							inputType: (cItem.data.name.indexOf('passwor')!=-1) ? 'password' : 'text', 
							agPflichtfeld: ( cItem.data.mandatory == 1 && rec == "" || (rec != "" && cItem.data.mandatory == 1 && cItem.data.name.indexOf('passwor') == -1)) ? true : false,
							readOnly: (cItem.data.readonly==1 || modus=='read' || (rec == undefined  && cItem.data.flags != null &&  cItem.data.flags.indexOf("readonlyineditmodus")!=-1)) ? true : false,
							width: '100%',
							maxLength: (cItem.data.maxlength!='') ? cItem.data.maxlength : 10000000000000,
							enforceMaxLength: (cItem.data.maxlength!='') ? true : false,
							agCheckLength: (cItem.data.maxlength!='') ? true : false,
							enableKeyEvents: true,
							margin: (cItem.data.xtype == 'displayfield') ? '0 0 5 0' : '0 5 5 5',
							labelSeparator:(cItem.data.xtype == 'displayfield') ? '' : ':',
							baseCls:(cItem.data.xtype == 'displayfield') ? 'agDisplayField' : '',
							labelWidth: (cItem.data.xtype == 'displayfield') ? 700 : myWindow.agLabelWidth
						});
						
					break;
					
					
					case 'checkbox':
					
						myFields.push({
							xtype: cItem.data.xtype,
							fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
							name:cItem.data.name,
							value: 1,
							checked: ((rec != undefined && rec[cItem.data.name]==1) || (rec == undefined && cItem.data.value==1)) ? true : false,
							agPflichtfeld: ( cItem.data.mandatory == 1 && rec == "" || (rec != "" && cItem.data.mandatory == 1 && cItem.data.name.indexOf('passwor') == -1)) ? true : false,
							readOnly: (cItem.data.readonly==1 || modus=='read' || (rec == undefined  && cItem.data.flags != null &&  cItem.data.flags.indexOf("readonlyineditmodus")!=-1)) ? true : false,
							margin: '0 0 5 5',
							labelWidth: myWindow.agLabelWidth
						});
						
					break;
					
					case 'htmleditor':
					
							ckConfig.height = 150;
						
							var myCKEditor = Ext.create('Ext.ux.form.field.HtmlCKEditor',{
								value: (rec != undefined) ? rec[cItem.data.name] : cItem.data.value,
								ckConfig: ckConfig,
								name: cItem.data.name,
								flex: 1,
								height: '220px'
							});

							myFields.push({
								xtype: 'fieldcontainer',
								agCkEditor: true,
								width:"100%",
								labelWidth: myWindow.agLabelWidth,
								fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
								layout: 'hbox',
								height: '220px',
								name: cItem.data.name,
								agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
								margin: '0 5 5 5',
								items: [myCKEditor]
							});
						
					break;
					
					case 'numberfield':
						myFields.push({
							xtype: cItem.data.xtype,
							decimalSeparator:'.',
							fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
							labelWidth: myWindow.agLabelWidth,
							name:cItem.data.name,
							//emptyCls: (cItem.data.mandatory==1) ? 'errorBorder' : '',
							emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' : cItem.data.emptytext,
							value: (rec != undefined) ? rec[cItem.data.name] : cItem.data.value,
							hideTrigger: (cItem.data.flags.indexOf("donothidetrigger")) ? true : false,
							minValue: (cItem.data.flags.indexOf("donothidetrigger")) ? -1000000000 : 0,
							agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
							readOnly: (cItem.data.readonly==1 || modus=='read' || (rec == undefined && cItem.data.flags != null && cItem.data.flags.indexOf("readonlyineditmodus")!=-1)) ? true : false,
							decimalSeparator: ',',
							submitLocaleSeparator: false,
							margin: '0 5 5 5',
							width: '100%'
						});
					break;
					
						
					case 'datefield':
						defaultbis = "31.12.2099";
						//defaultarchiv = Ext.Date.add(new Date(),Ext.Date.MONTH, 24);
						defaultarchiv = '';
						myFields.push({
							xtype: 'fieldcontainer',
							layout: 'hbox',
							name:cItem.data.name,
							margin: '0 0 0 5',
							fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
							labelWidth: myWindow.agLabelWidth,
							width: '100%',
							items: [{
								xtype: cItem.data.xtype,
								name:cItem.data.name,
								flex: 1,
								emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' :'',
								value: (rec != undefined) ? rec[cItem.data.name] : (cItem.data.value=='heute') ? new Date() : (cItem.data.value=='defaultbis') ? defaultbis : (cItem.data.value=='defaultarchiv' && defaultarchiv != '') ? defaultarchiv : '',
								agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
								readOnly: (cItem.data.readonly==1 || modus=='read' || (rec == undefined && cItem.data.flags != null && cItem.data.flags.indexOf("readonlyineditmodus")!=-1)) ? true : false,
								plugins: [Ext.create('Ext.ux.field.date.plugin.CalendarWeek')],
								margin: '0 5 5 0',
								listeners: {
									focus: {
										fn: function(el,event) {
											el.expand();
										}
									}
								}
							},{
								xtype: 'button',
								text:'auf in 2 Jahren setzen',
								margin: '0 5 0 0',
								hidden: (cItem.data.name == "archiv_ab") ? false : true,
								listeners: {
									click: {
										fn: function(el,event) {
											inzweijahren = Ext.Date.add(new Date(),Ext.Date.MONTH, 24)
											el.previousSibling().setValue(inzweijahren);
										}
									}
								}
							},{
								xtype: 'button',
								text:'Feld leeren',
								margin: '0 5 0 0',
								hidden: (cItem.data.name == "archiv_ab") ? false : true,
								listeners: {
									click: {
										fn: function(el,event) {
											el.previousSibling().previousSibling().setValue('');
										}
									}
								}
							}]
						});
						
					break;
					
					case 'fileuploadfield':
						myFields.push({
							xtype: cItem.data.xtype,
							fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
							labelWidth: myWindow.agLabelWidth,
							name:cItem.data.name,
							//emptyCls: (cItem.data.mandatory==1) ? 'errorBorder' : '',
							emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' :'',
							value: (rec != undefined) ? rec[cItem.data.name] : cItem.data.value,
							height: (cItem.data.height!='') ? cItem.data.height : '', 
							agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
							buttonText: 'Bild wählen...',
							readOnly: (cItem.data.readonly==1 || (rec == undefined && cItem.data.flags != null && cItem.data.flags.indexOf("readonlyineditmodus")!=-1)) ? true : false,
							width: '100%',
							margin: '0 5 5 5'
						});
						
						myItemName = cItem.data.name.replace("_upload","");
						
						myFields.push({
							xtype: 'fieldcontainer',
							layout: 'hbox',
							name: myItemName,
							margin: '0 5 5 5',
							hidden: (rec != undefined && rec[myItemName]!="") ? false : true,
							items: [{
								xtype: 'image',
								margin: (rec != undefined) ? '0 0 5 136' : '0 0 0 136',
								width: (rec != undefined && rec[myItemName+'_breite']!="") ? rec[myItemName+'_breite'] : 0,
								height: (rec != undefined && rec[myItemName+'_hoehe']!="") ? rec[myItemName+'_hoehe'] : 0,
								src: (rec != undefined) ? rec[myItemName] : ""
							},{
								xtype: 'button',
								text:'Bild löschen',
								margin: '60% 0 0 15',
								name: 'pictureDelete',
								agRecord: (rec != undefined) ? rec : "",
								agField: myItemName
							}]
						});
						
					break;
					
					case 'image':
						myFields.push({
							xtype: cItem.data.xtype,
							margin: (rec != undefined) ? '0 0 5 136' : '0 0 0 136',
							width: (rec != undefined && rec[cItem.data.name+'_breite']!="") ? rec[cItem.data.name+'_breite'] : 0,
							height: (rec != undefined && rec[cItem.data.name+'_hoehe']!="") ? rec[cItem.data.name+'_hoehe'] : 0,
							src: (rec != undefined) ? rec[cItem.data.name] : ""
						});
					break;
					
					case 'datetime':
						myFields.push({
							xtype: 'fieldcontainer',
							layout: 'hbox',
							name:cItem.data.name,
							margin: '0 5 5 5',
							fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
							labelWidth: myWindow.agLabelWidth,
							width: '100%',
							items: [{
								xtype: 'datefield',
								name:cItem.data.name,
								flex: 0.5,
								//emptyCls: (cItem.data.mandatory==1) ? 'errorBorder' : '',
								emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' :'',
								value: (rec != undefined) ? rec[cItem.data.name] : (cItem.data.value=='heute') ? new Date() : '',
								agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
								readOnly: (cItem.data.readonly==1 || modus=='read' || (rec == undefined && cItem.data.flags != null && cItem.data.flags.indexOf("readonlyineditmodus")!=-1)) ? true : false,
								plugins: [Ext.create('Ext.ux.field.date.plugin.CalendarWeek')]
							},{
								xtype: 'timefield',
								name:cItem.data.name+'_time',
								flex: 0.5,
								margin: '0 0 0 5',
								increment: 15,
								emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' :'',
								value: (rec != undefined) ? rec[cItem.data.name+'_time'] : (cItem.data.value=='heute') ? new Date() : '',
								agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
								readOnly: (cItem.data.readonly==1 || modus=='read') ? true : false
							},{
								xtype: 'button',
								text:'jetzt',
								name: 'jetzt',
								margin: '0 0 0 5',
								hidden: (rec != undefined) ? true : false
							}]
						});
						
					break;
					
                    case 'timefield':
                        myFields.push({
                            xtype: cItem.data.xtype,
                            name:cItem.data.name,
							labelWidth: myWindow.agLabelWidth,
                            //editable: false,
							margin: '0 5 5 5',
                            flex: 1,
                            increment: 15,
							width:"100%",
                            emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' :'',
                            value: (rec != undefined) ? rec[cItem.data.name] : cItem.data.value,
                            agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
                            readOnly: (cItem.data.readonly==1 || modus=='read') ? true : false,
							fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
							listeners: {
								blur: function(el, value) {
									if (el.getValue() == null && el.getValue() == "") {
										Ext.Msg.alert('Systemnachricht','Die eingetragene Uhrzeit ist nicht gültig. Bitte wählen Sie einen Wert aus der Liste oder verwenden Sie folgendes Format: HH:mm');
										el.setValue();
									}
								}
							}
						});
					break;
                    
					case 'hiddenfield':
						myFields.push({
							xtype: cItem.data.xtype,
							name:cItem.data.name,
							value: (rec != undefined) ? rec[cItem.data.name] : cItem.data.value
						});
					break;
					
					case 'file':
						
						myItemName = cItem.data.name.replace("_upload","");
						
						myFields.push({
							xtype: 'fieldcontainer',
							layout: 'hbox',
							name: myItemName,
							margin: '0 0 5 5',
							items: [{	
								xtype: 'fileuploadfield',
								fieldLabel: (cItem.data.mandatory==1) ? cItem.data.fieldlabel+'*' : cItem.data.fieldlabel,
								labelWidth: myWindow.agLabelWidth,
								name:cItem.data.name,
								emptyText: (cItem.data.mandatory==1) ? (cItem.data.emptytext!='') ? cItem.data.emptytext :'Pflichtfeld' :'',
								value: (rec != undefined) ? rec[cItem.data.name] : cItem.data.value,
								height: (cItem.data.height!='') ? cItem.data.height : '', 
								agPflichtfeld: (cItem.data.mandatory==1) ? true : false,
								buttonText: 'Datei wählen...',
								readOnly: (cItem.data.readonly==1 || (rec == undefined && cItem.data.flags != null && cItem.data.flags.indexOf("readonlyineditmodus")!=-1)) ? true : false,
								hidden: (modus=='read') ? true : false,
								listeners: {
									change: function(fld, value) {
										var newValue = value.replace(/C:\\fakepath\\/g, '');
										fld.setRawValue(newValue);
									}
								}
							/*},{
								xtype: 'button',
								text: 'Download ' +cItem.data.fieldlabel,
								margin: (modus=='read') ? '0 0 0 135' :  '0 0 0 109',
								name: 'openFile',
								agRecord: (rec != undefined) ? rec : "",
								agField: myItemName,
								hidden: (rec != undefined && rec[myItemName]!="") ? false : true,
								
							},{
								xtype: 'button',
								text:'Datei löschen',
								margin: '0 0 0 115',
								name: 'deleteFile',
								record: (rec != undefined) ? rec : "",
								nodeTypeField: myItemName,
								hidden: (rec != undefined && rec[myItemName]!="" && modus!='read') ? false : true,*/
							}]
						});
						
					break;
					
				}
				
			}
			
		})
			
		return myFields;
		
	},
	
	onOpenWindow:function(el,record,modus) {
		
		var myParams = {};
		var myMandatoryFields = [];
		var myTabs = [];
		var myFields = [];
		var myComboboxen = [];
		var mandatoryMessage = "";
		var me = this;
		var myMask = new Ext.LoadMask(Ext.getBody(), {msg:"Bitte warten ..."});
		var myCommonController = myapp.app.getController('Common');
		
		// standardwerte für höhe und breite ggf. setzen
		var winwidth = (el.windowWidth!="") ? el.windowWidth : '600';
		var winheight = (el.windowHeight!="") ? el.windowHeight : '';
		var maxwinheight = (el.maxWindowHeight!="") ? el.maxWindowHeight : '800';
		var nodeType = (el.nodeType!="") ? el.nodeType : '';
		if (el.xtype=="grid") {
			var myReloadStore = el.getStore();
			var myGrid = el;
		}
		if (el.xtype=="button") {
			var myGrid = el.up('grid');
			var myReloadStore = myGrid.getStore();
		}


		// special handling for Artist store to preserve deactivated filter
		if (myReloadStore.storeId === 'Artist' || myReloadStore.storeId === 'Veranstalter' || myReloadStore.storeId === 'Veranstaltungen' || myReloadStore.storeId === 'Bilder') {
			// only reload if necessary and re-apply filter
			if (myReloadStore.getCount() === 0) {
				myReloadStore.load({
					callback: function() {
						myReloadStore.filter('deactivated', 0)
					}
				})
			}
		} else {
			// For other stores, clear filters and reload as before
			myReloadStore.clearFilter()
			myReloadStore.load()
		}
	
		// rausfinden, ob es sich um ein tab window handelt
		var myFieldStore = this.getWindowFieldsStore();
	
		Ext.each(myFieldStore.data.items,function(cItem,index){
			if (cItem.data.windowname == el.windowName) {
				if (cItem.raw.tab != "" && myTabs.indexOf(cItem.raw.tab) == -1) {
					myTabs.push(cItem.raw.tab);
				}
				
				if (cItem.data.xtype == "combobox" && cItem.data.valuefield != "") {
					myComboboxen.push(cItem.data.name);
				}
			}
		});
		
		var ckConfig = {
			height: 200,
			autoGrow_onStartup: true,
			baseFloatZIndex: 20000,
			fontSize_sizes: '8/8px;9/9px;10/10px;11/11px;12/12px;14/14px;16/16px',
			format_tags: 'p',
			linkShowAdvancedTab: false,
			linkShowTargetTab: false,
			removePlugins: 'resize'
		};

		//bei allen anderen portalen (derzeit nur formularplattform#) sind images im CK-Editor verboten
		var specialConfig = {
			disallowedContent: 'img script style table xml blockquote; *[on*]',
			toolbar: [
				//['Source'],
				//['Cut','Copy','Paste','PasteText','PasteFromWord','-','Undo','Redo'],
				//['Find','Replace','-','SelectAll','-','Scayt'],
				//['Bold','Italic','Underline','Strike','Subscript','Superscript','-','RemoveFormat'],
				//['NumberedList','BulletedList','-','Outdent','Indent','-','Blockquote','-','JustifyLeft','JustifyCenter','JustifyRight','JustifyBlock'],
				//['Link','Unlink'],
				//['Table','HorizontalRule','SpecialChar','PageBreak'],
				//['Styles'],
				//['Format'],
				//['FontSize'],
				//['BGColor'],
				//['Maximize','ShowBlocks']
				['Bold','Italic','Underline'],
				['NumberedList','BulletedList'],
				['Link','Unlink'],
				['Maximize']
			],
			on: {
				pluginsLoaded: function(evt) {
					evt.editor.dataProcessor.dataFilter.addRules({
						comment: function() {
							return false;
						}
					});
				}
			}
		};		

		ckConfig =  Ext.Object.merge(ckConfig,specialConfig);
		
		// Fenster erzeugen
		var myWindow = this.createWindow(winwidth,winheight,el.text,'windowfields',maxwinheight,nodeType,modus,el,record);
		
		if (myWindow.nodeType === 2102) {
			myWindow.width="90%"
			myWindow.down('fieldcontainer[name=windowFields]').add({
				xtype: 'tabpanel',
				border: false,
				flex: 1,
				width: "100%",
				height: '100%',
				margin:'0 5 0 0',
				margin:'0',
				name:'tabpanel_' + el.windowName
			});		
			// Main [Tab]
			myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').add({
				xtype: 'fieldcontainer',
				layout: 'vbox',
				flex: 1,
				width: '100%',
				height: '100%',
				margin: '5 5 5 0',
				title: "Main",
				name: 'container_'+el.windowName+'_main',
				listeners: {
					render: function() {
						var mainEventsStore = Ext.data.StoreManager.lookup('MainVeranstaltungen');
						console.log(mainEventsStore)
					}
				}
				//,hidden: (cTab=="ebene3") ? true : false
			});
			var myFields = me.getWindowFields(el.windowName, record.data, modus,'', myWindow, ckConfig);


			// create another field that summarizes these 
			const field_names = ['kinder', 'next', 'tipp', 'visible']
			const filtered_fields = []
			let first_occurrence = -1

			// manipulate myFields directly (just if nodetype 2102)
			myFields.forEach((field, i) => {
				const index = field_names.indexOf(field.name)
				// found element
				if (index >= 0) {
					if (first_occurrence === -1) {
						field.margin = '0 0 0 140px'
						first_occurrence = i
					}
					else {
						field.margin = '0 0 0 80px'
					}
					// manipulate current field
					field.labelWidth = 50
					filtered_fields.push(field)
					myFields = myFields.filter((field) => field.name !== field_names[index])
				}
			})

			console.log(filtered_fields)

			// create new field 
			const hbox = {
				xtype: 'fieldcontainer',
				layout: 'hbox',
				items: filtered_fields
			}
			//
			myFields.splice(first_occurrence, 0, hbox)
			myWindow.down('fieldcontainer[name=container_'+el.windowName+'_main]').add(myFields);
			// Veranstalter [Tab]
			myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').add({
					disabled: myWindow.title === "Neue Veranstaltung" || myWindow.title === "Neue Subveranstaltung",
					xtype: 'grid',
					border: true,
					flex: 1,
					title: 'Veranstalter',
					store: 'RVeranstaltungVeranstalter',
					name: 'RVeranstaltungVeranstalter',
					windowName: 'rveranstaltungveranstalter',
					text: 'Verknüpfung löschen',
					windowWidth: '200px',
					nodeType: 2111,
					minHeight: 500,
					width:"100%",
					agShowDeleteButton: true,
					agShowAbortButton: false,
					agDoNotShowSaveButton: true,
					margin: '0 0 0 0',
					viewConfig: {
						enableTextSelection: false,
					},
					columns: [
						{ text: 'Veranstalter', dataIndex: 'name', flex: 1 },
						{ text: 'Adresse', dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'PLZ', dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Ort', dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Telefon', dataIndex: 'telefon', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Email', dataIndex: 'email', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
						{ text: 'Web', dataIndex: 'web', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
					],
					bbar: [{
						xtype: 'combobox',
						width: 350,
						name: 'addVeranstalter',
						store: 'Veranstalter',
						displayField: 'name',
						valueField: 'recordid',
						queryMode: 'remote',
						queryDelay: 700,
						minChars: 3,
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
					}, {
						xtype: 'button',
						name: 'addVeranstalter',
						text: ' Veranstalter verknüpfen',
						margin: '0 5 0 0',
						width: 250,
						cls: 'btn-green'
					}, {
						xtype: 'displayfield',
						flex: 1
					}, {
						xtype: 'button',
						text: 'Veranstalter nicht gefunden? - Neuen Veranstalter hinzufügen',
						margin: '0 5 0 0',
						width: 400,
						windowWidth: '800px',
						maxWindowHeight: '90%',
						windowName: 'veranstalter',
						agVerknuepfungErstellen: true,
						nodeType: 2101,
						cls: 'btn-orange',
						name: 'addNewVeranstalter'
					}]
			});
			// Künstler [Tab]
			myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').add({
				disabled: myWindow.title === "Neue Veranstaltung",
				xtype: 'grid',
				border: true,
				flex: 1,
				title: 'Künstler',
				store: 'RVeranstaltungArtist',
				name: 'RVeranstaltungArtist',
				windowWidth: 800,
				windowHeight: '',
				maxWindowHeight: 800,
				height:500,
				width:"100%",
				windowName: 'rveranstaltungartist',
				text: 'Details bearbeiten',
				nodeType: 2110,
				agShowDeleteButton: true,
				margin: '0 0 0 0',
				viewConfig: {
					enableTextSelection: false,
				},
				columns: [
					{ text: 'Künstler', dataIndex: 'name', flex: 1, },
					{ text: 'Vorname', dataIndex: 'vorname', flex: 1, },
					{ text: 'Uhrzeit von', dataIndex: 'uhrzeitvon', width: 110, xtype: 'datecolumn', format: 'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Uhrzeit bis', dataIndex: 'uhrzeitbis', width: 110, xtype: 'datecolumn', format: 'H:i', align: 'center', menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Veranstaltungsort', dataIndex: 'veranstaltungsort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Adresse', dataIndex: 'adresse', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'PLZ', dataIndex: 'plz', width: 80, menuDisabled: true, menuDisabled: true, sortable: false },
					{ text: 'Ort', dataIndex: 'ort', flex: 1, menuDisabled: true, menuDisabled: true, sortable: false },
				],
				bbar: [{
					xtype: 'combobox',
					width: 350,
					name: 'addArtist',
					store: 'Artist',
					displayField: 'name',
					valueField: 'recordid',
					queryMode: 'remote',
					queryDelay: 700,
					minChars: 3,
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
				}, {
					xtype: 'button',
					name: 'addArtist',
					text: ' Künstler verknüpfen',
					margin: '0 5 0 0',
					width: 250,
					cls: 'btn-green'
				}, {
					xtype: 'displayfield',
					flex: 1
				}, {
					xtype: 'button',
					text: 'Künstler nicht gefunden? - Neuen Künstler hinzufügen',
					margin: '0 5 0 0',
					width: 400,
					windowWidth: '800px',
					maxWindowHeight: '90%',
					windowName: 'artist',
					nodeType: 2103,
					cls: 'btn-orange',
					name: 'addNewArtist'
				}]



			})
			// Tags [Tab]
			myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').add({
				disabled: myWindow.title === "Neue Veranstaltung",
				xtype: 'grid',
				name: 'tagzuweisung',
				minHeight: 500,
				width:"100%",
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
					width: 28, hideable: false, menuDisabled: true, resizable: false, dataIndex: 'checked', sortable: false,
					renderer: function (value, data, record) {
						data.tdCls = 'tdPointer';
						if (record.data.checked) {
							return '<img src="img/icons/checked.png" style="margin-left: 1px; margin-top: 1px">';
						} else {
							return '<img src="img/icons/unchecked.png" style="margin-left: 1px; margin-top: 1px">';
						}
					}
				}, {
					text: 'Tags', dataIndex: 'name', flex: 1, menuDisabled: true, sortable: false
				}
				],
				bbar: [{
					xtype: 'textfield',
					labelSeparator: ' ',
					labelWidth: 140,
					width: 360,
					name: 'gridFilter',
					margin: '0 0 0 0',
					labelClsExtra: 'whiteBold',
					emptyText: 'Schnellfilter nach Tags',
					enableKeyEvents: true,
					agSearchFields: 'name',
					listeners: {
						keyup: {
							fn: function (el, event) {
								if (event.getCharCode() == 27) {
									el.setValue('');
								}
							}
						}
					}
				}, {
					xtype: 'button',
					text: 'X',
					width: 27,
					height: 24,
					name: 'gridFilterReset',
					margin: '0 0 0 0',
					cls: 'btn-red'
				}, {
					xtype: 'displayfield',
					flex: 1
				}, {
					xtype: 'button',
					text: 'Neuen Tag hinzufügen',
					height: 24,
					margin: '0 5 0 0',
					width: 200,
					windowWidth: 400,
					windowHeight: '',
					maxWindowHeight: 400,
					windowName: 'tag',
					nodeType: 2106,
					cls: 'btn-orange'
				}]
			})
			// Bilder [Tab]
			myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').add( {
				disabled: myWindow.title === "Neue Veranstaltung",
				xtype: 'fieldcontainer',
				layout: 'hbox',
				margin: '0 0 0 5',
				title: 'Bilder',
				minHeight: 500,
				width:"100%",
				items: [{
					xtype: 'grid',
					border: true,
					flex: 1,
					store: 'Bilder',
					name: 'Bilder',
					height: '100%',
					windowWidth: 600,
					windowHeight: '',
					maxWindowHeight: 500,
					windowName: 'bilder',
					text: 'Bilder  bearbeiten / löschen',
					nodeType: 1,
					agShowDeleteButton: true,
					margin: '0 0 0 0',
					viewConfig: {
						enableTextSelection: false,
					},
					columns: [
						{
							text: 'Vorschau', dataIndex: 'vorschaubild', align: 'center', width: 118,
							renderer: function (value) {
								if (value != "") {
									return '<div><span></span><img src="' + value + '" class="pointer"/></div>';
								} else {
									return 'Nicht verfübar';
								}
							}
						},
						{ text: 'Hochgeladen am', dataIndex: 'createdwhen', width: 150, xtype: 'datecolumn', format: 'd.m.Y', align: 'center' },
						{ text: 'Titel', dataIndex: 'titel', flex: 1 },
						{ text: 'Beschreibung', dataIndex: 'beschreibung', flex: 1 },
						{ text: 'Auflösung', dataIndex: 'resolution', width: 110, align: 'center' },
						{
							text: 'Ansehen', align: 'center', width: 90,
							renderer: function (value, data, record) {
								data.tdCls = 'tdHover';
								return '<img src="img/eye.png" title="Diese Datei ansehen" alt="Diese Datei ansehen">';
							}
						},
						{
							text: 'Download', align: 'center', width: 90,
							renderer: function (value, data, record) {
								data.tdCls = 'tdHover';
								return '<img src="img/download.png" title="Diese Datei laden" alt="Diese Datei laden">';
							}
						}
					],
					bbar: [{
						xtype: 'textfield',
						labelSeparator: ' ',
						labelWidth: 140,
						width: 360,
						name: 'gridFilter',
						margin: '0 0 0 0',
						labelClsExtra: 'whiteBold',
						emptyText: 'Schnellfilter für Bilder',
						enableKeyEvents: true,
						agSearchFields: 'beschreibung,titel',
						listeners: {
							keyup: {
								fn: function (el, event) {
									if (event.getCharCode() == 27) {
										el.setValue('');
									}
								}
							}
						}
					}, {
						xtype: 'button',
						text: 'X',
						width: 27,
						height: 24,
						name: 'gridFilterReset',
						margin: '0 0 0 0',
						cls: 'btn-red'
					}, {
						xtype: 'displayfield',
						flex: 1

					}]
				}, {
					xtype: 'panel',
					border: false,
					height: "100%",
					margin: '0 0 0 0',
					padding: '0 0 0 0',
					width: "20%",
					html: '<iframe src="/modules/multiupload.cfm?typ=bilder&bereich=veranstaltung" width="100%" height="100%"></iframe>'
				}]

			})
			// Downloads [Tab]
			myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').add({
				disabled: myWindow.title === "Neue Veranstaltung",
				xtype: 'fieldcontainer',
				layout: 'hbox',
				margin: '0 0 0 5',
				title: 'Downloads',
				minHeight: 500,
				width: '100%',
				maxHeight: 800,
				items: [{
					xtype: 'grid',
					border: true,
					flex: 1,
					store: 'Downloads',
					name: 'Downloads',
					windowWidth: 600,
					windowHeight: '',
					maxWindowHeight: 500,
					windowName: 'downloads',
					text: 'Download bearbeiten / löschen',
					minHeight: 500,
					idth: '100%',
					nodeType: 2,
					agShowDeleteButton: true,
					margin: '0 0 0 0',
					viewConfig: {
						enableTextSelection: false,
					},

					columns: [
						{
							text: 'Vorschau', dataIndex: 'vorschaubild', align: 'center', width: 118,
							renderer: function (value) {
								return '<div style="text-align: center" ><img src="' + value + '" /></div>';
							}
						},
						{ text: 'Hochgeladen am', dataIndex: 'createdwhen', width: 150, xtype: 'datecolumn', format: 'd.m.Y', align: 'center' },
						{ text: 'Titel', dataIndex: 'titel', flex: 1 },
						{ text: 'Beschreibung', dataIndex: 'beschreibung', flex: 1 },
						{ text: 'Auflösung', dataIndex: 'resolution', width: 110, align: 'center' },
						{ text: 'Dateityp', dataIndex: 'extension', width: 80, align: 'center' },
						{
							text: 'Ansehen', align: 'center', width: 90,
							renderer: function (value, data, record) {
								if (record.data.previewable == "yes") {
									data.tdCls = 'tdHover';
									return '<img src="img/eye.png" title="Diese Datei ansehen" alt="Diese Datei ansehen">';
								} else {
									return '<img src="img/noeye.png" title="Diese Datei laden" alt="Diese Datei laden">';
								}
							}
						},
						{
							text: 'Download', align: 'center', width: 90,
							renderer: function (value, data, record) {
								data.tdCls = 'tdHover';
								return '<img src="img/download.png" title="Diese Datei laden" alt="Diese Datei laden">';
							}
						}
					],
					bbar: [{
						xtype: 'textfield',
						labelSeparator: ' ',
						labelWidth: 140,
						width: 360,
						name: 'gridFilter',
						margin: '0 0 0 0',
						labelClsExtra: 'whiteBold',
						emptyText: 'Schnellfilter für Dokumente',
						enableKeyEvents: true,
						agSearchFields: 'beschreibung,titel',
						listeners: {
							keyup: {
								fn: function (el, event) {
									if (event.getCharCode() == 27) {
										el.setValue('');
									}
								}
							}
						}
					}, {
						xtype: 'button',
						text: 'X',
						width: 27,
						height: 24,
						name: 'gridFilterReset',
						margin: '0 0 0 0',
						cls: 'btn-red'
					}, {
						xtype: 'displayfield',
						flex: 1

					}]
				}, {
					xtype: 'panel',
					border: false,
					height: "100%",
					margin: '0 0 0 0',
					padding: '0 0 0 0',
					width: "20%",
					html: '<iframe src="/modules/multiupload.cfm?typ=uploads&bereich=veranstaltung" width="100%" height="100%"></iframe>'
				}
				]
			})
			// Kontake [Tab]
			myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').add( {
				disabled: myWindow.title === "Neue Veranstaltung",
				xtype: 'fieldcontainer',
				layout: 'hbox',
				margin: '0 0 0 5',
				title: 'Kontakte',
				minHeight: 500,
				width:"100%",
				height: '100%',
				items: [{
					xtype: 'grid',
					border: true,
					flex: 1,
					store: 'RVeranstaltungKontakt',
					name: 'Kontakte',
					height: '100%',
					windowWidth: 600,
					windowHeight: '',
					maxWindowHeight: 500,
					text: 'Kontakte ansehen',
					nodeType: 2120,
					agShowDeleteButton: false,
					margin: '0 0 0 0',
					viewConfig: {
						enableTextSelection: false,
					},

					columns: [
						{ text: 'Name', dataIndex: 'name', align: 'center', width: 118 },
						{ text: 'Email', dataIndex: 'mail', width: 150 },
						{ text: 'Datenschutzhinweise', dataIndex: 'accepted_ds', flex: 1 },
						{ text: 'Datenverarbeitung', dataIndex: 'accepted_dp', flex: 1 },
					],
				}
				
				]
			})
			// // felder und values des tabs holen
			// var myFields = me.getWindowFields(el.windowName,record.data,modus,'',myWindow,ckConfig);
		
			// // felder in window einhängen
			// myWindow.down('fieldcontainer[name=windowFields]').add(myFields);
			
		}
		else{
			var myFields = me.getWindowFields(el.windowName,record.data,modus,'',myWindow,ckConfig);
		
			// felder in window einhängen
			myWindow.down('fieldcontainer[name=windowFields]').add(myFields);
		}
		
		// überprüfen, ob comboboxen mit relationen auf andere tabellen auch über die nötigen informationen verfügen
		Ext.each(myComboboxen,function(cItem,index){
		
			myField = myWindow.down('combobox[name='+cItem+']');

			myField.flex=1
			myFieldStore = myField.getStore();
			myFieldValue = myField.getValue();
			myRow = myFieldStore.findExact(myField.valueField,myFieldValue);
			if (myRow == -1) {
			//	myFieldStore.load();
			}
			
		});
		
		// buttons holen
		mySaveButton = myWindow.down('button[name=btnSaveWindow]');
		mySaveAndNewButton = myWindow.down('button[name=btnSaveWindowAndNew]');
		myDeleteButton = myWindow.down('button[name=btnDeleteWindow]');
		
		// speichern
		mySaveButton.on({
			click: {
				fn: function () {
		
					this.onSaveEntry(myMask,myWindow,el,record,myFields,mySaveButton);
				
				},
				scope: this
			}
		});
		// speichern und neu
		mySaveAndNewButton.on({
			click: {
				fn: function () {
	
					this.onSaveEntry(myMask,myWindow,el,record,myFields,mySaveAndNewButton);
				},
				scope: this
			}
		});
		
		// löschen
		myDeleteButton.on({
			click: {
				fn: function (el) {
					Ext.Msg.confirm('Datensatz löschen?', "Möchten Sie diesen Datensatz wirklich löschen?", async function (elem) {
						//
						if (elem === 'yes') {
							// additional behavior (handle images differently)
							if (myGrid.name=="Bilder") {
								const imageID = record && record.data ? record.data.recordid : null
								const url = `${env_live_url}/modules/common/veranstaltungen.cfc?method=deleteImage&imageID=${imageID}`
								const serverResponse = await fetch(url, { method: 'GET', headers: { 'Content-Type': 'application/json' } })
								const responseData = await serverResponse.json()
								
								if (responseData.success) {
									// remove image from Bilder store after successful deletion
									const bilderStore = myGrid.getStore()
									if (bilderStore && record?.data?.recordid) {
										bilderStore.remove(record)
									}
								}
								else {
									console.error(`Could not delete image with ID: ${imageID}`)
								}
								// Close the topmost window (image edit box)
								const topWindow = Ext.WindowManager.getActive();
								topWindow.close()
							}
							// previous behavior
							else {
								myMask.show();
								openedNodes = [];

								if (nodeType == 2102) {
									Ext.Array.each(myCommonController.getVeranstaltungenStore().data.items, function(cItem) {
										if (cItem.data.parent_fk=="" && cItem.data.opened) {
											openedNodes.push(cItem.data.recordid);
										}
									});
								}

								const params = {
									records: record.data.recordid,
									nodeType: nodeType
								}

								console.log(params)

								Ext.Ajax.request({
									url: '/modules/common/delete.cfc?method=deleteRecord',
									params: params,
									callback: function(a,b,response) {
										var jsonParse = Ext.JSON.decode(response.responseText);
										if (jsonParse.success) {
											// handle veranstalter soft-deletion
											if (nodeType === 2101) {
												const veranstalterStore = Ext.getStore('Veranstalter')
												// update the record
												const recordToUpdate = veranstalterStore.getById(record.data.recordid)
												if (recordToUpdate) {
													recordToUpdate.set('deactivated', 1)
													recordToUpdate.commit()
												}
												// re-apply filter to hide deactivated entries
												veranstalterStore.clearFilter()
												veranstalterStore.filter('deactivated', 0)
											}
											// handle veranstaltung soft-deletion
											if (nodeType === 2102) {
												const veranstaltungenStore = Ext.getStore('Veranstaltungen')
												// update the record
												const recordToUpdate = veranstaltungenStore.getById(record.data.recordid)
												if (recordToUpdate) {
													recordToUpdate.set('deactivated', 1)
													recordToUpdate.commit()
												}
												// re-apply filter to hide deactivated entries
												veranstaltungenStore.clearFilter()
												veranstaltungenStore.filter('deactivated', 0)
											}
											// handle artist store update after soft-deletion
											if (nodeType === 2103) {
												const artistStore = Ext.getStore('Artist')
												// update the record
												var recordToUpdate = artistStore.getById(record.data.recordid)
												if (recordToUpdate) {
													recordToUpdate.set('deactivated', 1)
													recordToUpdate.commit()
												}
												// re-apply filter to hide deactivated entries
												artistStore.clearFilter()
												artistStore.filter('deactivated', 0)
											}

											myReloadStore.reload({
												callback: function(response) {
													if (openedNodes.length > 0) {
														var tmpStore = myCommonController.getVeranstaltungenStore();
														//tmpStore.removeFilter('filterOpened');
														Ext.Array.each(tmpStore.data.items,function(cItem) {
															if (openedNodes.includes(cItem.data.recordid) || openedNodes.includes(cItem.data.parent_fk)) {
																cItem.set('opened',true);
															}
														});
														
													}
												}
											});
										
											myWindow.close();
											
										} else {
											if (jsonParse.message != "") { 
												Ext.Msg.alert('Systemnachricht',jsonParse.message);
												myWindow.close();
											}
											
										}
											
										myMask.hide();
									}
								});
							}
						}
					}, this);
				}
			}
		});

		if(record?.data?.children!==undefined){
			myWindow.down("[xtype=combobox]").up().setVisible(record?.data?.children!==undefined && record.data.children<1)
		}
		
		// Fenster anzeigen
		myWindow.show();
		
		return myWindow;

	},
	
	createGUID: function(el) {
	  function s4() {
		return Math.floor((1 + Math.random()) * 0x10000)
		  .toString(16)
		  .substring(1)
		  .toUpperCase();
	  }
	  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
		s4() + '-' + s4() + s4() + s4();
	},
	
	
	onSaveEntry: function (myMask,myWindow,el,record,myFields,mySaveButton) {
		
		var me = this;
		var reloadDetailGrid = false;
	
		myCommonController = myapp.app.getController('Common');
		myForm = myWindow.down('form');
		// objekt zum speichern der parameter erstellen
		myParams = {};
		// nodeType des aktuellen fensters mit in die params übernehmen
		myParams['nodeType'] = el.nodeType;
		// 0 für neuen eintrag oder id des aktuellen eintrags mitgeben
		myParams['instance'] = (record.data != undefined) ? record.data.recordid : 0;
		// checken, ob neuer eintrag erstellt werden soll
		if(mySaveButton.createNewEntry) {
			myParams['duplicate'] = 1;
			
		}
		// objekt für nicht ausgefüllte pflichtfelder erstellen
		myMandatoryFields = [];
	
		let vmode = window.location.href.split("#!")[1]==="/common/Veranstalter"
		// alle zu übermittelnden felder in params schreibem
		Ext.each(myFields, function(element,index) {
	
			if (element.xtype!="image" && element.xtype!="fieldcontainer") {
				// aktuellen wert finden
				myTempVal = myWindow.down(element.xtype+'[name='+element.name+']').getValue();

				// nicht ausgefüllte pflichtfelder in objekt schreiben
				if (
						(element.agPflichtfeld && (myTempVal==' ' || myTempVal=='' || myTempVal==null))
					|| 
						(element.agPflichtfeld && element.name=='email' && !me.checkMailadress(myTempVal))
					|| 
						(!element.agPflichtfeld && element.name=='email' && myTempVal!='' && !me.checkMailadress(myTempVal))
				)
				{
					myMandatoryFields.push(element.fieldLabel);
				}

			} else if (element.xtype=="fieldcontainer" && element.items.length>2 && element.items[0].xtype=="datefield") {
				
				myDay = myWindow.down(element.items[0].xtype+'[name='+element.items[0].name+']').getValue();
				myTimeField = myWindow.down(element.items[1].xtype+'[name='+element.items[1].name+']');
				myTime = null;
				if (myTimeField.xtype=="timefield") {
					myTime =  myTimeField.getValue();
				}
				
				if (myDay!=null)  {
					myParams[element.items[0].name+'_date'] = Ext.Date.format(myWindow.down(element.items[0].xtype+'[name='+element.items[0].name+']').getValue(),'Y-m-d');
				}
				if ((element.items[0].agPflichtfeld && myDay == null) || ( element.items[1].agPflichtfeld && myTime == null)) {
					myMandatoryFields.push(element.fieldLabel);
				}
			} else if (element.xtype=="fieldcontainer" && element.items.length >= 2 && element.items[0].xtype == "combobox") {
				myTempVal = myWindow.down('combobox[name='+element.items[0].name+']').getValue();
				//nicht ausgefüllte pflichtfelder in objekt schreiben
				if (element.items[0].agPflichtfeld && (myTempVal=='' || myTempVal==null))
				{
					myMandatoryFields.push(element.fieldLabel);
				}
			} else if (element.xtype=="fieldcontainer" && element.items.length==1 && element.agCkEditor) {
				myTempVal = element.items[0].getValue();
				myParams[element.items[0].name] = myTempVal;

				if (element.agPflichtfeld && (myTempVal == "" || myTempVal == null)) {
					myMandatoryFields.push(element.fieldLabel);
				}
			}

		});
		
		
		// reload store zuweisen
		if (el.xtype == "grid") {
			myReloadStore = el.getStore();
			myGrid = el;
		} else {
			myReloadStore = el.up('grid').getStore();
			myGrid = el.up('grid');
		}
		
		if (el.reloadDetailGrid) {
			reloadDetailGrid = true;
		}
		
	
		// Validate dates: von (start) must be less than or equal to bis (end)
		if (myParams.nodeType === 2102) {
			var vonField = myForm.getForm().findField('von');
			var bisField = myForm.getForm().findField('bis');
			
			if (vonField && bisField) {
				var vonValue = vonField.getValue();
				var bisValue = bisField.getValue();
				
				// Check if both dates have values
				if (vonValue && bisValue) {
					// Compare as dates - von must be before or equal to bis
					if (new Date(vonValue).getTime() > new Date(bisValue).getTime()) {
						Ext.Msg.alert('Datum Fehler', 'Das Startdatum (von) darf nicht nach dem Enddatum (bis) liegen. Bitte überprüfen Sie die Datumsangaben.');
						return;
					}
				}
			}
		}
		
		// wenn der Pflichtfeld check erfolgreich war, cfc aufrufen
		if (myMandatoryFields.length==0) {
			if(myWindow.duplicate_fk!==undefined){
				myParams.duplicate_fk=myWindow.duplicate_fk
			}
			if (myParams.nodeType === 2102 && myParams.name === undefined) {
				myParams.name = myForm.getForm().findField('name').getValue()
			}
			myForm.submit({
				url: '/modules/common/update.cfc?method=updateData',
				submitEmptyText: false,
				method: 'POST',
				params: myParams,
				success: function(form,action) {
					var jsonParse = Ext.JSON.decode(action.response.responseText);
					// update separate "MainVeranstaltungen" store after successfully modifying some data
					if (myParams.nodeType === 2102 || !myParams.parent_fk) {
						const eventID = myParams.instance
						const eventName = myParams.name
						const mainEvents = Ext.data.StoreManager.lookup('MainVeranstaltungen')
						if (mainEvents) {
							const rec = mainEvents.findRecord('recordid', eventID, 0, false, true, true)
							if (rec) {
								rec.set('name', eventName)
								rec.commit()
							}
						}
					}

					if (jsonParse.success) {
						let vid = jsonParse.recordid
						if(mySaveButton.createNewEntry){
							record.data.recordid=vid
						}
						if(vmode){
						Ext.Ajax.request({
							url: '/modules/common/create.cfc?method=addVeranstalterToVeranstaltung',
							params: {
								veranstaltung_fk: vid,
								veranstalter_fk: myWindow.down("[xtype=hiddenfield]").getValue()
							},
							success: function(response) {
								var jsonParse = Ext.JSON.decode(response.responseText);
								if (!jsonParse['success']) {
									Ext.Msg.alert('Systemnachricht','Bitte melden Sie sich an.');
								} else {
									myStore.load({
										params: {
											veranstaltung_fk:  me.cVeranstaltung,
										}
									});
								}
								el.previousSibling().setValue();
							}
						});
					}
				}
			
						myReloadStore.reload({
							callback: function(response) {
							
								if (mySaveButton.createNewEntry) {
									myWindow.duplicate_fk=0
									Ext.each(response, function(cRec,index) {
										if (cRec.data.recordid == jsonParse['recordid']) {
											myGrid.getView().select(index)
											myRecord = cRec;
										}
									});
									myWindow.setTitle("Duplikat von: "+record.data.name)
									//Ext.Msg.alert('Systemnachricht','Der Datensatz wurde erfolgreich dupliziert.');
								}
								if (myWindow.title==="Neue Veranstaltung") {
						
									Ext.each(response, function(cRec,index) {
										if (cRec.data.recordid == jsonParse['recordid']) {
											myGrid.getView().select(index)
											myRecord = cRec;
											myWindow.setTitle("Veranstaltung bearbeiten")
											console.log(myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').items.items)
											myWindow.down('tabpanel[name=tabpanel_'+el.windowName+']').items.items.forEach(x=>x.enable())
											
										}
									});
									
									//Ext.Msg.alert('Systemnachricht','Der Datensatz wurde erfolgreich dupliziert.');
								}
							}
						});
						if (!mySaveButton.createNewEntry) {
							Ext.Msg.alert('Systemnachricht',jsonParse.message);
							if(myWindow.title!=="Neue Veranstaltung"){
							myWindow.close();
							}
							
							
						} 
						
					
					myMask.hide();
				},
				failure: function(form, action) {
					var jsonParse = Ext.JSON.decode(action.response.responseText);
					Ext.Msg.alert('Systemnachricht',jsonParse.message);
					myMask.hide();
				}
			},this );

		} else {
			// text für nicht erfolgreichen pflichtfeld check erstellen
			mandatoryMessage = "Bitte füllen Sie folgende Pflichtfelder aus:<ul>";
			Ext.each(myMandatoryFields, function(element,index) {
				mandatoryMessage = mandatoryMessage + "<li>"+element+"</li>";
			});
			mandatoryMessage = mandatoryMessage + "</ul>";
			// ggf.(wenn nur email nicht befüllt wurde) systemnachricht überschreiben
			if (mandatoryMessage.toLowerCase().indexOf("mail") != -1 && myMandatoryFields.length == 1) {
				mandatoryMessage = "Die von Ihnen eingegebene E-Mail Adresse ist nicht gültig.";
			}
			// fenster ausgeben
			Ext.Msg.alert('Systemnachricht',mandatoryMessage);
			myMask.hide();
		}
	
	},
	
	
	checkMailadress: function(email) {
		var re = /^([\w-]+(?:\.[\w-]+)*)@((?:[\w-]+\.)*\w[\w-]{0,66})\.([a-z]{2,6}(?:\.[a-z]{2})?)$/i;
		return re.test(email);
	},
	
	emptyCombo: function(el) {
		el.previousSibling('combobox').setValue('');
	},
	
	selectAllCombo: function(el) {
		var myCombo =  el.previousSibling('combobox'),
		myStore = myCombo.getStore();
		myStore.load();
		selectecValues = [];
		myStore.load({
			callback: function(response){
				//myCombo.expand();
				Ext.each(response, function(cUser) {
					selectecValues.push(cUser.data.node_fk);
				});
				myCombo.setValue(selectecValues);
			},
			scope: this
		});
	},
	
	changeTimefield: function(el){
		myVal = el.rawValue;
		if(myVal.length==3){
			el.setValue(myVal.substr(0,1)+':'+myVal.substr(1,3));
		} else if (myVal.length==4) {
			el.setValue(myVal.substr(0,2)+':'+myVal.substr(2,4));
		}
	}

});
