<cfcomponent>

    <cffunction name="fetchLocations" access="remote" returnFormat="JSON">

        <!--- arguments --->
        <cfargument name="username" type="string" required="yes">
        <cfargument name="password" type="string" required="yes">

        <!--- init --->
        <cfset response = {}>

        <!--- check auth --->
        <!---<cfset authStruct = authenticate(arguments.username, arguments.password, 'page')>--->

        <cfset response['data'] = 'Hola'>

        <cfreturn response>

    </cffunction>
    
</cfcomponent>