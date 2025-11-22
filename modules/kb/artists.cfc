<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">
    <cfinclude template="/modules/cors.cfm">


    <!--- ############################# --->
    <!--- #   HELPER : PARSE DATE     # --->
    <!--- ############################# --->

    <cffunction name="parseAndFormatDate" access="private" returntype="string">
        <cfargument name="dateString" type="string" required="true">
        
        <cftry>
            <!--- Parse the date string --->
            <cfset var parsedDate = ParseDateTime(arguments.dateString)>
            <!--- Format as dd.mm.yyyy --->
            <cfreturn DateFormat(parsedDate, "dd.mm.yyyy")>
            
            <cfcatch>
                <!--- Return original string if parsing fails --->
                <cfreturn arguments.dateString>
            </cfcatch>
        </cftry>
    </cffunction>

</cfcomponent>