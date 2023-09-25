Ext.define('myapp.controller.History', {
	extend: 'Ext.app.Controller',
	
	views: [
		'MainMenu'
	],
	
	init: function(){
		if (this.inited) {
			return;
		}
		this.inited = true;
		

		Ext.util.History.on('change', this.onHistoryChange, this);
		Ext.util.History.on('ready', this.onHistoryReady, this);
		
		// document zum manipulieren von z.b. title-tag
		this.domDocument = Ext.getDoc();
		this.domDocument.dom.title = 'Veranstaltungen Schwaz - Intranet Verwaltungsclient';
		
		this.MainMenu;
		this.control(
			{
				'mainmenu': {
					added: this.onMenuAdded
				}
			}
		);
	},
	stores:[
		'Auth'
	],
	
	onMenuAdded: function(el){
		
		//History wird initialisiert NACHDEM das menü geaddet wurde
		this.MainMenu = el;
		Ext.util.History.init();
		this.application.historyOldToken = Ext.History.getToken();
		myAuthStore = this.getAuthStore();
		if (myAuthStore.data.items[0].data.controller !="" && myAuthStore.data.items[0].data.handler !="") {
			myController = myAuthStore.data.items[0].data.controller;
			myHandler = myAuthStore.data.items[0].data.handler;
			
		}
		
		this.application.viewport.setLoading(false);
		if (!Ext.History.getToken()) {
			this.application.runAction(myController,myHandler, true);
			
		}
		
	},

	setHistory : function (myToken) {
		//if (oldToken === null || oldToken.search(newToken) === -1) {
		if (this.application.historyOldToken === null || this.application.historyOldToken != this.application.historyNewToken) {
			Ext.History.add(this.application.historyNewToken);
		} else if(this.application.historyOldToken === this.application.historyNewToken)  {
			this.onHistoryChange(this.application.historyNewToken);
		}
	},
	
	onHistoryChange : function (myToken) {
		if (myToken) {
			this.application.historyNewToken = myToken;
			this.setToggledMenuButton(myToken);
			var page = myToken.split("/"),
			action = '',
			arguments = '';
			if (page[0] === '!'){
				action = page[2].split("/");
				if (page[2].indexOf(':') != -1) {
					action = page[2].split(":");
				}
				if (myToken.indexOf('@') != -1) {
					arguments = myToken.split("@")[1];
				}
				this.application.runActionfromHistory(Ext.String.capitalize(page[1]),Ext.String.capitalize(action[0]),arguments);
				if (myToken.split(":").length == 2){
					var myTabPanel = this.application.centerRegion.down('tabpanel');
					myTabPanel.setActiveTab(myTabPanel.child('panel[ref='.concat(myToken.split(":")[1],']')));
				}
				this.domDocument.dom.title = 'Veranstaltungen Schwaz - Intranet Verwaltungsclient • ' + Ext.String.capitalize(page[1]) + '-' + Ext.String.capitalize(action[0]) + ((arguments) ? '@'+arguments : '');
			}
		} else {
			this.application.clearMainView();
		}
	},

	onHistoryReady: function (myHistory) {
		if (myHistory.currentToken) {
			this.onHistoryChange(myHistory.currentToken);
		}
	},
	
	extendHistoryWithTabPanel: function(tabPanel, newCard, oldCard, eOpts){
		var newToken, oldToken = Ext.History.getToken();

		if (oldToken.indexOf(':') != -1) {
			newToken = oldToken.split(':')[0].concat(':',newCard.ref);
		} else {
			newToken = oldToken.concat(':',newCard.ref);
		}
		
		if (oldToken === null || oldToken.search(newToken) === -1) {
			Ext.History.add(newToken);
		}
	},
	
	setToggledMenuButton: function(myToken) {
		var aMenuItem = myToken.split('/');
		if (aMenuItem[1]) {
			var myButton = this.MainMenu.getComponent(Ext.String.capitalize(aMenuItem[1]));
			if (myButton && !myButton.pressed) {
				myButton.toggle();
			}
		}
	}
	
});
