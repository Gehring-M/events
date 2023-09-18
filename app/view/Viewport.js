Ext.define('oegb.view.Viewport', {
	extend: 'Ext.container.Viewport',
	
	layout: {
		type: 'border',
		align:'stretch'
	},
	
	/*style: {
		background: '#FFF'
	},*/

	initComponent : function () {
		var me = this;
	
		Ext.applyIf(me, {
			items : [
				{
					layout: {
						type: 'vbox',
						align: 'stretch'
					},
					border: false,
					minHeight: 50,
					region: 'north'
				},{
					xtype : 'container',
					region : 'center',
					layout: 'fit'
				}
			]
		});
	
		me.callParent(arguments);
	}

});