Ext.Loader.setConfig({
    enabled: true,
	disableCaching: true
});

Ext.Loader.setPath('Ext.ux', 'app/ux');
Ext.Loader.setPath('Ext.aghelp', 'app/aghelp');

Ext.application({
	autoCreateViewport: true,
	name: 'myapp',
	controllers: [
		'History'
	],
	requires: [
		'Ext.ux.grid.column.ActionButtonColumn',
		'Ext.aghelp.Helper'
	],
	stores: [
		'Auth'
    ],
	init: function() {
		Ext.state.Manager.setProvider(new Ext.state.CookieProvider());
	},
	launch: function() {
		this.viewport = Ext.ComponentQuery.query('viewport')[0];
		this.centerRegion = this.viewport.down('[region=center]');
		this.northRegion = this.viewport.down('[region=north]');
		this.historyOldToken = '';
		this.historyNewToken = '';  
		
		//viewport initialisieren
		var c = this.getController('Viewport');
		c.init();
		
},
	
	/*
		zentrale funktion zum aufrufen von controller + method
		ist changeHistory gesetzt, wird der aufruf über den History-Controller
		umgeleitet und von dort an die funktion "runActionfromHistory" übergeben
	*/
	runAction : function (controllerName, actionName, changeHistory, fArgs) {
		
		changeHistory = changeHistory || false;
		//changeHistory = true;
		fArgs = fArgs || '';
		
		var controller = this.getController(controllerName),
			myArgs,
			myAllowExecute = true;
			
		controller.init(this);
		try {
			
			if (changeHistory) {
				var myHistory = controllerName.toLowerCase().concat('/',actionName)
				if (fArgs) {
					myHistory = myHistory.concat('/@',fArgs);
				}
				
				this.historyOldToken = Ext.History.getToken();
				this.historyNewToken = '!/'.concat(myHistory);
				
				if (this.historyOldToken != this.historyNewToken) {
					this.getController('History').setHistory(myHistory);
				} else {
					/*
					Ext.Msg.confirm('Bitte bestätigen','Sie wollen die aktuelle Seite erneut aufrufen?<br>Eventuelle Eingaben gehen dadurch verloren.',function(el){
						if (el === 'yes') {
							this.clearMainView();
							controller['action' + actionName]();
						}
					},this);
					*/
					this.clearMainView();
					controller['action' + actionName]();
					
				}
			} else {
				/*
				   checkt den datentyp der fArgs.
				   strings werden als array weitergegeben,
				   objects unverändert.
				   
				   NUR wenn !changeHistory
				*/
				switch (Ext.typeOf(fArgs)){
					case 'string':
						myArgs = fArgs.split(',');
						break;
					
					case 'object':
						myArgs = fArgs;
						break;
					
					default:
						myAllowExecute = false;
						Ext.Msg.alert('Arguments haben falschen Datentyp!','Der verwendete Datentyp "'.concat(
							Ext.typeOf(fArgs),
							'" ist nicht zulässig!<br>Aufruf für:<br>Controller: ',
							controllerName,
							'<br>Function: action',
							actionName
						));
						break;
				}
				
				if (myAllowExecute) {
					controller['action' + actionName](myArgs);
				}
			}
		}
		catch(err) {
			Ext.Msg.alert('Controller '.concat(controllerName),'Handler "action'.concat(actionName,'" nicht vorhanden!'));
			console.log(err);
			console.log(controllerName);
			console.log(actionName);
			console.log(fArgs);
		}
	},

	runActionfromHistory : function (controllerName, actionName, arguments) {
		arguments = arguments || '';
		this.historyOldToken = Ext.History.getToken();
		
		if (this.historyOldToken.split('@')[0] === this.historyNewToken.split('@')[0]) {
			this.clearMainView();
		}
		
		var controller = this.getController(controllerName);
		controller.init(this);

		try {
			controller['action' + actionName](arguments.split(','));
		}
		catch(err) {
			Ext.Msg.alert('Controller '.concat(controllerName),'Handler "action'.concat(actionName,'" nicht vorhanden (fromHistory)!'));
			console.log(err);
			console.log(controllerName);
			console.log(actionName);
			console.log(arguments);
		}
	},

	setMainView : function (view) {
		if (this.getAuthStore().data.length == 0 && view.initialCls == "ag-login-screen") {
			this.centerRegion.add(view);
		} else {
			var myAuthData = this.getAuthStore().data.items[0].data,
			mySite = ","+view.initialConfig.xtype.toLowerCase()+",";
			this.clearMainView();
			if (myAuthData.allowedSites.indexOf(mySite)!=-1 || view.cls=='ag-login-screen' || myAuthData.administrator) {
				this.centerRegion.add(view);
			} else {
				Ext.Msg.alert('Fehler','Sie haben nicht die Berechtigung diese Seite aufzurufen.');
			}
		}
		
	},
	
	clearMainView : function () {
		this.centerRegion.removeAll(true);
	}
});
