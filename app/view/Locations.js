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
                'bezirksname',
                'aktiv'
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
            { text: 'Aktiv', dataIndex: 'aktiv', width: 80, renderer: function(val){ return val ? 'Ja' : 'Nein'; } },
            { text: 'Beschreibung', dataIndex: 'beschreibung', flex: 1 },
            { text: 'Kulturrelevant', dataIndex: 'kulturrelevant', width: 110, renderer: function(val){ return val ? 'Ja' : 'Nein'; } },
            { text: 'Ort', dataIndex: 'ortsname', flex: 1 },
            { text: 'Bezirk', dataIndex: 'bezirksname', flex: 1 }
        ],
        listeners: {
            itemdblclick: function(view, record) {
                var grid = view.up('grid');
                var win = Ext.create('Ext.window.Window', {
                    title: 'Edit Location',
                    modal: true,
                    width: 800,
                    height: 520,
                    layout: 'fit',
                    items: [{
                        xtype: 'tabpanel',
                        items: [{
                            title: 'Edit',
                            xtype: 'form',
                            bodyPadding: 10,
                            defaults: { anchor: '100%' },
                            items: [
                                { xtype: 'hiddenfield', name: 'id' },
                                { xtype: 'textfield', name: 'name', fieldLabel: 'Name', allowBlank: false },
                                { xtype: 'textfield', name: 'adresse', fieldLabel: 'Adresse' },
                                { xtype: 'textareafield', name: 'beschreibung', fieldLabel: 'Beschreibung' },
                                { xtype: 'checkbox', name: 'kulturrelevant', fieldLabel: 'Kulturrelevant', inputValue: 1, uncheckedValue: 0 },
                                { xtype: 'checkbox', name: 'aktiv', fieldLabel: 'Aktiv', inputValue: 1, uncheckedValue: 0 }
                            ],
                            buttons: [{
                                text: 'Save',
                                formBind: true,
                                handler: async function(btn) {
                                    var form = btn.up('form').getForm();
                                    if (!form.isValid()) return;
                                    var vals = form.getValues();
                                    // normalize checkboxes
                                    vals.kulturrelevant = vals.kulturrelevant ? 1 : 0;
                                    vals.aktiv = vals.aktiv ? 1 : 0;
                                    // post update to backend
                                    try {
                                        const resp = await fetch('/modules/common/locations.cfc?method=updateLocation', {
                                            method: 'POST',
                                            headers: { 'Content-Type': 'application/json' },
                                            body: JSON.stringify(vals)
                                        });
                                        const data = await resp.json();
                                        // update record in store
                                        record.set(data);
                                        grid.getView().refresh();
                                        win.close();
                                    } catch (err) {
                                        Ext.Msg.alert('Error', 'Save failed');
                                    }
                                }
                            },{
                                text: 'Cancel', handler: function(){ win.close(); }
                            }]
                        },{
                            title: 'Images',
                            xtype: 'panel',
                            layout: { type: 'hbox', align: 'stretch' },
                            defaults: { margin: 8 },
                            bodyStyle: 'background:transparent;',
                            items: [
                                {
                                    xtype: 'panel',
                                    title: 'Drop files here',
                                    flex: 1,
                                    itemId: 'dropZone',
                                    layout: 'fit',
                                    bodyPadding: 10,
                                    defaults: { bodyStyle: 'background:transparent;' },
                                    html: '<div style="height:100%;display:flex;align-items:center;justify-content:center;border:2px dashed #bbb;border-radius:6px;">Drop images here or click to select</div>',
                                    listeners: {
                                        afterrender: function(p) {
                                            var win = p.up('window');
                                            var rec = record; // closure from parent scope
                                            // create a hidden file input for fallback click-to-select
                                            var input = document.createElement('input');
                                            input.type = 'file';
                                            input.accept = 'image/*';
                                            input.multiple = true;
                                            input.style.display = 'none';
                                            document.body.appendChild(input);

                                            input.addEventListener('change', function(e) {
                                                if (!e.target.files || e.target.files.length === 0) return;
                                                uploadFiles(Array.from(e.target.files), rec.get('id'), p.up('panel').down('#imageList').getStore());
                                                // reset
                                                e.target.value = null;
                                            });

                                            var el = p.getEl();
                                            // click opens file selector
                                            el.on('click', function() { input.click(); });

                                            // prevent defaults
                                            el.dom.addEventListener('dragover', function(ev){ ev.preventDefault(); el.addCls('drop-over'); }, false);
                                            el.dom.addEventListener('dragleave', function(ev){ ev.preventDefault(); el.removeCls('drop-over'); }, false);
                                            el.dom.addEventListener('drop', function(ev){
                                                ev.preventDefault();
                                                el.removeCls('drop-over');
                                                var files = Array.prototype.slice.call(ev.dataTransfer.files || []);
                                                if (files.length) {
                                                    uploadFiles(files, rec.get('id'), p.up('panel').down('#imageList').getStore());
                                                }
                                            }, false);

                                            // helper upload function (uses fetch + FormData)
                                            function uploadFiles(files, id, store) {
                                                if (!files || files.length === 0) return;
                                                var url = '/modules/common/locations.cfc?method=uploadImage';
                                                files.forEach(function(file) {
                                                    var fd = new FormData();
                                                    fd.append('file', file, file.name);
                                                    fd.append('locationID', id);
                                                    fd.append('filename', file.name); // send filename as separate field
                                                    // show simple feedback
                                                    var mask = win.getEl().mask ? win.getEl().mask('Uploading...') : null;
                                                    fetch(url, {
                                                        method: 'POST',
                                                        body: fd
                                                    }).then(function(resp){
                                                        return resp.json().catch(function(){ return { success: true }; });
                                                    }).then(function(data){
                                                        // reload the image list store
                                                        if (store) store.reload();
                                                    }).catch(function(err){
                                                        Ext.Msg.alert('Upload failed', (err && err.message) || 'Upload error');
                                                    }).finally(function(){
                                                        try { win.getEl().unmask(); } catch(e){}
                                                    });
                                                });
                                            }
                                        }
                                    }
                                },
                                {
                                    xtype: 'panel',
                                    title: 'Images',
                                    flex: 1,
                                    layout: 'fit',
                                    itemId: 'imagesPanel',
                                    items: [{
                                        xtype: 'dataview',
                                        itemId: 'imageList',
                                        store: Ext.create('Ext.data.Store', {
                                            model: Ext.define('ImageModel', {
                                                extend: 'Ext.data.Model',
                                                fields: [
                                                    { name: 'id', type: 'int' },
                                                    { name: 'filename', type: 'string' },
                                                    { name: 'path', type: 'string' }
                                                ]
                                            }),
                                            proxy: {
                                                type: 'ajax',
                                                url: '/modules/common/locations.cfc?method=fetchImages',
                                                reader: {
                                                    type: 'json',
                                                    rootProperty: 'images',
                                                    transform: function(data) {
                                                        try {
                                                            if (!data) return data;
                                                            if (Ext.isArray(data)) {
                                                                if (data.length === 1 && data[0] && data[0].images && Ext.isArray(data[0].images)) {
                                                                    return data[0].images;
                                                                }
                                                                return data;
                                                            }
                                                            if (data.images && Ext.isArray(data.images)) {
                                                                return data.images;
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
                                            autoLoad: false
                                        }),
                                        tpl: Ext.create('Ext.XTemplate',
                                            '<div style="padding:8px;overflow:auto;height:100%;">',
                                            '<tpl for=".">',
                                                '<div class="thumb" style="display:inline-block;margin:6px;text-align:center;width:120px;vertical-align:top;">',
                                                    '<img src="{path}" style="max-width:100px;max-height:80px;display:block;margin:0 auto 6px;"/>',
                                                    '<div style="white-space:nowrap;overflow:hidden;text-overflow:ellipsis;width:120px;">{filename}</div>',
                                                    '<div style="margin-top:4px;"><a href="#" class="delete-img" data-id="{id}">Delete</a></div>',
                                                '</div>',
                                            '</tpl>',
                                            '</div>'
                                        ),
                                        itemSelector: 'div.thumb',
                                        listeners: {
                                            afterrender: function(view) {
                                                try {
                                                    var win = view.up('window');
                                                    var rec = record; // closure
                                                    var st = view.getStore();
                                                    st.getProxy().url = '/modules/common/locations.cfc?method=fetchImages&locationID=' + encodeURIComponent(rec.get('id'));
                                                    st.on('load', function(store, records) {
                                                        try {
                                                            var data = records.map(function(r){ return r.getData(); });
                                                            console.log('Image store loaded records:', data);
                                                            // If records are empty or fields are blank, force loadData from raw response
                                                            if (!data.length || !data[0].filename) {
                                                                var raw = store.getProxy().getReader().rawData;
                                                                if (raw && raw.images) {
                                                                    store.loadData(raw.images);
                                                                    console.log('Forced loadData with:', raw.images);
                                                                }
                                                            }
                                                        } catch(e) { console.log('Image store debug error', e); }
                                                        view.refresh();
                                                    });
                                                    st.load();
                                                    view.getEl().on('click', function(e, t) {
                                                        t = Ext.get(t);
                                                        if (t && t.hasCls('delete-img')) {
                                                            e.stopEvent();
                                                            var imgId = t.getAttribute('data-id');
                                                            Ext.Msg.confirm('Confirm', 'Delete this image?', function(btn){
                                                                if (btn !== 'yes') return;
                                                                Ext.Ajax.request({
                                                                    url: '/modules/common/locations.cfc?method=deleteImage',
                                                                    method: 'POST',
                                                                    params: { id: imgId },
                                                                    success: function() { view.getStore().reload(); },
                                                                    failure: function() { Ext.Msg.alert('Error', 'Delete failed'); }
                                                                });
                                                            });
                                                        }
                                                    }, null, { delegate: 'a.delete-img' });
                                                } catch (e) { console.log('image list load error', e); }
                                            }
                                        }
                                    }]
                                }
                            ],
                            bbar: [
                                { text: 'Refresh', handler: function(b){ var st = b.up('panel').down('#imageList').getStore(); st.reload(); } },
                                { xtype: 'tbfill' },
                                { text: 'Close', handler: function(b){ b.up('window').close(); } }
                            ]
                        }]
                    }]
                });
                // load record data into form
                var f = win.down('form');
                if (f) f.getForm().setValues(record.getData());
                win.show();
            }
        },
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
                                { xtype: 'checkbox', name: 'kulturrelevant', fieldLabel: 'Kulturrelevant', inputValue: 1, uncheckedValue: 0 },
                                { xtype: 'checkbox', name: 'active', fieldLabel: 'Active', inputValue: 1, uncheckedValue: 0 }
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
                                           values.active = values.active ? 1 : 0;
                                        var store = grid.getStore();
                                        // 
                                        console.log(values)
                                        const postData = {
                                            name: values.name,
                                            adresse: values.adresse,
                                            ort_fk: values.comboOrtFk,
                                            beschreibung: values.beschreibung,
                                            kulturrelevant: values.kulturrelevant,
                                            aktiv: values.active
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
