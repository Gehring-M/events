Ext.define("Ext.aghelp.Permission", {
	//extend: 'Ext.util.Functions',
	singleton: true,

	checkPermissions: function(customerId,myWindow)
	{
		var lock = true;
		var checkHauptbetreuer = false;
		var checkCSSPbetreuer = false;
		var checkVKBVerantwortlicher = false;
		var checkVerkaufsbereich = false;
		
		// store mit den permissions holen
		var myAuthStore = Ext.getStore('Auth');
		var myAuthData = myAuthStore.data.items[0].data;
		var setLock = function(element, lockState) {

			switch(element.xtype) {

				case 'combo':
				case 'combobox':
				case 'textfield':
				case 'textareafield':
				case 'displayfield':
				case 'checkboxfield':
				case 'numberfield':
				case 'checkbox':
				case 'radio':
				case 'radiofield':
					switch(element.permissionMode) {
						case 'disable':		element.setDisabled(lockState); 	break;
						case 'hide': 		element.setVisible(!lockState); 	break;
						case 'readonly': 	element.setReadOnly(lockState); 	break;
					}
				break;

				case 'fieldset':
				case 'button':
				case 'splitbutton':
				case 'container':
				case 'fieldcontainer':
				case 'grid':
				case 'label':
					switch(element.permissionMode) {
						case 'disable':		element.setDisabled(lockState); 	break;
						case 'hide': 		element.setVisible(!lockState); 	break;
						case 'readonly': 	element.setDisabled(lockState); 	console.log("Der Typ '"+element.xtype+"' hat keine Methode setReadOnly. Alternativmethode setDisabled angewandt"); 	break;
					}
				break;

				default:
					console.log("Der Typ '"+element.xtype+"' ist noch nicht im permissionCheck (/app/aghelp/permissions.js) implementiert.");
				break;
			}

		};
		
		// zu checkenden bereich festlegen
		if (myWindow) {
			var areaToCheck = myWindow;
		} else {
			// center region zuweisen
			this.viewport = Ext.ComponentQuery.query('viewport')[0];
			var areaToCheck = this.viewport.down('[region=center]');
		}
		
		// nach objekten mit permissioncheck suchen
		myObj = areaToCheck.query('[permissionMode]');

		// über das objekt loopen und permission checken

		Ext.each(myObj,function(el,index) {

			lock = true;
		
			// berechtigung checken
			Ext.each(el.permissionGroups.split(","), function(permissionGroup){

				// wenn der user die entsprechende gruppe hat, wird der lock aufgehoben
				if (myAuthData[permissionGroup]) {
					lock = false;
				}
				
				// spezialfälle behandeln:
				// wenn die gruppe "spezial_nurHauptBetreuer" ist, wird geprüft, ob der user der hauptbetreuer des aktuellen kunden ist (übergebene customerId)
				if (permissionGroup=="spezial_nurHauptBetreuer") {
					// check ob customerid vorhanden ist
					if (customerId) {
						// prüfen, ob der check bereits gemacht wurde
						if (!checkHauptbetreuer) {
							// variable setzen, dass check bereits gemacht wurde
							checkHauptbetreuer = true;
							// request absetzen
							Ext.Ajax.request({
								url: '/modules/communication/data.cfc?method=getKundeBetreuer',
								params: {
									CustomerId: customerId,
									hauptbetreuer: 1
								},
								success: function (response) {
									var jsonParse = Ext.JSON.decode(response.responseText);
									// bei sucess = true, alle felder mit permission spezial_nurHauptBetreuer entsperren
									if(jsonParse.success) {
										Ext.each(myObj,function(el) {
											if (el.permissionGroups.indexOf("spezial_nurHauptBetreuer")!=-1) {
												setLock(el, false);
											}
										})
									}
								}
							});
						} 
						
					} else {
						console.log('Bei permissionGroup "spezial_nurHauptBetreuer" muss beim Funktionsaufruf (checkPermissions) eine customerDd mitgegeben werden.');
					}
				}
				
				// wenn die gruppe "spezial_CSSPBetreuer" ist, wird geprüft, ob der user der csspbetreuer des aktuellen kunden ist (übergebene customerId)
				if (permissionGroup=="spezial_CSSPBetreuer") {
					
					// check ob customerid vorhanden ist
					if (customerId) {
						// prüfen, ob der check bereits gemacht wurde
						if (!checkCSSPbetreuer) {
							// variable setzen, dass check bereits gemacht wurde
							checkCSSPbetreuer = true;
							// request absetzen
							Ext.Ajax.request({
								url: '/modules/communication/data.cfc?method=getKundeBetreuer',
								params: {
									CustomerId: customerId,
									checkAufBetreuerartFK: '5FC44DD5-CEA3-44AB-8EFF-820C22ED175B'
								},
								success: function (response) {
									var jsonParse = Ext.JSON.decode(response.responseText);
									// bei sucess = true, alle felder mit permission spezial_nurHauptBetreuer entsperren
									if(jsonParse.success) {
										Ext.each(myObj,function(el) {
											if (el.permissionGroups.indexOf("spezial_CSSPBetreuer")!=-1) {
												setLock(el, false);
											}
										})
									}
								}
							});
						} 
						
					} else {
						console.log('Bei permissionGroup "spezial_CSSPBetreuer" muss beim Funktionsaufruf (checkPermissions) eine customerDd mitgegeben werden.');
					}
				}
				
				// wenn die gruppe "spezial_vkb_verantwortlicher" ist, wird geprüft, ob der user der verkaufsbereichs verantwortliche des aktuellen kunden ist (übergebene customerId)
				if (permissionGroup=="spezial_vkb_verantwortlicher") {
					
					// check ob customerid vorhanden ist
					if (customerId) {
						// prüfen, ob der check bereits gemacht wurde
						if (!checkVKBVerantwortlicher) {
							// variable setzen, dass check bereits gemacht wurde
							checkVKBVerantwortlicher = true;
							// request absetzen
							Ext.Ajax.request({
								url: '/modules/communication/data.cfc?method=getVBKVerantwortlichen',
								params: {
									CustomerId: customerId
								},
								success: function (response) {
									var jsonParse = Ext.JSON.decode(response.responseText);
									// bei sucess = true, alle felder mit permission spezial_nurHauptBetreuer entsperren
									if(jsonParse.success) {
										Ext.each(myObj,function(el) {
											if (el.permissionGroups.indexOf("spezial_vkb_verantwortlicher")!=-1) {
												setLock(el, false);
											}
										})
									}
								}
							});
						} 
						
					} else {
						console.log('Bei permissionGroup "spezial_vkb_verantwortlicher" muss beim Funktionsaufruf (checkPermissions) eine customerDd mitgegeben werden.');
					}
				}
				
				// wenn die gruppe "spezial_nurVerkaufsbereich" ist, wird geprüft, ob der user der verkaufsbereichs verantwortliche des aktuellen kunden ist (übergebene customerId)
				if (permissionGroup=="spezial_nurVerkaufsbereich") {
					
					// check ob customerid vorhanden ist
					if (customerId) {
						// prüfen, ob der check bereits gemacht wurde
						if (!checkVerkaufsbereich) {
							// variable setzen, dass check bereits gemacht wurde
							checkVerkaufsbereich = true;
							// request absetzen
							Ext.Ajax.request({
								url: '/modules/common/retrieve.cfc?method=getCustomerVerkaufsbereich',
								params: {
									CustomerId: customerId
								},
								success: function (response) {
									var jsonParse = Ext.JSON.decode(response.responseText);
									// bei sucess = true, alle felder mit permission spezial_nurVerkaufsbereich entsperren
									if(jsonParse.success) {
										Ext.each(myObj,function(el) {
											if (el.permissionGroups.indexOf("spezial_nurVerkaufsbereich")!=-1) {
												setLock(el, false);
											}
										})
									}
								}
							});
						} 
						
					} else {
						console.log('Bei permissionGroup "spezial_nurVerkaufsbereich" muss beim Funktionsaufruf (checkPermissions) eine customerDd mitgegeben werden.');
					}
				}
				
			})
			
			// administrator sieht alles
			if (myAuthData['administrator']) {
				lock = false;
			}

			// bei fehlender berechtigung felder sperren / ausbleden
			if (lock) {
				setLock(el, true);
			}

		})

	}

});