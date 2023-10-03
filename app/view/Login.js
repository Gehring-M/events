Ext.define('myapp.view.Login', {
	extend: 'Ext.form.Panel',
	alias: 'widget.loginview',
	
	layout: {
		type: 'vbox',
		align: 'stretch'
	},
	width: 500,
	title: 'Kulturbezirk Schwaz - Verwaltungsclient',
	bodyPadding: '20 20 5 20',
	frame: true,
	
	items: [
		{
			xtype: 'container',
			html: "<div style='height: 140px'><img src='/img/logo.png?t=3' style='height: 80px'><br><br><p>Bitte geben Sie hier Ihren Benutzernamen und Ihr Passwort ein.</p></div>"
		},
		{
			name: 'ameisenUsername',
			emptyText: 'Benutzername',
			anchor:'100%',
			xtype: 'textfield',
			height: 40,
			allowBlank: false,
			enableKeyEvents: true,
			listeners: {
				keypress: 
				{
					fn: function(me, e, ePts) 
					{
						if(e.getKey() == e.ENTER)
						{
							this.up().checkCompleteness();
						}
					}	
				}	
			}
		},
		{
			name: 'ameisenPassword',
			emptyText: 'Passwort',
			inputType: 'password',
			anchor:'100%',
			xtype: 'textfield',
			height: 40,
			allowBlank: false,
			enableKeyEvents: true,
			listeners: {
				keypress: 
				{
					fn: function(me, e, ePts) 
					{
						
						if(e.getKey() == e.ENTER)
						{
							this.up().checkCompleteness();
						}
					}
				}
			
			}
		},
		{
			name: 'ameisenPageLogin',
			value: 'yes',
			xtype: 'hidden'
		}

	],
	
	fbar: [
		'->',
		{
			xtype: 'button',
			text: 'Anmelden',
			width: 150,
			margin: '0 20 10 0',
			scale: 'large',
			handler: function()
			{
				this.up('form').checkCompleteness();
			}
		}
	],

	
	checkCompleteness: function()
	{
		var fields = this.getForm().getFields();
		var doSubmit = true;
		for(var index=0; index <fields.length;index++)
		{
			if(fields.getAt(index).getErrors().length > 0)
			{
				//ein pflichtfeld wurde nicht ausgewaehlt oder ein anderer fehler liget vor -> form wird nicht abgeschickt 
				doSubmit = false;
				//fokus wird auf diees Feld gelegt 
				fields.getAt(index).focus();
				break;
			}
		}
		
		if(doSubmit)
		{
			this.submit({
				scope: this,
				url: '/modules/common/retrieve.cfc?method=getAuthStatus',
				success: function(form, action) {
					
					// check ob login erfolgreich war oder nicht
					if(!action.result.hasOwnProperty('userinformation') || !action.result.userinformation.isauth)
					{
						Ext.Msg.alert('FEHLER', action.result.message);
					//	this.setLoading(false);
					}
					else
					{
						//neu laden des auth stores 
						var myAuthStore = Ext.getStore('Auth');
						myAuthStore.load({params:{}});
						//this.setLoading(false);
						document.location.href="/page.cfm?vpath=verwaltungsclient";
					}
				},
				failure: function(form, action) {
					Ext.Msg.alert('FEHLER', 'Die Anmeldung konnte nicht durchgeführt werden. Bitte überprüfen Sie Ihre Benutzerdaten.');
					this.setLoading(false);
				}
			});
			
		}
	},
	
	initComponent: function() {
		this.callParent(arguments);
	}

});