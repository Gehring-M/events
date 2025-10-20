Ext.define('myapp.store.LocationDropdown', {
    extend: 'Ext.data.Store',
    storeId: 'LocationDropdown',
    alias: 'store.LocationDropdown',
    autoLoad: true,
    proxy: {
        type: 'ajax',
        timeout: 300000,
        pageParam: false,
        startParam: false,
        limitParam: false,
        noCache: true,
        url: 'modules/common/locations.cfc?method=fetchLocations',
        reader: {
            type: 'json',
            transform: function(data) {
                // Handle responses like: { locations: [...] } or [ { locations: [...] } ]
                try {
                    if (!data) return data;
                    if (Ext.isArray(data) && data.length && data[0] && data[0].locations && Ext.isArray(data[0].locations)) {
                        return data[0].locations;
                    }
                    if (data.locations && Ext.isArray(data.locations)) {
                        return data.locations;
                    }
                } catch (e) {
                    // silent transform error
                }
                return data;
            }
        }
    },
    fields: [{
        name: 'id'
    }, {
        name: 'name'
    }],
    listeners: {
        load: function(store, records, successful, operation) {
            try {
                // Defensive: only map if records is a valid array
                var rawSnapshot = Array.isArray(records) ? records.map(function(r){ return r.raw }) : [];
                // If the reader created a single wrapper record whose raw contains the locations array,
                // replace the store data with that inner array so models have correct id/name fields.
                try {
                    if (!store._normalizedLoaded && rawSnapshot && rawSnapshot.length === 1 && rawSnapshot[0] && rawSnapshot[0].locations && Ext.isArray(rawSnapshot[0].locations)) {
                        var locs = rawSnapshot[0].locations;
                        if (locs && Ext.isArray(locs) && locs.length) {
                            store._normalizedLoaded = true;
                            store.loadData(locs);
                        }
                    }
                } catch (e) {
                    console.log('normalization fallback error', e);
                }
            } catch (err) {
                console.log('load listener error', err);
            }
        }
    }
});
