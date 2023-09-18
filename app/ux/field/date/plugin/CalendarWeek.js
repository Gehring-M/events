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
Ext.define('Ext.ux.field.date.plugin.CalendarWeek', {
    alias: 'plugin.ag_datepicker_kw',
    extend: 'Ext.AbstractPlugin',
    
    mixins: {
        observable: 'Ext.util.Observable'
    },
	
	requires: [
		'Ext.ux.field.date.picker.DateKW'
	],
	
    //configurables
    /**
     * @cfg {Boolean} agCalculateKW 
     * True um die Ausgabe der rawValue und Value an KW-Format anzupassen. Default false.
     */
    agCalculateKW: false,
    
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
    init: function(datefield) {
        var me = this;
		
		if (datefield.agCalculateKW) {
			datefield.format = 'W/Y';
		}

		Ext.override(datefield, {
			safeParse : function(value, format) {
				var me = this,
					utilDate = Ext.Date,
					result = null,
					strict = me.useStrict,
					parsedDate,
					myYearValue;
					
				// wenn ein gültiger datumswert gesetzt ist wird NICHT geparsed
				if (Ext.isDate(me.value) && me.agCalculateKW) {
					result = me.value;
				} else if (!Ext.isDate(me.value && me.agCalculateKW)) {
					parsedDate = utilDate.parse(value + ' ' + me.initTime, format + ' ' + me.initTimeFormat, strict);
					if (parsedDate) {
						// passt den Datumswert an das angezeigte Jahr an
						myYearValue = value.split('/')[1];
						myKWValue = value.split('/')[0];
						
						if (myKWValue == '53') {
							//var kwTest = utilDate.getWeekOfYear(utilDate.parse('31.12.'+myYearValue,'d.m.Y'));
							
							parsedDate = utilDate.parse('31.12.'+myYearValue,'d.m.Y');
							
							/*if (kwTest == myKWValue) {
								console.log('echte 53');
								parsedDate = utilDate.parse('31.12.'+myYearValue,'d.m.Y');
								
							} else if (kwTest === 1) {
								console.log('falsche 53');
								parsedDate = utilDate.parse('31.12.'+myYearValue,'d.m.Y');
							}*/
						}
						/*while (myYearValue > parsedDate.getFullYear()) {
							parsedDate = Ext.Date.add(parsedDate, Ext.Date.DAY, 1);
						}
						while (myYearValue < parsedDate.getFullYear()) {
							parsedDate = Ext.Date.subtract(parsedDate, Ext.Date.DAY, 1);
						}*/
						/*while (myKWValue < utilDate.getWeekOfYear(parsedDate)) {
							parsedDate = utilDate.subtract(parsedDate, Ext.Date.DAY, 1);
						}*/
						result = parsedDate;
						//result = me.value;
						
					}
				} else {
					if (utilDate.formatContainsHourInfo(format)) {
						// if parse format contains hour information, no DST adjustment is necessary
						result = utilDate.parse(value, format, strict);
					} else {
						// set time to 12 noon, then clear the time
						parsedDate = utilDate.parse(value + ' ' + me.initTime, format + ' ' + me.initTimeFormat, strict);
						if (parsedDate) {
							result = utilDate.clearTime(parsedDate);
						}
					}
				}
				
				return result;
			},
			
			onSelect: function(m, d) {
				var me = this,
					utilDate = Ext.Date,
					myKW = Ext.Date.getWeekOfYear(d),
					myMonth = d.getMonth(),
					myYear = d.getFullYear(),
					myRMASwitch = (myMonth === 11) ? utilDate.getLastDayOfMonth(d) + 1 : utilDate.getFirstDayOfMonth(d);
				
				// passt das angezeigte KW/Jahr an den Datumswert an
				if (me.agCalculateKW) {
					if (myKW === 1) {
						if (myRMASwitch == 4) {
							// ausnahme für ausserordentliche RMA-KW53
							myKW = 53;
							if (d.getDay() >= 4 || d.getDay() === 0) {
								myYear = utilDate.subtract(d, utilDate.YEAR, 1).getFullYear();
							}
						} else if (myMonth === 11) {
							myYear = utilDate.add(d, utilDate.YEAR, 1).getFullYear();
						}
					} else if(myKW >= 52 && myMonth === 0 && myRMASwitch != 4) {
						myYear = utilDate.subtract(d, utilDate.YEAR, 1).getFullYear();
					}
					
					myKW = (myKW <= 9) ? '0'.concat(myKW) : myKW;
					me.setRawValue(''.concat(myKW,'/',myYear))
					me.value = d;
				} else {
					me.setValue(d);
				}
				
				me.fireEvent('select', me, d);
				me.collapse();
			},
			
			beforeBlur : function(){
				var me = this,
					v = me.parseDate(me.getRawValue()),
					focusTask = me.focusTask;
					
				if (focusTask) {
					focusTask.cancel();
				}
				
				if (v && !me.agCalculateKW) {
					me.setValue(v);
				}
			},
			
			createPicker: function() {
				var me = this,
					format = Ext.String.format;
				return new Ext.ux.field.date.picker.DateKW({
					width: 242,
					pickerField: me,
					ownerCt: me.ownerCt,
					renderTo: document.body,
					floating: true,
					hidden: true,
					focusOnShow: true,
					minDate: me.minValue,
					maxDate: me.maxValue,
					disabledDatesRE: me.disabledDatesRE,
					disabledDatesText: me.disabledDatesText,
					disabledDays: me.disabledDays,
					disabledDaysText: me.disabledDaysText,
					format: me.format,
					showToday: me.showToday,
					startDay: me.startDay,
					minText: format(me.minText, me.formatDate(me.minValue)),
					maxText: format(me.maxText, me.formatDate(me.maxValue)),
					listeners: {
						scope: me,
						select: me.onSelect
					},
					keyNavConfig: {
						esc: function() {
							me.collapse();
						}
					}
				});
			}
		});
        
    }, // eof init
    
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