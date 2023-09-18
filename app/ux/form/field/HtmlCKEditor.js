/**
 * Einbindung CKEditor als neue ExtJs Component
 * xtype: "htmlckeditor".
 * ToDo: - config als parameter mitschicken
 *       - automatische höhe falls in window
 *
 */
Ext.define('Ext.ux.form.field.HtmlCKEditor', {
    extend: 'Ext.Component',
    requires: [
        'Ext.XTemplate',
        'Ext.EventObject'
    ],
    alias: 'widget.htmlckeditor',
    alternateClassName: 'Ext.HtmlCKEditor',

    childEls: [
        'innerEl', 'eventEl', 'prevEl', 'nextEl'
    ],
    
    border: false,
	
	//componentLayout: 'fit',

    renderTpl: [
        /*'<div id="{[Ext.id()]}-innerEl" role="panel">',*/
            '<textarea id="{[Ext.id()]}-editorEl" cols="80" rows="10">{value}</textarea>',
        //'</div>'
    ],

    /**
     * @cfg {String} [baseCls='x-datepicker']
     * The base CSS class to apply to this components element.
     */
    baseCls: Ext.baseCSSPrefix + 'html-ckeditor',

    /**
     * @cfg {String} [baseCls='x-datepicker']
     * The base CSS class to apply to this components element.
     */
    value: '',

    /**
     * @cfg {String} [baseCls='x-datepicker']
     * The base CSS class to apply to this components element.
     */
    ckConfig: {
		baseFloatZIndex: 20000,
		removePlugins: 'resize',
		autoMaximize_onStartup: false
	},

    /**
     * @cfg {Boolean} focusOnShow
     * True to automatically focus the picker on show.
     */
    focusOnShow: false,
	
	// @private
	// Set by other components to stop the picker focus being updated when the value changes.
	currentCKEditor: '',


    // private, inherit docs
    initComponent : function() {
        var me = this
			removePlugins = [],
			ckConfig = me.ckConfig;
		
		//console.log(me.name);
		
		me.renderTo = me.previousNode();
		//me.renderTo = Ext.getBody();
		me.value = me.value;
		me.name = me.name;
		
		Ext.Loader.loadScript(
			{
				url: 'js/ckeditor/ckeditor.js',
				onLoad: function() {
					replaceHeadLines = function( el, tools ) {
						myReplacements = me.currentCKEditor.config.format_tags.split(';')
						tools.transform(el, (myReplacements.length > 1) ? myReplacements[1] : myReplacements[0]);
					}
					
					me.currentCKEditor = CKEDITOR.replace(me.el.select('textarea').elements[0],ckConfig);

					CKEDITOR.on('dialogDefinition',function(ev){
					
						if (ev.data.name == "table" || ev.data.name == "tableProperties") {
							var definition = ev.data.definition,
								content = definition.getContents('info')
								iBorder = content.get('txtBorder'),
								iWidth = content.get('txtWidth'),
								iCellSpace = content.get('txtCellSpace'),
								iCellPad = content.get('txtCellPad');
							
							content.remove('txtHeight');
							content.remove('selHeaders');
							content.remove('cmbAlign');
							content.remove('txtCaption');
							content.remove('txtSummary');
							
							iBorder['default'] = "1";
							iBorder.label = "";
							iBorder.controlStyle = "display:none";
							iWidth['default'] = "100%";
							iWidth.label = "";
							iWidth.controlStyle = "display:none";
							iCellSpace['default'] = "0";
							iCellSpace.label = "";
							iCellSpace.controlStyle = "display:none";
							iCellPad['default'] = "0";
							iCellPad.label = "";
							iCellPad.controlStyle = "display:none";
						}
					});
					
					CKEDITOR.addCss(
						'.cke_editable table {border: 1px solid #000;border-collapse: collapse;width: 100%;margin: 1em 0;}' +
						'.cke_editable table td {border: 1px solid #000;border-collapse: collapse;padding: 2px 5px;vertical-align: top;}'
					);

					CKEDITOR.dialog.add('myCancelConfirm', function (api) {
						var dialogDefinition = {
							title : 'Bearbeitung abbrechen',
							minWidth : 260,
							minHeight : 130,
							contents : [{
									id : 'tabCancel',
									label : 'Label',
									title : 'Title',
									expand : false,
									padding : 0,
									elements : [{
											type : 'html',
											html : '<p>Möchten Sie alle Änderungen am Text verwerfen?</p>'
										}
									]
								}
							],
							buttons : [{
								type: 'button',
								label: 'JA',
								title: 'JA',
								className: 'cke_dialog_ui_button_ok',
								onClick: function(ev) {
									ev.data.dialog.hide();
									me.currentCKEditor.execCommand('cancelEdit');
								}
							},{
								type: 'button',
								label: 'Nein',
								title: 'Nein',
								onClick: function(ev) {
									ev.data.dialog.hide();
								}
							}]
						};
			
						return dialogDefinition;
					});
					
					me.currentCKEditor.on('loaded',function(ev){
						me.currentCKEditor.filter.addTransformations([
							[
								{element: 'h1',right: replaceHeadLines}
							],
							[
								{element: 'h2',right: replaceHeadLines}
							],
							[
								{element: 'h3',right: replaceHeadLines}
							],
							[
								{
									element: 'a',
									left: function(el) {
										return !el.attributes.target;
									},
									right: function(el,tools) {
										el.attributes.target = '_blank';
									}
								}
							],
							[
								{
									element: 'table',
									left: function(el) {
										return !el.attributes.width;
									},
									right: function(el){
										el.attributes.width = '100%';
										el.attributes.border = '1';
									}
								}
							]
						]);
					});
					
					if (ckConfig.autoMaximize_onStartup) {
						
						me.currentCKEditor.addCommand( 'cancelEdit', {
							exec: function( editor ) {
								editor.execCommand('maximize');
								var myBtn = Ext.getCmp(editor.config.senchaParentId).down('button:first');
								myBtn.fireEvent('click',myBtn);
							},
							context: false,
							async: true
						});
						me.currentCKEditor.addCommand( 'saveEdit', {
							exec: function( editor ) {
								editor.execCommand('maximize');
								var myBtn = Ext.getCmp(editor.config.senchaParentId).down('button:last');
								myBtn.fireEvent('click',myBtn);
							},
							context: false,
							async: true
						});
						me.currentCKEditor.addCommand('cancelconfirm', new CKEDITOR.dialogCommand('myCancelConfirm'));
						me.currentCKEditor.ui.addButton( 'doSave', {
							label: 'Änderungen übernehmen',
							command: 'saveEdit',
							toolbar: 'saveornot,100'
						});
						me.currentCKEditor.ui.addButton('doCancel', {
							label : 'Abbrechen',
							command : 'cancelconfirm',
							toolbar: 'saveornot,10'
						});
					}

					me.currentCKEditor.on('maximize',function(ev){
						myFrame = new CKEDITOR.dom.element(this.document.$.defaultView.frameElement);
						if (ev.data == 1) {
							myFrame.addClass('ag-mimick-page');
							myFrame.getParent().addClass('ag-mimick-page');
							myFrame.getFrameDocument().getBody().addClass('ag-mimick-page');
						} else if(ev.data == 2) {
							myFrame.removeClass('ag-mimick-page');
							myFrame.getParent().removeClass('ag-mimick-page');
							myFrame.getFrameDocument().getBody().removeClass('ag-mimick-page');
						}
					});
					
					me.currentCKEditor.on('instanceReady',function(ev){
						if (ev.editor.config.autoMaximize_onStartup) {
							ev.editor.execCommand('maximize');
						}
					});
				},
				scope: me
			}
		);

        me.callParent();

        me.addEvents(
            /**
             * @event select
             * Fires when a date is selected
             * @param {Ext.picker.Date} this DatePicker
             * @param {Date} date The selected date
             */
           // 'select'
        );

    },

    beforeRender: function () {
        /*
         * days array for looping through 6 full weeks (6 weeks * 7 days)
         * Note that we explicitly force the size here so the template creates
         * all the appropriate cells.
         */
		
		
        var me = this;
		me.height = me.height ;
		
        me.callParent();

       /* Ext.applyIf(me, {
            renderData: {}
        });*/
		
		
        Ext.apply(me.renderData, {
            value: me.value,
        });

        me.protoEl.unselectable();
    },

    // @private
    // @inheritdoc
    onRender : function(container, position){
        var me = this;
		
        me.callParent(arguments);
    },
	
    /**
     * Sets the value of the date field
     * @param {Date} value The date to set
     * @return {Ext.picker.Date} this
     */
    setValue : function(value){
        //this.value = Ext.Date.clearTime(value, true);
		//console.log(value);
        //return this.update(this.value);
    },

    /**
     * Gets the current selected value of the date field
     * @return {Date} The selected date
     */
    getValue : function(){
        return this.currentCKEditor.getData();
    },

    // @private
    // @inheritdoc
    beforeDestroy : function() {
        var me = this;

        if (me.rendered) {
           /* Ext.destroy(
                me.todayKeyListener,
                me.keyNav,
                me.monthPicker,
                me.monthBtn,
                me.nextRepeater,
                me.prevRepeater,
                me.todayBtn
            );*/
        }
        me.callParent();
    },

    // @private
    // @inheritdoc
    onShow: function() {
        this.callParent(arguments);
        if (this.focusOnShow) {
            this.focus();
        }
    }
});