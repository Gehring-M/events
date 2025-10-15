Ext.define('myapp.view.Locations', {
    extend: 'Ext.form.Panel',
    alias: 'widget.Locations',
    xtype: 'Locations',
    layout: {
        type: 'border'
    },
    flex: 1,
    style: 'backgroundColor: #d1d1d1',
    items: [{
        xtype: 'grid',
        title: 'Locations',
        region: 'center',
        name: 'locations',
        layout: 'fit',
        flex: 4,
        split: true,
        autoScroll: true,
        store: Ext.create('Ext.data.Store', {
            fields: [
                'id',
                'adresse',
                'name',
                'beschreibung',
                'kulturrelevant',
                'ortsname',
                'bezirksname'
            ],
            proxy: {
                type: 'ajax',
                url: '/modules/common/locations.cfc?method=fetchRegionalHighlights',
                reader: {
                    type: 'json',
                    transform: function(data) {
                        try {
                            if (!data) return data;
                            if (Ext.isArray(data)) {
                                if (data.length === 1 && data[0] && data[0].regional_highlights && Ext.isArray(data[0].regional_highlights)) {
                                    return data[0].regional_highlights;
                                }
                                return data;
                            }
                            if (data.regional_highlights && Ext.isArray(data.regional_highlights)) {
                                return data.regional_highlights;
                            }
                            for (var k in data) {
                                if (data.hasOwnProperty(k) && Ext.isArray(data[k])) return data[k];
                            }
                        } catch (e) {
                            // silent
                        }
                        return data;
                    }
                }
            },
            autoLoad: true,
            listeners: {
                load: function(store, records, successful, operation) {
                    try {
                        if (operation && operation.response && operation.response.responseText) {
                            console.log('fetchRegionalHighlights responseText:', operation.response.responseText);
                        }
                    } catch(e) {}
                    try { console.log('grid store records:', records.map(function(r){ return r.getData(); })); } catch(e) {}
                    // Normalization fallback: if reader created a single wrapper record whose raw contains the array
                    try {
                        if (successful && store.getCount() === 1 && records[0] && records[0].raw && records[0].raw.regional_highlights && Ext.isArray(records[0].raw.regional_highlights)) {
                            var inner = records[0].raw.regional_highlights;
                            if (inner && inner.length) {
                                store.loadData(inner);
                            }
                        }
                    } catch (normErr) {
                        console.log('regional highlights normalization error', normErr);
                    }
                }
            }
        }),
        columns: [
            { text: 'ID', dataIndex: 'id', width: 50 },
            { text: 'Adresse', dataIndex: 'adresse', flex: 1 },
            { text: 'Name', dataIndex: 'name', flex: 1 },
            { text: 'Beschreibung', dataIndex: 'beschreibung', flex: 1 },
            { text: 'Kulturrelevant', dataIndex: 'kulturrelevant', width: 110, renderer: function(val){ return val ? 'Ja' : 'Nein'; } },
            { text: 'Ort', dataIndex: 'ortsname', flex: 1 },
            { text: 'Bezirk', dataIndex: 'bezirksname', flex: 1 }
        ],
        tools: [{
            xtype: 'button',
            text: 'Create Location',
            width: 180,
            height: 24,
            cls: 'btn-gray',
            handler: function() {
                var grid = this.up('grid');
                var win = Ext.create('Ext.window.Window', {
                    title: 'Create Location',
                    modal: true,
                    width: 400,
                    layout: 'fit',
                    items: [{
                        xtype: 'form',
                        bodyPadding: 10,
                        defaults: { anchor: '100%' },
                        items: [
                            { xtype: 'textfield', name: 'name', fieldLabel: 'Name', allowBlank: false },
                            { xtype: 'textfield', name: 'adresse', fieldLabel: 'Adresse' },
                            {
                                xtype: 'combobox',
                                fieldLabel: 'Ort',
                                name: 'comboOrtFk',
                                store: 'LocationDropdown',
                                emptyText: 'Ort wählen...',
                                queryDelay: 700,
                                queryMode: 'local',
                                displayField: 'name',
                                valueField: 'id',
                                minChars: 2,
                                typeAhead: true,
                                hideTrigger: false,
                                listConfig: {
                                    getInnerTpl: function() {
                                        return '<div class="x-combo-list-item">{name}</div>';
                                    }
                                },
                                listeners: {
                                    expand: function(combo) {
                                        var s = combo.getStore();
                                        if (s.getCount() === 0) {
                                            s.load();
                                        }
                                        // Force a local query to populate the picker from the loaded store
                                        try {
                                            combo.doQuery('', true);
                                            var data = s.getRange().map(function(r){ return r.getData(); });
                                            console.log('Combo expand store count', s.getCount(), 'data:', data);
                                        } catch(e) {
                                            console.log('Combo expand logging error', e);
                                        }
                                    }
                                }
                            },
                            { xtype: 'textfield', name: 'beschreibung', fieldLabel: 'Beschreibung' },
                            { xtype: 'checkbox', name: 'kulturrelevant', fieldLabel: 'Kulturrelevant', inputValue: 1, uncheckedValue: 0 }
                        ],
                        buttons: [
                            {
                                text: 'Create',
                                formBind: true,
                                handler: async function (btn) {
                                    var form = btn.up('form').getForm();
                                    if (form.isValid()) {
                                        var values = form.getValues();
                                        values.kulturrelevant = values.kulturrelevant ? 1 : 0;
                                        var store = grid.getStore();
                                        // 
                                        console.log(values)
                                        const postData = {
                                            name: values.name,
                                            adresse: values.adresse,
                                            ort_fk: values.comboOrtFk,
                                            beschreibung: values.beschreibung,
                                            kulturrelevant: values.kulturrelevant
                                        }
                                        const response = await fetch('/modules/common/locations.cfc?method=createLocation', {
                                            method: 'POST',
                                            headers: {
                                                'Content-Type': 'application/json'
                                            },
                                            body: JSON.stringify(postData)
                                        })
                                        const data = await response.json()
                                        console.log(data)
                                        
                                        values.id = store.getCount() + 1;
                                        store.add(values);
                                        win.close();
                                    }
                                }
                            },
                            {
                                text: 'Cancel',
                                handler: function() { win.close(); }
                            }
                        ]
                    }]
                });
                win.show();
            }
        }]
    }]
});
