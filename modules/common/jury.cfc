<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">


    <!--- ########################## --->
    <!--- #   FETCH JURY MEMBERS   # --->
    <!--- ########################## --->

    <cffunction name="fetchJuryMembers" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var response = {}>
        <cfset response['jury_members'] = []>

        <!--- check authentication --->
        <cfif isAuth() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>

            <cfset juryMembers = getStructuredContent(nodetype=1502)>

            <!--- construct jury members --->
            <cfloop query="juryMembers">
                <cfset juryMember = {}>
                <cfset juryMember['id'] = juryMembers.id>
                <cfset juryMember['name'] = juryMembers.vorname>
                <cfset juryMember['last_name'] = juryMembers.nachname>
                <cfset juryMember['email'] = juryMembers.email>
                <cfset juryMember['description'] = juryMembers.beschreibung>
                <cfset juryMember['status'] = juryMembers.status>
                <cfset ArrayAppend(response['jury_members'], juryMember)>
            </cfloop>

            <cfset response['success'] = true>
            <cfset response['message'] = "Successfully fetched jury members">
            <cfreturn response>
        <cfelse>
            <cfheader statuscode="401" statustext="Unauthorized">
            <cfset response['success'] = false>
            <cfset response['message'] = "You are not authenticated">
        </cfif>

    </cffunction>

</cfcomponent>