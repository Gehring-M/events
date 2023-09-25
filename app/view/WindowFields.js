Ext.define('myapp.view.WindowFields', {
	extend: 'Ext.form.Panel',
	alias: 'widget.windowfields',
	
	flex: 1,
	overflowY: 'auto',
	layout:'vbox',
	defaults: {
		xtype: 'textfield',
		margin: '5 0 0 0',
	},
	
	initComponent: function() {
		var me = this;
		Ext.applyIf(me, {

			items: [{
				xtype: 'fieldcontainer',
				layout: 'vbox',
				width: '100%',
				name:'windowFields',
				defaults:{
					xtype:'textfield',
					width: '100%'
				},
			}]			 

		});

		me.callParent(arguments);
	}
});