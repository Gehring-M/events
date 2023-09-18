Ext.define('oegb.view.MainMenu', {
	extend: 'Ext.toolbar.Toolbar',
	alias: 'widget.mainmenu',
	
	margin: '5 0 4',
	enableOverflow: true,

	initComponent: function() {
		var me = this;
		
		me.callParent(arguments);
	}

});