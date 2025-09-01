const url = 'https://events-test.agindo-services.info'


Ext.define('myapp.view.ExterneDaten', {
    extend: 'Ext.form.Panel',
    alias: 'widget.ExterneDaten',
    xtype: 'ExterneDaten',
    
    title: 'Externe Daten',
    bodyPadding: 10,
    
    tbar: [{
        text: 'Import data',
        handler: async function() {
            // get panel
            const panel = this.up('panel')
            // send request to import geodata
            fetch(`${url}/components/geodatenimport.cfc?method=importGeodata`)
                .then(async (response) => {
                    //
                    const data = await response.json()
                    
                    // render HTML to display results 
                    const html = `
                        <div style="padding: 1rem; border-radius: .5rem; box-shadow: 0 4px 8px 0 rgba(0, 0, 0, 0.2); width: auto; margin: 0 auto;">
                            <h3 style="margin: 0 0 1rem 0;">Import Auswertung</h3>
                            <table>
                                <thead style="border-bottom: 1px solid #555;">
                                    <th style="padding: .5rem; background-color: #CCC;">new entries that are active on website</th>
                                    <th style="padding: .5rem; background-color: #CCC;">new entries that need approval</th>
                                    <th style="padding: .5rem; background-color: #CCC;">overwritten entries that are active on website</th>
                                    <th style="padding: .5rem; background-color: #CCC;">overwritten entries that need approval</th>
                                    <th style="padding: .5rem; background-color: #CCC;">did not overwrite because KBSZ did</th>
                                    <th style="padding: .5rem; background-color: #CCC;">entries that did not match a category</th>
                                    <th style="padding: .5rem; background-color: #CCC;">http request errors</th>
                                </thead>
                                <tbody>
                                    <td style="padding: .5rem; background-color: #EEE;">${data.debug.new_visible_on_website}</td>
                                    <td style="padding: .5rem; background-color: #EEE;">${data.debug.new_need_approval}</td>
                                    <td style="padding: .5rem; background-color: #EEE;">${data.debug.overwrite_visible_on_website}</td>
                                    <td style="padding: .5rem; background-color: #EEE;">${data.debug.overwrite_need_approval}</td>
                                    <td style="padding: .5rem; background-color: #EEE;">${data.debug.no_overwrite}</td>
                                    <td style="padding: .5rem; background-color: #EEE;">${data.debug.no_import}</td>
                                    <td style="padding: .5rem; background-color: #EEE;">${data.debug.http_error}</td>
                                </tbody>
                            </table>
                        </div>
                    `

                    const resultsBox = panel.down('#importResults')
                    resultsBox.update(html)
                })
                .catch((error) => {
                    console.error(error)
                })
        }
    }],

    items: [{
        xtype: 'container',
        itemId: 'importResults',
        html: ''
    }]
});
