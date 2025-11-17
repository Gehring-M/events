<cfcomponent>

    <!--- includes --->
    <cfinclude template="/ameisen/functions.cfm">
    <cfinclude template="/modules/functions.cfm">

    <!--- settings --->
    <cfset errorMessages = {}>
    <cfset errorMessages['Unauthorized'] = "You are not authenticated">


    <!--- ######################## --->
    <!--- #   FETCH CATEGORIES   # --->
    <!--- ######################## --->

    <cffunction name="fetchCategories" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var response = {}>

        <cfif isAuth() OR (isAuth() AND hasGroup('verwaltungsclient', 'name'))>

            <cfquery name="categories" datasource="#getConfig('DSN')#">
                SELECT id, name, description
                FROM category 
                WHERE deletedwhen IS NULL;
            </cfquery>

            <!--- build data --->
            <cfset response['categories'] = []>
            <cfloop query="categories">
                <cfset category = {}>
                <cfset category['id'] = categories.id>
                <cfset category['name'] = categories.name>
                <cfset category['description'] = categories.description>
                <cfset ArrayAppend(response['categories'], category)>
            </cfloop>

            <cfset response['success'] = true>
            <cfset response['message'] = "Sending categories ...">
            <cfreturn response>
        <cfelse>
            <cfreturn sendErrorResponse(statusCode=401, statusText="Unauthorized", errorMessage="You are not authenticated")>
        </cfif>

    </cffunction>


    <!--- ####################### --->
    <!--- #   CREATE CATEGORY   # --->
    <!--- ####################### --->

    <cffunction name="createCategory" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var requestData = deserializeJSON(getHttpRequestData().content)>
        <cfset var wpResponse = {}>
        <cfset var response = {}>


        <cfif isAuth() OR hasGroup('verwaltungsclient')>
            <cfif StructKeyExists(requestData, 'name') AND StructKeyExists(requestData, 'description')>

                <cftry>
                    <!---------- WORDPRESS COMMUNICATION ---------->
                    <cfset wpURL = getConfig('wordpress.url') & "/categories">
                    <cfset credentials = getConfig('wordpress.user') & ":" & getConfig('wordpress.password')>
                    <cfset encodedCredentials = ToBase64(credentials)>

                    <cfhttp method="POST" url="#wpURL#" result="result" timeout="5">
                        <cfhttpparam type="header" name="Authorization" value="Basic #encodedCredentials#">
                        <cfhttpparam type="header" name="Content-Type" value="application/json">
                        <cfhttpparam type="body" value='{ "name": "#requestData['name']#", "description": "#requestData['description']#" }'>
                    </cfhttp>

                    <cfset wpResponse = deserializeJSON(result.fileContent)>
                    <!--------------------------------------------->
                <cfcatch>
                    <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="Communication error between 'events-backend' and 'wordpress'")>
                </cfcatch>
                </cftry>

                <cfif StructKeyExists(wpResponse, 'data') AND StructKeyExists(wpResponse['data'], 'status') AND (wpResponse['data']['status'] EQ 400)>
                <!--- entry is already there --->
                    <cfreturn sendErrorResponse(statusCode=400, statusText="Bad Request", errorMessage="The category could not be created because it is already there.")>
                <cfelse>
                <!--- entry is not there yet --->
                    <cfif StructKeyExists(wpResponse, 'id') AND StructKeyExists(wpResponse, 'name') AND StructKeyExists(wpResponse, 'description') AND StructKeyExists(wpResponse, 'slug')>

                        <cfquery name="saveCategory" datasource="#getConfig('DSN')#">
                            INSERT INTO category (id, name, description, slug)
                            VALUES (
                                <cfqueryparam cfsqltype="cf_sql_integer" value="#wpResponse['id']#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#wpResponse['name']#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#wpResponse['description']#">,
                                <cfqueryparam cfsqltype="cf_sql_varchar" value="#wpResponse['slug']#">
                            )
                        </cfquery>

                        <cfset response['success'] = true>
                        <cfset response['message'] = "Created new category">
                        <cfreturn response>
                    <cfelse>
                        <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="The data coming from Wordpress has changed. Please check parameters and Wordpress API.")>
                    </cfif>
                </cfif>
            <cfelse>
                <cfreturn sendErrorResponse(statusCode=400, statusText="Bad Request", errorMessage="Please provide the following POST params: { name, description }")>
            </cfif>
        <cfelse>
            <cfreturn sendErrorResponse(statusCode=401, statusText="Unauthorized", errorMessage="You are not authenticated")>
        </cfif>

    </cffunction>



    <!--- ####################### --->
    <!--- #   DELETE CATEGORY   # --->
    <!--- ####################### --->

    <cffunction name="deleteCategory" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var requestData = deserializeJSON(getHttpRequestData().content)>
        <cfset var wpResponse = {}>
        <cfset var response = {}>
        
        <!--- delete category --->
        <cfif isAuth() OR hasGroup('verwaltungsclient')>
            <cfif StructKeyExists(requestData, 'categoryID')>

                <!--- credentials --->
                <cfset credentials = getConfig('wordpress.user') & ":" & getConfig('wordpress.password')>
                <cfset encodedCredentials = ToBase64(credentials)>


                <!--- check for posts that are related to this category --->
                <cftry>
                    <!---------- WORDPRESS COMMUNICATION ---------->
                    <cfset wpCheckURL = getConfig('wordpress.url') & "/posts?categories=" & requestData['categoryID']>
                    
                    <cfhttp method="GET" url="#wpCheckURL#" result="checkResult" timeout="5">
                        <cfhttpparam type="header" name="Authorization" value="Basic #encodedCredentials#">
                        <cfhttpparam type="header" name="Content-Type" value="application/json">
                    </cfhttp>

                    <cfset wpCheckResponse = deserializeJSON(checkResult.filecontent)>
                    <!--------------------------------------------->
                <cfcatch>
                    <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="Communication error between 'events-backend' and 'wordpress'")>
                </cfcatch>
                </cftry>


                <!--- there are posts related to that category => assign to "Uncategorized" --->
                <cfif ArrayLen(wpCheckResponse) GT 0>

                    <!--- reassign all posts to "Uncategorized" (category ID: 1) --->
                    <cfloop array="#wpCheckResponse#" index="wpPost">
                        <cftry>
                            <!---------- WORDPRESS COMMUNICATION ---------->
                            <cfset wpPostURL = getConfig('wordpress.url') & "/#wpPost['id']#">
                            <cfset credentials = getConfig('wordpress.user') & ":" & getConfig('wordpress.password')>
                            <cfset encodedCredentials = ToBase64(credentials)>

                            <cfhttp method="PUT" url="#wpPostURL#" result="postResult" timeout="5">
                                <cfhttpparam type="header" name="Authorization" value="Basic #encodedCredentials#">
                                <cfhttpparam type="header" name="Content-Type" value="application/json">
                                <cfhttpparam type="body" value='{ "categories": [1] }'>
                            </cfhttp>
                            <!--------------------------------------------->
                        <cfcatch>
                            <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="Failed to reassign post #wpPost['id']# to Uncategorized category. Cannot delete category.")>
                        </cfcatch>
                        </cftry>
                    </cfloop>

                </cfif>


                <!--- delete category --->
                <cftry>
                    <!---------- WORDPRESS COMMUNICATION ---------->
                    <cfset wpURL = getConfig('wordpress.url') & "/categories" & "/#requestData['categoryID']#" & "?force=true">
                    <cfset credentials = getConfig('wordpress.user') & ":" & getConfig('wordpress.password')>
                    <cfset encodedCredentials = ToBase64(credentials)>

                    <cfhttp method="DELETE" url="#wpURL#" result="result" timeout="5">
                        <cfhttpparam type="header" name="Authorization" value="Basic #encodedCredentials#">
                        <cfhttpparam type="header" name="Content-Type" value="application/json">
                    </cfhttp>

                    <cfset wpResponse = deserializeJSON(result.fileContent)>
                    <!--------------------------------------------->
                <cfcatch>
                    <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="Communication error between 'events-backend' and 'wordpress'")>
                </cfcatch>
                </cftry>

                <!--- category does not exist in Wordpress --->
                <cfif StructKeyExists(wpResponse, 'code') AND wpResponse['code'] EQ "rest_term_invalid">
                    <cfreturn sendErrorResponse(statusCode=404, statusText="Not Found", errorMessage="The category with an ID #wpResponse['categoryID']# does not exist in Wordpress.")>

                <!--- category was deleted successfully in Wordpress --->
                <cfelseif StructKeyExists(wpResponse, 'deleted') AND wpResponse['deleted']>

                    <cfquery name="deleteCategory" datasource="#getConfig('DSN')#">
                        DELETE FROM category WHERE id = <cfqueryparam cfsqltype="cf_sql_integer" value="#wpResponse['previous']['id']#">
                    </cfquery>

                    <cfset response['success'] = true>
                    <cfset response['message'] = "Successfully deleted category">
                    <cfreturn response>

                <!--- fallback --->
                <cfelse>
                    <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="The Wordpress-Response format might have changed, please check the API.")>
                </cfif>
            <cfelse>
                <cfreturn sendErrorResponse(statusCode=400, statusText="Bad Request", errorMessage="Please provide the following URL params: { categoryID }")>
            </cfif>
        <cfelse>
            <cfreturn sendErrorResponse(statusCode=401, statusText="Unauthorized", errorMessage="You are not authenticated")>
        </cfif>

    </cffunction>


    <!--- ####################### --->
    <!--- #   UPDATE CATEGORY   # --->
    <!--- ####################### --->

    <cffunction name="updateCategory" access="remote" returnFormat="JSON">

        <!--- init --->
        <cfset var requestData = deserializeJSON(getHttpRequestData().content)>
        <cfset var wpResponse = {}>
        <cfset var response = {}>

        <!--- modify category --->
        <cfif isAuth() OR hasGroup('verwaltungsclient')>
            <cfif StructKeyExists(requestData, 'id') AND StructKeyExists(requestData, 'name') AND StructKeyExists(requestData, 'description')>

                <cftry>
                    <!---------- WORDPRESS COMMUNICATION ---------->
                    <cfset wpURL = getConfig('wordpress.url') & "/categories" & "/#requestData['id']#">
                    <cfset credentials = getConfig('wordpress.user') & ":" & getConfig('wordpress.password')>
                    <cfset encodedCredentials = ToBase64(credentials)>

                    <cfhttp method="PUT" url="#wpURL#" result="result" timeout="5">
                        <cfhttpparam type="header" name="Authorization" value="Basic #encodedCredentials#">
                        <cfhttpparam type="header" name="Content-Type" value="application/json">
                        <cfhttpparam type="body" value='{ "name": "#requestData['name']#", "description": "#requestData['description']#" }'>
                    </cfhttp>

                    <cfset wpResponse = deserializeJSON(result.fileContent)>
                    <!--------------------------------------------->
                <cfcatch>
                    <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="Communication error between 'events-backend' and 'wordpress'")>
                </cfcatch>
                </cftry>

                <!--- category does not exist in Wordpress --->
                <cfif StructKeyExists(wpResponse, 'code') AND wpResponse['code'] EQ "rest_term_invalid">
                    <cfreturn sendErrorResponse(statusCode=404, statusText="Not Found", errorMessage="The category with an ID #wpResponse['categoryID']# does not exist in Wordpress.")>

                <!--- category was modified successfully in Wordpress --->
                <cfelseif StructKeyExists(wpResponse, 'id') AND StructKeyExists(wpResponse, 'name') AND StructKeyExists(wpResponse, 'description') AND StructKeyExists(wpResponse, 'slug')>

                    <cfquery name="updateCategory" datasource="#getConfig('DSN')#">
                        UPDATE category
                        SET 
                            name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#wpResponse['name']#">,
                            description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#wpResponse['description']#">,
                            slug = <cfqueryparam cfsqltype="cf_sql_varchar" value="#wpResponse['slug']#">
                        WHERE 
                            id = <cfqueryparam cfsqltype="cf_sql_integer" value="#wpResponse['id']#">;
                    </cfquery>

                    <cfset response['success'] = true>
                    <cfset response['message'] = "Successfully updated category">
                    <cfreturn response>

                <!--- fallback --->
                <cfelse>
                    <cfreturn sendErrorResponse(statusCode=500, statusText="Internal Server Error", errorMessage="The Wordpress-Response format might have changed, please check the API.")>
                </cfif>
            <cfelse>
                <cfreturn sendErrorResponse(statusCode=400, statusText="Bad Request", errorMessage="Please provide the following URL params: { id, name, description }")>
            </cfif>
        <cfelse>
            <cfreturn sendErrorResponse(statusCode=401, statusText="Unauthorized", errorMessage="You are not authenticated")>
        </cfif>

    </cffunction>


    <!--- ########################### --->
    <!--- #   SEND ERROR RESPONSE   # --->
    <!--- ########################### --->

    <cffunction name="sendErrorResponse">
        <!--- arguments --->
        <cfargument name="statusCode" type="numeric" required="yes">
        <cfargument name="statusText" type="string" required="yes">
        <cfargument name="errorMessage" type="string" required="yes">
        <!--- construct response --->
        <cfheader statuscode="#statusCode#" statustext="#statusText#">
        <cfset response['success'] = false>
        <cfset response['message'] = errorMessage>
        <cfreturn response>
    </cffunction>

</cfcomponent>