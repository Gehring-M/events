Ext.define('myapp.store.WindowFields', {
	extend: 'Ext.data.Store',
	storeId: 'SystemInfo',
	autoLoad: true,
	proxy: {
		type: 'ajax',
		timeout: 300000,
		pageParam: false, 
		startParam: false, 
		limitParam: false,
		noCache: false,
		url: 'modules/common/retrieve.cfc?method=getWindowFields',
		reader: {
			type: 'json',
		}
	},
	sorters: [
		{
			property: 'sortierung',
			direction: 'DESC'
		}
	],
	fields: [
		{
			name:'windowname'
		},{
			name:'xtype'
		},{
			name:'fieldlabel'
		},{
			name:'text'
		},{
			name:'name'
		},{
			name:'store'
		},{
			name:'displayfield'
		},{
			name:'valuefield'
		},{
			name:'mandatory'
		},{
			name:'emptytext'
		},{
			name:'value'
		},{
			name:'querymode'
		},{
			name:'height'
		},{
			name:'sortierung',
			type:'int'
		},{
			name:'mehrfachauswahl'
		},{
			name:'readonly'
		},{
			name:'hidden'
		},{
			name:'mehrfachauswahl_convert'
		},{
			name:'showenptycombobutton'
		},{
			name:'showselectallcombobutton'
		},{
			name:'flags'
		}
	]
});