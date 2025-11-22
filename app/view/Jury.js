Ext.define('myapp.view.Jury', {
    extend: 'Ext.grid.Panel',
    alias: 'widget.Jury',
    xtype: 'Jury',
    title: 'Jury',
    store: 'Jury',
    border: true,
    flex: 1,
    name: 'jury',
    windowWidth: 800,
    maxWindowHeight: 800,
    windowName: 'jury',
    nodeType: 1502,
    text: 'Daten ändern',
    viewConfig: {
        enableTextSelection: true
    },
    plugins: [{
        ptype: 'bufferedrenderer',
        trailingBufferZone: 20,
        leadingBufferZone: 50
    }],
    columns: [
        { xtype: 'rownumberer', width: 38, align: 'center' },
        { text: 'Status', dataIndex: 'status', width: 65, align: 'center', hidden: false,
            renderer: function (value, data, record) {
                var myTdClass = (record.data.status == "aktiv") ? 'tdGreen' : 'tdRed';
                data.tdCls = myTdClass;
                return record.data.status;
            }
        },
        { text: 'Nachname', dataIndex: 'last_name', flex: 1 },
        { text: 'Vorname', dataIndex: 'name', flex: 1 },
        { text: 'Email', dataIndex: 'email', flex: 1 },
        { text: 'Beschreibung', dataIndex: 'description', flex: 2,
            renderer: function (value, meta) {
                meta.style = 'white-space: normal';
                return value;
            }
        }
    ]
});