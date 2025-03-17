Ext.define('myapp.controller.Veranstaltungen', {
	extend: 'Ext.app.Controller',
	
	stores: [
		'Veranstaltungen'

	],

	views: [
		'Veranstaltungen'
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
		
		
		//viewportController ist vorbereitet, jetzt muss geschaut werden ob man angemeldet ist oder nicht 
		
		
		
		//erstelle ActivityListener
		//maxInactive = 240 Minuten, es wird jede (interval) Minute überprüft ob man ein autologout schicken muss oder nicht
		
		
	},
	
	actionloadVeranstaltung: function(id)
	{ 
		var myAuthStore = this.getVeranstaltungenStore(),
			me = this;
            console.log("lol")
        console.log(id)
	},
	

});
