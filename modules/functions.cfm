<cfsilent>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!--- funktion handelt die sonderfälle der updateData funktion ab. diese unterscheiden sich je nach nodetype --->
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cffunction name="updateSpecialData" access="private" returnFormat="json">
	<cfargument name="nodetype" type="numeric" required="yes">
	<cfargument name="data" type="struct" required="yes">
	<cfargument name="instanceid" type="string" required="yes">
	<cfset var result = StructNew()>
	<cfset result['overWriteMessage'] = "">
	<cfset var uploadStruct = StructNew()>
	<cfset var myUploadID = 0>
		   
	<cfswitch expression="#arguments.nodetype#">
		
		<cfcase value="2101">
			
		</cfcase>
		<cfcase value="2102">
			
		</cfcase>	
	</cfswitch>
	<cfreturn result>
</cffunction>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
					
</cfsilent>