Ext.define('myapp.controller.MainMenu', {
	extend: 'Ext.app.Controller',
	
	views: [
		'MainMenu'
	],
	
	init: function(){
		if (this.inited) {
			return;
		}
		this.inited = true;
		
		this.getMainMenuStore().addListener('load',this.mainMenuStoreLoaded,this);
				
		this.control(
			{
				'mainmenu > button': {
					mouseover: this.showButtonMenu
				},
				'mainmenu button menu': {
					mouseleave: this.hideButtonMenu
				}
			}
		);
	},
	
	stores: [
		'MainMenu',
		'Auth'
    ],
	
	showButtonMenu: function(el){
		if (el.menu) {
			el.showMenu();
		}
	},
	
	hideButtonMenu: function(el){
		el.hide();
	},

	mainMenuStoreLoaded: function(myStore){
		
		var myMenu = Ext.widget('mainmenu',{}),
		recordid = 'Alle',
		myAuthStore = this.getAuthStore();
		
		if (!myAuthStore.data.items[0].data.administrator) {
			recordid = myAuthStore.data.items[0].data.mandant;
		}
		
		function getQueryParam(name, queryString) {
			var match = RegExp(name + '=([^&]*)').exec(queryString || location.search);
			return match && decodeURIComponent(match[1]);
		}
		
		function setParam(param) {
			var queryString = Ext.Object.toQueryString(Ext.apply(Ext.Object.fromQueryString(location.search), param));
			location.search = queryString;
		}
		
		function removeParam(paramName) {
			var params = Ext.Object.fromQueryString(location.search);
			delete params[paramName];
			location.search = Ext.Object.toQueryString(params);
		}
		
		myUsername = Ext.create('Ext.form.field.Display',{
			itemId: 'myUsername',
			margin: '0 15 0 0',
			labelWidth: 100,
			fieldLabel: 'Angemeldet als: ',
			fieldStyle: 'font-weight: bold',
			value: myAuthStore.data.items[0].data.username,
			labelSeparator: ''
		});
        
		myMenu.add( 
			Ext.create('Ext.button.Button',{
				icon: 'img/icons/icon-off-24.png',
				scale: 'medium',
				name: 'btnLogout',
				tooltip: 'Abmelden',
				listeners: {
					click: {
						fn: function()
						{
							this.getController('Viewport').loadAuth(true);
						},
						scope: this
					}
				}
			})
		);
		myMenu.add('-');
		myStore.each(function(record,index){
							  
			var menuSettings = {};
			if (record.data['config']) {
				Ext.apply(menuSettings, record.data['config']);
			} else {
				menuSettings = {
					itemId: record.data['pagetitle'],
					text: record.data['pagetitle'],
					scale: 'medium',
					toggleGroup: 'mainmenu',
					margin: '0 5 0 0',
					listeners: {
						click: {
							fn: function(el){
								this.application.runAction(record.data.controller,record.data.handler, true);
							},
							scope: this
						}
					}
					
				};
			}
			
			Ext.apply(menuSettings, this.addSubmenuItems(record.data['submenuitems']));
			
			myMenu.add(menuSettings);
			
		},this);
		/*
		myMenu.add( 
			Ext.create('Ext.button.Split',{
				scale: 'medium',
				text: 'Beschlagwortung starten',
				name: 'btnTagging',
				menu: {
					plain: true,
					items: [{	
							text: ' Einem Dokument Schlagwörter zuweisen',
							itemId: 'btnTagToDoc'
						},{	
							text: 'Einem Schlagwort Dokumente zuweisen',
							itemId: 'btnDocToTag'
						}
					]
				}
			})
		);
		*/
		myMenu.add('->');
		myMenu.add(myUsername);
		
		this.application.northRegion.add([myMenu]);
		
	},
	
	addSubmenuItems: function(records) {
		
		var sMenuSettings = {};
		if (records) {
			
			sMenuSettings.menu = {
				plain: true,
				defaults: {
					margin: '1 0'
				},
				items : []
			};

			Ext.each(records, function (menuitem) {
										
				//kontrollen während Entwicklungsphase START
				var myIcon = '', myDisabled = false;
				
				if (!menuitem.submenuitems) {
					if (!menuitem['controller']) {
						myIcon = 'c-missing';
						myDisabled = true;
					} else if (!menuitem['handler']) {
						myIcon = 'h-missing';
						myDisabled = true;
					} else {
						try {
							this.getController(menuitem['controller']);
						}
						catch(err) {
							myIcon = 's-missing';
							myDisabled = true;
							console.log(err);
						}
					}
				}
				//kontrollen während Entwicklungsphase ENDE
				
				var menuitemSettings = {};
				menuitemSettings = {
					itemId : menuitem['pagetitle'],
					text : menuitem['pagetitle'],
					mcontroller: menuitem['controller'],
					mhandler: menuitem['handler'],
					disabled: myDisabled,
					iconCls: myIcon,
					listeners: {
						click: {
							fn: function(el){
								this.application.runAction(el.mcontroller, el.mhandler, true);
							},
							scope: this
						}
					}
				};
				
				//submenueinträge mit submenüs rufen keine handler auf
				if (menuitem.submenuitems) {
					delete menuitemSettings.listeners
				}
				Ext.apply(menuitemSettings, this.addSubmenuItems(menuitem.submenuitems));
				sMenuSettings.menu.items.push(menuitemSettings);

			}, this);
		}

		return sMenuSettings
		
	}
	
});
