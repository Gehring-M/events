/**
 * Created by JetBrains WebStorm.
 * User: Joshua McDonald joshuamcdonald69124@gmail.com
 * www.learnsomethings.com
 * Date: 9/12/13
 * To change this template use File | Settings | File Templates.
 */
Ext.define('Ext.ux.ExportRecords', {
    extend      : 'Ext.AbstractPlugin',
    alias       : 'plugin.exportrecords',

    /*
        Will create a context menu with a download
        button if this is set to 'context' or add a
        button to a toolbar if it is set to 'top'
    */

    downloadButton   : 'context',

    init    : function(component){
        var me = this;
        component.selectedRecords  = [],
		jetzt = new Date();
		tag = jetzt.getDate();
		monat = jetzt.getMonth()+1;
		jahr = jetzt.getFullYear();
		if (tag < 10) {
			tag = '0'+tag;	
		}
		if (monat < 10) {
			monat = '0'+monat;	
		}
		datum = tag+'.'+monat+'.'+jahr;
		
       // component.on('select', me.onRowSelect, component);
       // component.on('deselect', me.onRowDeselect, component);

        if(me.downloadButton == 'context'){
            me.contextMenu = Ext.create('Ext.menu.Menu', {
                width   : 250,
                items   :[
                    {
                        xtype   :   'button',
                        text    :   'Export Selected Records',
                        listeners: {
                            click: {
                                fn      : me.onExportToExcel,
                                scope   : component
                            }
                        }
                    }
                ]
            });

            component.on('itemcontextmenu', me.onRightExportExcel,this);

        } else {
            /*
                Does a toolbar exist?
                If so add the button to the existing tbar, if not
                create a tbar and then add the button.
            */
			
            if (component.getDockedItems('toolbar[dock="top"]').length === 0){
                component.addDocked({
                    xtype   : 'toolbar',
                    dock    : 'top',
                    items: [{
                        xtype   :   'button',
                        text    :   'Export Selected Records',
                        listeners: {
                            click: {
                                fn      : me.onExportToExcel,
                                scope   : component
                            }
                        }
                    }]
                });
            } else {
				
                component.getDockedItems('toolbar[dock="top"]')[0].insert(999, {
                    xtype   :   'button',
                    text    :   'Liste als CSV Datei exportieren',
					itemId	:	'exportData',
                    listeners: {
                        click: {
                            fn      : me.onExportToExcel,
                            scope   : component
                        }
                    }
                })
				
            }
        }

        /*
            Whoa! this grid has paging enabled, go ahead
            and make sure to remember the selections across
            pages for the print function.
        */
        if(component.down('pagingtoolbar') != null){
            // Is there a paging toolbar?
            component.relayEvents(component.down('pagingtoolbar'), ['change'], 'page');
            component.on('pagechange', me.onPageChange, component);
        }


    },

    onPageChange: function(pgtb, pageData){
        var me              = this,

            selectionModel  = me.getSelectionModel(),
            /*
             Beacuse the records in the page that you see have a row index that
             always starts with 0
             */
            subtractive     = (pageData.currentPage - 1 ) * me.store.pageSize,
            /*
             Users probably would not like to see Displaying 0 - 24 of 56 records
             in the paging toolbar so you have to account for the fact that the
             toRecord of pagedata will be one over unless the number of records displayed
             is less than the original page size.
             */
            finalIndex      = (me.getStore().getCount() < me.store.pageSize) ? pageData.toRecord :(pageData.toRecord -1 ),

            startIndex      = (pageData.fromRecord - 1);
        /* Make sure you remove the empty values */
        Ext.Array.clean(me.selectedRecords);
        /* Dedupe the array */
        Ext.Array.unique(me.selectedRecords);

        for (var i = 0; i < me.selectedRecords.length; i++){
            /*
             Make sure that you check if the current index falls in the visible indices
             on the current page otherwise you will get an error when trying
             to select an index that is out of range (but you would never know it,
             as it will not tell you what the error is)
             */
            if(me.selectedRecords[i].index >= startIndex && me.selectedRecords[i].index <= finalIndex){
                selectionModel.select((me.selectedRecords[i].index - subtractive), true,true);
            }
        }
    },

    onRowSelect : function(grid, record){
        Ext.Array.push(this.selectedRecords,record);
    },

    onRowDeselect   : function(grid, record){
        Ext.Array.remove(this.selectedRecords,record);
    },

    onRightExportExcel: function(grid,record, item, index, e){
        e.preventDefault();
        this.contextMenu.showAt(Ext.EventObject.getXY());
    },


    onExportToExcel: function(){
        var me              = this,
            csvContent      = '',
            /*
             Does this browser support the download attribute
             in HTML 5, if so create a comma seperated value
             file from the selected records / if not create
             an old school HTML table that comes up in a
             popup window allowing the users to copy and paste
             the rows.
             */
            noCsvSupport     = ( 'download' in document.createElement('a') ) ? false : true,
            sdelimiter      = noCsvSupport ? "<td>"   : "",
            edelimiter      = noCsvSupport ? "</td>"  : ";",
            snewLine        = noCsvSupport ? "<tr>"   : "",
            enewLine        = noCsvSupport ? "</tr>"  : "\r\n",
            printableValue  = '',
			myGrid 			= this.down('#exportData').up('grid'),
			myStore			= myGrid.getStore();
			myVisibleColumns = [],
			myColumnLabels={};
			
        csvContent += snewLine;

		if (myStore.data.items.length < 1) {
			Ext.Msg.alert('Systemnachricht','Die Tabelle entählt keine Daten und kann daher nicht exportiert werden.');
		} else {
			
			// sichtbare spalten zuweisen    
			Ext.Array.each(myGrid.columns,function(cCol) {
				if (!cCol.isHidden() && cCol.text!="") {
					Ext.Array.push(myVisibleColumns,cCol.dataIndex);
					myColumnLabels[cCol.dataIndex] = cCol.text;
				}
			});
			
			/* Get the column headers from the store dataIndex */
			Ext.Object.each(myStore.data.items[0].data, function(key) {
				if (myVisibleColumns.indexOf(key) != -1) {
					csvContent += sdelimiter +  myColumnLabels[key] + edelimiter;
				}
			});
			
			csvContent += enewLine;
			/*
			 Loop through the selected records array and change the JSON
			 object to teh appropriate format.
			 */
			for (var i = 0; i < myStore.data.items.length; i++){
				/* Put the record object in somma seperated format */
				csvContent += snewLine;
				Ext.Object.each(myStore.data.items[i].data, function(key, value) {
					if (myVisibleColumns.indexOf(key) != -1) {
						printableValue = ((noCsvSupport) && value == '') ? '&nbsp;'  : value;
						printableValue = String(printableValue).replace(/,/g , "");
						printableValue = String(printableValue).replace(/(\r\n|\n|\r)/gm,"");
						csvContent += sdelimiter +  printableValue + edelimiter;
					}
				});
				csvContent += enewLine;
			}
			
			if('download' in document.createElement('a')){
				/*
				 This is the code that produces the CSV file and downloads it
				 to the users computer
				 */
				var mycsvlink = document.createElement("a");
				mycsvlink.setAttribute("href", "data:text/csv;charset=utf-8,\uFEFF" + encodeURI(csvContent));
				mycsvlink.setAttribute("download", "Export_"+myGrid.agExportLabel+"_"+datum+".csv");
				document.body.appendChild(mycsvlink); 
				mycsvlink.click();
				document.body.removeChild(mycsvlink); 
			} else {
				/*
				 The values below get printed into a blank window for
				 the luddites.
				 */
				var newWin = open('windowName',"_blank");
				newWin.document.write('<table border=1>' + csvContent + '</table>');
			}
		}
    }
});