/**
 * Ein plugin für korrekte Anzeige und Datumswerte für Datumsfelder mit Format "W/Y".
 * das Datumsformat wird vom Plugin gesetzt
 * 
 * Notes:
 * 
 * - Compatible with Ext 4.x
 * Example usage:
        @example
        var myDate = Ext.create('Ext.form.Date',{
            plugins: [{
                ptype: 'ag_datepicker_kw'
            }],
			agCalculateKW: true,
            ...
        });
 * 
 * @version 0.1 (June 18, 2014) initial.
 * @constructor
 * @param {Object} config 
 */
Ext.define('Ext.ux.form.field.display.plugin.HtmlCKEditorInline', {
    alias: 'plugin.htmlckeditorinline',
    extend: 'Ext.AbstractPlugin',
    
    mixins: {
        observable: 'Ext.util.Observable'
    },
	
    //configurables
    /**
     * @cfg {Boolean} agCalculateKW 
     * True um die Ausgabe der rawValue und Value an KW-Format anzupassen. Default false.
     */
    agCalculateKW: false,
    
	// @private
	// Set by other components to stop the picker focus being updated when the value changes.
	currentCKEditor: false,

    //properties
    
    //private
    constructor: function(){
		var me = this;
		
        me.callParent(arguments);
        // Dont pass the config so that it is not applied to 'this' again
        me.mixins.observable.constructor.call(me);
    },//eof constructor
    
    /**
     * @private
     * @param {Ext.form.field.Date} datefield
     */
    init: function(displayfield) {
        var me = this;
		
		me.mon(displayfield, 'beforerender', me.onBeforeRender, me, {single:true});
		me.mon(displayfield, 'afterrender', me.onAfterRender, me, {single:true});
		
    }, // eof init
	
	onBeforeRender: function(displayfield) {
		var me = this,
			myOwner = displayfield.ownerCt;
			forceUpdateLayout = false;

		
		

		/*displayfield.bubble(function(el){
			if (el.ui === 'pageContent') {
				return false;
			}
			
			console.log(el.getId())
			console.log(el.manageHeight)
			if (el.manageHeight) {
				el.manageHeight = false;
				forceUpdateLayout = true;
			}
		});
		
		if (forceUpdateLayout) {
			//displayfield.up('#contentCenter').updateLayout();
		}*/



		//console.log('b4');
		if (displayfield.value === '') {
			displayfield.setFieldStyle({
				backgroundColor: '#F0F0F0',
				borderRadius: '5px',
				minHeight: '32px'
			})
		}
		
	},
    
	onAfterRender : function (displayfield) {
		/*
		 * days array for looping through 6 full weeks (6 weeks * 7 days)
		 * Note that we explicitly force the size here so the template creates
		 * all the appropriate cells.
		 */
		var me = this,
			myOwner = displayfield.ownerCt;
		
		if (myOwner.manageHeight) {
			myOwner.manageHeight = false;
			/*myPanel.style = 'height:auto';
			myPanel.setBodyStyle('height:auto');*/
			myOwner.updateLayout();
		}
		
		displayfield.inputEl.set({contenteditable: true});
		if (!me.currentCKEditor) {
			Ext.Loader.loadScript(
				{
					url: 'js/ckeditor/ckeditor.js',
					onLoad: function() {
						CKEDITOR.disableAutoInline = true;
						me.currentCKEditor = CKEDITOR.inline(displayfield.inputId);
						//me.currentCKEditor = CKEDITOR.replace(me.el.select('textarea').elements[0]);
						//CKEDITOR.config.height = me.height;
						//CKEDITOR.config.autoGrow_onStartup = true;
						CKEDITOR.config.baseFloatZIndex = 20000;
						CKEDITOR.config.floatSpaceDockedOffsetX = -15;
						CKEDITOR.config.floatSpaceDockedOffsetY = 5;
						
						me.currentCKEditor.on('focus', function(ev){
							displayfield.setFieldStyle({
								backgroundColor: '#FFF'
							})
						});
						me.currentCKEditor.on('blur', function(ev){
							//displayfield.setValue(me.currentCKEditor.getData());
							displayfield.nextSibling('hidden').setValue(me.currentCKEditor.getData());
							if (me.currentCKEditor.getData() === '') {
								displayfield.setFieldStyle({
									backgroundColor: '#F0F0F0'
								})
							}
							//Ext.ComponentQuery.query('#contentCenter')[0].doLayout();
						});
					},
					scope: me
				}
			);

			
			
			
			
			
		}
	},
	
    /**
     * Destroy the plugin.  Called automatically when the component is destroyed.
     */
    destroy: function() {
        this.callParent(arguments);
        this.clearListeners();
    }, //eof destroy
    
    /**
     * Returns a properly typed result.
     * @return {Ext.tree.Panel}
     */
    getCmp: function() {
        return this.callParent(arguments);
    } //eof getCmp 
    
});//eo class

//end of file