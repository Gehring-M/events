Ext.define('oegb.controller.Viewport', {
	extend: 'Ext.app.Controller',
	
	stores: [
		'MainMenu',
		'Auth'
	],

	views: [
		'Login'
	],
	
	requires: [
		'Ext.ux.ActivityMonitor',
		'Ext.ux.ExportRecords',
		'Ext.ux.grid.column.Component'
	],
	
	refs: [
		{
			ref: 'loginview',
			selector: 'loginview',
			xtype: 'loginview',
			autoCreate: true
		}
	],
	
	init: function(application) {
		
		if (this.inited) {
			return;
		}
		this.inited = true;
		
		// handler der sicherstellt, dass beim springen mit den browserbuttons
		// keine lademasken von div. views hängenbleiben.
		// erfordert dass sämtliche FullScreen Masken nicht per "new Ext.LoadMask(Ext.getBody())"
		// sondern per "this.application.viewport.setLoading()" eingehängt werden
		//this.application.centerRegion.addListener('beforeadd',this.onCenterRemove,this,{single:true});
		//this.application.centerRegion.addListener('remove',this.onCenterRemove,this);
		this.getAuthStore().addListener('load',this.checkAuth,this);
		
		//viewportController ist vorbereitet, jetzt muss geschaut werden ob man angemeldet ist oder nicht 
		this.loadAuth();
		
		
		//erstelle ActivityListener
		//maxInactive = 240 Minuten, es wird jede (interval) Minute überprüft ob man ein autologout schicken muss oder nicht
		Ext.ux.ActivityMonitor.init({ 
			verbose : false,
			maxInactive: (1000 * 60 * 240),
			interval: (1000 * 60 * 1),
			oegb: this.application 
		});
		Ext.ux.ActivityMonitor.start();
		//höre auf das event zum Autologout, wenn das event gefeuert wird -> logout	
		this.application.on({
			autologout: function(){
				this.getController('Viewport').loadAuth(true);
			} 
		});
		
	},
	
	loadAuth: function(doLogout)
	{ 
		var myAuthStore = this.getAuthStore(),
			me = this;
		if (doLogout) {
			myAuthStore.load({
				params: {ameisenLogout: true},
			});
			document.location.href=window.location.origin+window.location.pathname+window.location.search;
			
		} else {
			myAuthStore.load({});
		}
	},
	
	checkAuth: function(myAuthStore, myRecords)
	{
		if(myAuthStore.getCount()== 1 && myAuthStore.getAt(0).get('isauth') == true)
		{
			// wenn man angemeldet ist
			//es wird dem MainMenu Controller initialisiert, diese lädt dann auch gleich das Menü
			var m = this.getController('MainMenu');
			m.init();
			
			this.application.northRegion.show();
			this.getMainMenuStore().load();
		}
		else
		{
			
			this.application.viewport.setLoading(false);
			
			// wenn man nicht angemeldet ist
			var myLoginContainer = Ext.create('Ext.container.Container',{
				cls: 'ag-login-screen',
				listeners: {
					boxready: {
						fn: this.onLoginAdded,
						scope: this
					}
				}
			});
			
			myLoginContainer.add(this.getLoginView({itemId:'loginContainer'}));
			this.application.setMainView(myLoginContainer);

			this.application.northRegion.removeAll();
			this.application.northRegion.hide();
			
			var myRegionEast = this.application.viewport.down('[region=east]');
			if (myRegionEast) {
				this.application.viewport.remove(myRegionEast);
			}
		}
	},
	
	onLoginAdded : function (view) {
		view.down('form').center();
	},

	onCenterRemove: function(el) {
		this.application.viewport.setLoading(false);
	}
});
