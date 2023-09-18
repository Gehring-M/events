Ext.define("Ext.aghelp.Helper", {
	alternateClassName: 'Ext.agHelper',
	singleton: true,


	//diese Funktion gibt zurück, ob ein string eine UUID ist oder nicht
	isUUID: function(value)
	{
		//regExprfür gültige uuids
		var UUIDRegExp = new RegExp("^\\w{8}\\-\\w{4}\\-\\w{4}\\-\\w{4}\\-\\w{12}$");
		
		return UUIDRegExp.test(value);
		
	},

 	trimTextCutNoWords: function(text,charno,overlap)
	{
		var retText = text.trim();
		var cuttingRegExp;
		if(text.length > charno)
		{
			retText = retText.replace(/(<[^>]*>)/g,"");
			retText = retText.replace(/(&nbsp;)/g,"");
			if(overlap)
			{
				cuttingRegExp = new RegExp("^\\s*(.{0," + charno + "}.[^(\\s),.?!]*)(\\s|[,.?!])*");
			}
			else
			{
				cuttingRegExp = new RegExp("^\\s*(.{0," + charno + "})\\s.*");
			}
			retText = retText.match(cuttingRegExp)[1];
		}
		
		return retText;
	},

	convertUUID: function(value,record)
	{
		if(value && Ext.aghelp.Helper.isUUID(value))
		{
			return value.toUpperCase();
		}
		return value;
	},
	
	//bei einem autosugestfeld kann es vorkommen, dass ein user etwas eingibt und ein resultat bekommt, welches dann auch angezeigt wird
	//er klickt es aber nicht in der dropdown-area an, dadruch steht als value keine uuid im feld sondern ein falscher eintrag (der gerade eingegebene z.b 619669)
	//in so einem fall wird geschaut ob es einen eindeutigen eintrag im store gibt
	//falls ja wird dieser übernommen
	//falls nein wird das feld geleert, damit der user erkennt, dass die eingabe nicht funktioniert hat
	checkAutosuggestUUID: function(callingItem)
	{
		if(!Ext.aghelp.Helper.isUUID(callingItem.getValue()))
		{
			//wenn man einen eintrag entfernen will, kann es sein, dass im store trotzdem noch genau ein eintrag steht,
			//es kann auch sein, dass man einen wert eingibt, etwas im store steht und man wieder anfängt weg zu löschen
			//darum wird ein wert aus dem store erst übernommen, wenn die länge des werts (welchs eingegeben wurde) min der anzahl der minChars entspricht, d.h. dass auf jeden fall ein 
			// store mit dem betreffenden eingegebenen werte geladen wurde
			if(callingItem.getValue() && callingItem.getValue().length >=  callingItem.minChars && callingItem.getStore().getCount() == 1)
			{
				//setze die korrekte UUID
				callingItem.setValue(callingItem.getStore().getAt(0).get(callingItem.valueField));
			}
			else
			{
				//falls es mehrere einträge im store gibt wird das feld geleert
				callingItem.setValue('');
			}
		}
	},
	
	//can be used fpr a tree store to expand all parent nodes
	expandTreeNode: function(cRecord)
	{
		//wenn dieser Knoten bereits expanded ist, dan wird abgebrochen
		if(cRecord.isExpanded())
		{
			return
		}
		
		if(!cRecord.leaf)
		{
			cRecord.expand(false);
		}
	
		if(cRecord.parentNode)
		{
			Ext.aghelp.Helper.expandTreeNode(cRecord.parentNode);
		}
	},
	
	getConfigData: function(myStore,name)
	{
		var myRow = myStore.findExact('name',name),
		myRecord = myStore.getAt(myRow),
		cRetVal = "";
		
		if (myRow != -1) {
			cRetVal = myRecord.data.value;
		}
		return cRetVal;
	}
	
	
});