Ext.define('myapp.view.Registrierungen', {
    extend: 'Ext.form.Panel',
    alias: 'widget.Registrierungen',
    xtype: 'Approval',
    layout: {
        type: 'border'
    },
    flex: 1,
    style: 'backgroundColor: #d1d1d1',
    
    initComponent: function() {
        var me = this;
        
        Ext.applyIf(me, {
            items: [{
                xtype: 'container',
                region: 'center',
                layout: {
                    type: 'hbox',
                    align: 'stretch'
                },
                items: [{
                    xtype: 'grid',
                    title: 'Registrierungen von Künstlern',
                    name: 'artistGrid',
                    store: 'ArtistRegistrierungen',
                    flex: 1,
                    margin: '0 5 0 0',
                    autoScroll: true,
                    collapsible: false,
                    viewConfig: {
                        enableTextSelection: true
                    },
                    columns: [{
                            text: 'Status',
                            dataIndex: 'approved',
                            flex: 1,
                            align: 'center',
                            renderer: function (value, metaData, record) {
                                // get record data
                                const approved     = record.get('approved')
                                const approvedWhen = record.get('approvedwhen');
                                // check if initial registration or if rejected already
                                if (approved === 0) {
                                    if (approvedWhen === null) {
                                        return '<span style="color: orange; font-weight: bold;">Offen</span>';
                                    } else {
                                        return '<span style="color: red; font-weight: bold;">Abgelehnt</span>';
                                    }
                                } else {
                                    return '<span style="color: green; font-weight: bold;">Freigegeben</span>';
                                }
                            }
                        },{
                            text: 'Datum der Registrierung',
                            dataIndex: 'createdwhen',
                            flex: 2,
                            renderer: function(value) {
                                return value ? Ext.Date.format(new Date(value), 'j. F, Y') : 'N/A';
                            }
                        },{
                            text: 'Name',
                            dataIndex: 'name',
                            flex: 2
                        },{
                            text: 'Ort',
                            dataIndex: 'ort',
                            flex: 2
                        },{
                            text: 'Email',
                            dataIndex: 'email',
                            flex: 2
                        }
                    ],
                    dockedItems: [{
                        xtype: 'toolbar',
                        dock: 'top',
                        items: [{
                            xtype: 'textfield',
                            name: 'artistSearchField',
                            width: 200,
                            emptyText: 'Suche nach Künstlern ...',
                            listeners: {
                                change: function(field, newValue) {
                                    var grid = field.up('grid'),
                                        store = grid.getStore();
                                    
                                    store.clearFilter();
                                    
                                    if (newValue) {
                                        store.filter({
                                            property: 'name',
                                            value: newValue,
                                            anyMatch: true,
                                            caseSensitive: false
                                        });
                                    }
                                }
                            }
                        }, {
                            xtype: 'combo',
                            name: 'artistStatusFilter',
                            width: 150,
                            emptyText: 'Status Filter...',
                            store: Ext.create('Ext.data.Store', {
                                fields: ['value', 'text'],
                                data: [
                                    { value: 'all', text: 'Alle' },
                                    { value: 'offen', text: 'Offen' },
                                    { value: 'freigegeben', text: 'Freigegeben' },
                                    { value: 'abgelehnt', text: 'Abgelehnt' }
                                ]
                            }),
                            displayField: 'text',
                            valueField: 'value',
                            listeners: {
                                select: function(combo, record) {
                                    var grid = combo.up('grid'),
                                        store = grid.getStore(),
                                        value = record.get('value');
                                    
                                    // Clear all filters first
                                    store.clearFilter(true);
                                    
                                    if (value !== 'all') {
                                        // Reload store to get fresh data, then apply filter
                                        store.load({
                                            callback: function() {
                                                store.filter(function(rec) {
                                                    var approved = rec.get('approved');
                                                    var approvedWhen = rec.get('approvedwhen');
                                                    
                                                    if (value === 'offen') {
                                                        return approved == 0 && (approvedWhen === null || approvedWhen === "" || approvedWhen === undefined);
                                                    } else if (value === 'freigegeben') {
                                                        return approved == 1;
                                                    } else if (value === 'abgelehnt') {
                                                        return approved == 0 && (approvedWhen !== null && approvedWhen !== "" && approvedWhen !== undefined);
                                                    }
                                                    return false;
                                                });
                                            }
                                        });
                                    } else {
                                        // Just reload to show all records
                                        store.load();
                                    }
                                }
                            }
                        }, '->', {
                            text: 'Approve',
                            handler: function() {
                                var grid = this.up('grid'),
                                    selection = grid.getSelectionModel().getSelection();
                                if (selection.length > 0) {
                                    Ext.each(selection, function(record) {
                                        record.set('approved', 1);
                                    });
                                    Ext.Msg.alert('Success', 'Selected artists approved');
                                } else {
                                    Ext.Msg.alert('Warning', 'Please select an artist to approve');
                                }
                            }
                        }, {
                            text: 'Reject',
                            handler: function() {
                                var grid = this.up('grid'),
                                    selection = grid.getSelectionModel().getSelection();
                                if (selection.length > 0) {
                                    Ext.each(selection, function(record) {
                                        record.set('approved', 0);
                                    });
                                    Ext.Msg.alert('Success', 'Selected artists rejected');
                                } else {
                                    Ext.Msg.alert('Warning', 'Please select an artist to reject');
                                }
                            }
                        }]
                    }],
                    listeners: {
                        afterrender: function(grid) {
                            // Filter is already applied in store config
                        },
                        select: function(rowmodel, record) {
                            // Details panel removed - no action needed
                        },
                        itemdblclick: function(view, record, item, index, e, eOpts) {
                            // Create detailed information window
                            var detailWindow = Ext.create('Ext.window.Window', {
                                title: 'Artist Details: ' + (record.get('name') || 'Unknown'),
                                width: 600,
                                height: 500,
                                modal: true,
                                layout: 'fit',
                                autoScroll: true,
                                items: [{
                                    xtype: 'form',
                                    bodyPadding: 15,
                                    autoScroll: true,
                                    items: [{
                                        xtype: 'displayfield',
                                        fieldLabel: 'ID',
                                        value: record.get('id') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Registriert am',
                                        value: record.get('createdwhen') ? Ext.Date.format(new Date(record.get('createdwhen')), 'j. F, Y') : 'N/A'
                                    },{ 
                                        xtype: 'displayfield',
                                        fieldLabel: 'Name',
                                        value: record.get('name') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Vorname',
                                        value: record.get('vorname') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Ansprechperson',
                                        value: record.get('ansprechperson') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Email',
                                        value: record.get('email') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Telefon',
                                        value: record.get('telefon') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Adresse',
                                        value: record.get('adresse') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'PLZ',
                                        value: record.get('plz') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Ort',
                                        value: record.get('ort') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Website',
                                        value: record.get('web') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Link',
                                        value: record.get('link') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Beschreibung',
                                        value: record.get('beschreibung') || 'N/A',
                                        height: 80
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Geprüft',
                                        value: record.get('geprueft') ? 'Ja' : 'Nein'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Approved',
                                        value: record.get('approved') == 1 ? 'Ja' : (record.get('approved') == 0 ? 'Nein' : 'Pending')
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Approved When',
                                        value: record.get('approvedwhen') ? Ext.Date.format(new Date(record.get('approvedwhen')), 'F j, Y H:i:s') : 'N/A'
                                    }]
                                }],

                                // ############################
                                // #   DIALOG CLICK HANDLER   #
                                // ############################

                                buttons: [
                                    {
                                        text: 'Approve',
                                        record: record,
                                        handler: function (btn) {
                                            // init
                                            var rec = btn.record; 
                                            rec.set('approved', 1)
                                            rec.set('approvedwhen', Date.now())
                                            detailWindow.close()

                                            // send request to backend
                                            fetch('modules/common/update.cfc?method=changeArtistApproval', {
                                                method: 'POST',
                                                headers: {
                                                    'Content-Type': 'application/json'
                                                },
                                                body: JSON.stringify({ artistID: rec.get('id'), artistMail: rec.get('email'), approved: 1 })
                                            })
                                            .then(async (response) => {
                                                const data = await response.json()
                                                console.log(data)
                                            })
                                            .catch((error) => {
                                                console.log(error)
                                            })

                                            // notify user
                                            Ext.Msg.alert('Erfolgreich', 'Künstler wurde freigegeben')
                                        }
                                    },{
                                        text: 'Reject',
                                        record: record,
                                        handler: function (btn) {
                                            // init
                                            var rec = btn.record 
                                            rec.set('approved', 0)
                                            rec.set('approvedwhen', Date.now())
                                            detailWindow.close()

                                            // send request to backend
                                            fetch('modules/common/update.cfc?method=changeArtistApproval', {
                                                method: 'POST',
                                                headers: {
                                                    'Content-Type': 'application/json'
                                                },
                                                body: JSON.stringify({ artistID: rec.get('id'), artistMail: rec.get('email'), approved: 0 })
                                            })

                                            // notify user
                                            Ext.Msg.alert('Erfolgreich', 'Künstler wurde abgelehnt')
                                        }
                                    },{
                                        text: 'Close',
                                        handler: function() {
                                            detailWindow.close()
                                        }
                                    }
                                ]
                            });
                            detailWindow.show();
                        }
                    }
                }, {
                    xtype: 'grid',
                    title: 'Offene Registrierungen für Veranstalter',
                    name: 'organizerGrid',
                    store: 'OrganizerRegistrierungen',
                    flex: 1,
                    margin: '0 0 0 5',
                    autoScroll: true,
                    collapsible: false,
                    viewConfig: {
                        enableTextSelection: true
                    },
                    columns: [{
                            text: 'Status',
                            dataIndex: 'approved',
                            flex: 1,
                            align: 'center',
                            renderer: function (value, metaData, record) {
                                // get record data
                                const approved     = record.get('approved')
                                const approvedWhen = record.get('approvedwhen');
                                // check if initial registration or if rejected already
                                if (approved === 0) {
                                    if (approvedWhen === null) {
                                        return '<span style="color: orange; font-weight: bold;">Offen</span>';
                                    } else {
                                        return '<span style="color: red; font-weight: bold;">Abgelehnt</span>';
                                    }
                                } else {
                                    return '<span style="color: green; font-weight: bold;">Freigegeben</span>';
                                }
                            }
                    },{
                        text: 'Datum der Registrierung',
                        dataIndex: 'createdwhen',
                        flex: 2,
                        renderer: function(value) {
                            return value ? Ext.Date.format(new Date(value), 'j. F, Y') : 'N/A';
                        }
                    },{
                        text: 'Name',
                        dataIndex: 'name',
                        flex: 2
                    },{
                        text: 'Ort',
                        dataIndex: 'ort',
                        flex: 2
                    },{
                        text: 'Email',
                        dataIndex: 'email',
                        flex: 2
                    }],
                    dockedItems: [{
                        xtype: 'toolbar',
                        dock: 'top',
                        items: [{
                            xtype: 'textfield',
                            name: 'organizerSearchField',
                            width: 200,
                            emptyText: 'Search organizers...',
                            listeners: {
                                change: function(field, newValue) {
                                    var grid = field.up('grid'),
                                        store = grid.getStore();
                                    
                                    store.clearFilter();
                                    
                                    if (newValue) {
                                        store.filter({
                                            property: 'name',
                                            value: newValue,
                                            anyMatch: true,
                                            caseSensitive: false
                                        });
                                    }
                                }
                            }
                        }, {
                            xtype: 'combo',
                            name: 'organizerStatusFilter',
                            width: 150,
                            emptyText: 'Status Filter...',
                            store: Ext.create('Ext.data.Store', {
                                fields: ['value', 'text'],
                                data: [
                                    { value: 'all', text: 'Alle' },
                                    { value: 'offen', text: 'Offen' },
                                    { value: 'freigegeben', text: 'Freigegeben' },
                                    { value: 'abgelehnt', text: 'Abgelehnt' }
                                ]
                            }),
                            displayField: 'text',
                            valueField: 'value',
                            listeners: {
                                select: function(combo, record) {
                                    var grid = combo.up('grid'),
                                        store = grid.getStore(),
                                        value = record.get('value');
                                    
                                    // Clear all filters first
                                    store.clearFilter(true);
                                    
                                    if (value !== 'all') {
                                        // Reload store to get fresh data, then apply filter
                                        store.load({
                                            callback: function() {
                                                store.filter(function(rec) {
                                                    var approved = rec.get('approved');
                                                    var approvedWhen = rec.get('approvedwhen');
                                                    
                                                    if (value === 'offen') {
                                                        return approved == 0 && (approvedWhen === null || approvedWhen === "" || approvedWhen === undefined);
                                                    } else if (value === 'freigegeben') {
                                                        return approved == 1;
                                                    } else if (value === 'abgelehnt') {
                                                        return approved == 0 && (approvedWhen !== null && approvedWhen !== "" && approvedWhen !== undefined);
                                                    }
                                                    return false;
                                                });
                                            }
                                        });
                                    } else {
                                        // Just reload to show all records
                                        store.load();
                                    }
                                }
                            }
                        }, '->', {
                            text: 'Approve',
                            handler: function() {
                                var grid = this.up('grid'),
                                    selection = grid.getSelectionModel().getSelection();
                                if (selection.length > 0) {
                                    Ext.each(selection, function(record) {
                                        record.set('approved', 1);
                                    });
                                    Ext.Msg.alert('Success', 'Selected organizers approved');
                                } else {
                                    Ext.Msg.alert('Warning', 'Please select an organizer to approve');
                                }
                            }
                        }, {
                            text: 'Reject',
                            handler: function() {
                                var grid = this.up('grid'),
                                    selection = grid.getSelectionModel().getSelection();
                                if (selection.length > 0) {
                                    Ext.each(selection, function(record) {
                                        record.set('approved', 0);
                                    });
                                    Ext.Msg.alert('Success', 'Selected organizers rejected');
                                } else {
                                    Ext.Msg.alert('Warning', 'Please select an organizer to reject');
                                }
                            }
                        }]
                    }],
                    listeners: {
                        afterrender: function(grid) {
                            // Filter is already applied in store config
                        },
                        select: function(rowmodel, record) {
                            // Details panel removed - no action needed
                        },
                        itemdblclick: function(view, record, item, index, e, eOpts) {
                            // Create detailed information window
                            var detailWindow = Ext.create('Ext.window.Window', {
                                title: 'Organizer Details: ' + (record.get('name') || 'Unknown'),
                                width: 600,
                                height: 500,
                                modal: true,
                                layout: 'fit',
                                autoScroll: true,
                                items: [{
                                    xtype: 'form',
                                    bodyPadding: 15,
                                    autoScroll: true,
                                    items: [{
                                        xtype: 'displayfield',
                                        fieldLabel: 'ID',
                                        value: record.get('id') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Registriert am',
                                        value: record.get('createdwhen') ? Ext.Date.format(new Date(record.get('createdwhen')), 'j. F, Y') : 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Name',
                                        value: record.get('name') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Vorname',
                                        value: record.get('vorname') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Ansprechperson',
                                        value: record.get('ansprechperson') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Email',
                                        value: record.get('email') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Telefon',
                                        value: record.get('telefon') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Adresse',
                                        value: record.get('adresse') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'PLZ',
                                        value: record.get('plz') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Ort',
                                        value: record.get('ort') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Website',
                                        value: record.get('web') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Link',
                                        value: record.get('link') || 'N/A'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Beschreibung',
                                        value: record.get('beschreibung') || 'N/A',
                                        height: 80
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Geprüft',
                                        value: record.get('geprueft') ? 'Ja' : 'Nein'
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Approved',
                                        value: record.get('approved') == 1 ? 'Ja' : (record.get('approved') == 0 ? 'Nein' : 'Pending')
                                    },{
                                        xtype: 'displayfield',
                                        fieldLabel: 'Approved When',
                                        value: record.get('approvedwhen') ? Ext.Date.format(new Date(record.get('approvedwhen')), 'F j, Y H:i:s') : 'N/A'
                                    }]
                                }],

                                // ############################
                                // #   DIALOG CLICK HANDLER   #
                                // ############################

                                buttons: [
                                    {
                                        text: 'Approve',
                                        record: record, 
                                        handler: function(btn) {
                                            // init
                                            var rec = btn.record
                                            rec.set('approved', 1)
                                            rec.set('approvedwhen', Date.now())
                                            detailWindow.close()

                                            // Send request to backend
                                            fetch('modules/common/update.cfc?method=changeOrganizerApproval', {
                                                method: 'POST',
                                                headers: {
                                                    'Content-Type': 'application/json'
                                                },
                                                body: JSON.stringify({ organizerID: rec.get('id'), organizerMail: rec.get('email'), approved: 1 })
                                            })
                                            .then(async (response) => {
                                                const data = await response.json()
                                                console.log(data)
                                            })
                                            .catch((error) => {
                                                console.log(error)
                                            })

                                            // notify user
                                            Ext.Msg.alert('Erfolgreich', 'Veranstalter wurde freigegeben')
                                        }
                                    },{
                                        text: 'Reject',
                                        record: record, 
                                        handler: function(btn) {
                                            // init
                                            var rec = btn.record
                                            rec.set('approved', 0)
                                            rec.set('approvedwhen', Date.now())
                                            detailWindow.close()

                                            // Send request to backend
                                            fetch('modules/common/update.cfc?method=changeOrganizerApproval', {
                                                method: 'POST',
                                                headers: {
                                                    'Content-Type': 'application/json'
                                                },
                                                body: JSON.stringify({ organizerID: rec.get('id'), organizerMail: rec.get('email'), approved: 0 })
                                            })
                                            .then(async (response) => {
                                                const data = await response.json()
                                                console.log(data)
                                            })
                                            .catch((error) => {
                                                console.log(error)
                                            })

                                            // notify user
                                            Ext.Msg.alert('Erfolgreich', 'Veranstalter wurde abgelehnt')
                                        }
                                    },{
                                        text: 'Close',
                                        handler: function() {
                                            detailWindow.close()
                                        }
                                    }
                                ]
                            });
                            detailWindow.show();
                        }
                    }
                }]
            }]
        });
        
        me.callParent(arguments);
    }
});
