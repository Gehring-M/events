Ext.define("Ext.aghelp.Statusupdate", {
	//extend: 'Ext.util.Functions',
	singleton: true,

	updateStatus: function(result)
	{
		myStatus = Ext.getCmp('neo-status-update');
		var message = "";
		var statusClass = "";
		
		if (result) {
			if (result.success) {
				message = result.message;
				statusClass = "statusSuccess";
			} else {
				
				// Error text zusammenbauen
				Ext.each(result.errors.messages,function(el){
					message = message + el + "<br>";
				})
				statusClass = "statusError";
			}
			myStatus.update("<div class='"+statusClass+"'>"+message+"</div>");
		} else {
				myStatus.update();
		}
	}

});