<cfif NOT isAmeisen()>
	bitte einloggen
	<cfreturn>
</cfif>

<style>
	table {
		border: 1px solid #cdcdcd;
		border-collapse: collapse;
		
	}

	tr:nth-child(even) {
		background-color: #efefef;
	}

	td, th {
		border: 1px solid #cdcdcd;
		vertical-align: top;
		padding: 5px;
	}

</style>

<cfoutput>

<h1>Geodaten Import Demo</h1>

<div>
    <input id="importA" type="button" value="Import Achensee Daten" onclick="location.href='#me()#&mode=importA'">
    <input id="importZ" type="button" value="Import Zillertal Daten" onclick="location.href='#me()#&mode=importB'">
</div>

<br /><br />


<cfif StructKeyExists(url, 'mode')>
	#loadKategoryData(mode="#url.mode#", categoryType="A")#
	#loadKategoryData(mode="#url.mode#", categoryType="B")#
	#loadKategoryData(mode="#url.mode#", categoryType="Alle")#
</cfif>


<cffunction name="loadKategoryData">
	<cfargument name="mode" default="importA">
	<cfargument name="categoryType" default="A">

	<cfset apiUrl = "https://tirol.mapservices.eu/nefos_app/frontend/resource/json/Resource.action">
	<cfset apiKey = "agdo_hV6fnNk0yE68XnJz">
	<cfif mode EQ "importA">
		<cfset apiKey = "agdo_lI9dBpWqUuNuaRmu">
	</cfif>

	<cfhttp url="#apiUrl#" method="get" result="httpResponse">	
		<!---<cfhttpparam type="header" name="Content-Type" value="application/json">	--->
		<cfhttpparam type="url" name="LoadResourcesByCategory" value="action">
		<cfhttpparam type="url" name="apiKey" value="#apiKey#">
		<cfhttpparam type="url" name="exportAsOdta" value="true">

		<cfif categoryType EQ "A">

			<cfhttpparam type="url" name="search.categories[]" value="25051">
			<cfhttpparam type="url" name="search.categories[]" value="24969">
			<cfhttpparam type="url" name="search.categories[]" value="25039">
			<cfhttpparam type="url" name="search.categories[]" value="25002">
			<cfhttpparam type="url" name="search.categories[]" value="24992">
			<cfhttpparam type="url" name="search.categories[]" value="24993">
			<cfhttpparam type="url" name="search.categories[]" value="24989">
			<cfhttpparam type="url" name="search.categories[]" value="25045">
			<cfhttpparam type="url" name="search.categories[]" value="25058">
			<cfhttpparam type="url" name="search.categories[]" value="24998">
			<cfhttpparam type="url" name="search.categories[]" value="25040">
			<cfhttpparam type="url" name="search.categories[]" value="25041">
			<cfhttpparam type="url" name="search.categories[]" value="25052">
			<cfhttpparam type="url" name="search.categories[]" value="24995">
			<cfhttpparam type="url" name="search.categories[]" value="25059">
			<cfhttpparam type="url" name="search.categories[]" value="25043">
			<cfhttpparam type="url" name="search.categories[]" value="25044">
			<cfhttpparam type="url" name="search.categories[]" value="25046">
			<cfhttpparam type="url" name="search.categories[]" value="25047">
			<cfhttpparam type="url" name="search.categories[]" value="24994">
			<cfhttpparam type="url" name="search.categories[]" value="25067">
			<cfhttpparam type="url" name="search.categories[]" value="24968">
			<cfhttpparam type="url" name="search.categories[]" value="25042">
			<cfhttpparam type="url" name="search.categories[]" value="25048">
			<cfhttpparam type="url" name="search.categories[]" value="25049">
			<cfhttpparam type="url" name="search.categories[]" value="24985">
			<cfhttpparam type="url" name="search.categories[]" value="25003">

		<cfelseif categoryType EQ "B">

			<cfhttpparam type="url" name="search.categories[]" value="24972">
			<cfhttpparam type="url" name="search.categories[]" value="25069">
			<cfhttpparam type="url" name="search.categories[]" value="24987">
			<cfhttpparam type="url" name="search.categories[]" value="25063">
			<cfhttpparam type="url" name="search.categories[]" value="25064">
			<cfhttpparam type="url" name="search.categories[]" value="24973">
			<cfhttpparam type="url" name="search.categories[]" value="25038">
			<cfhttpparam type="url" name="search.categories[]" value="25068">

		<cfelseif categoryType EQ "Alle">

		</cfif>
	
	</cfhttp>


	<cfset data = DeserializeJSON(#httpResponse.filecontent#)>
	<cfset events = data["@graph"]>

	<!---<cfdump var="#events.1#">--->

	
	<cfif categoryType EQ "A">
		<h2>Events mit den Eventtypen (sofort aktiv):</h2>
		<ul>
			<li>odta:AdventMarket</li>
			<li>odta:Ball</li>
			<li>odta:Ballet</li>
			<li>odta:HarvestFestival</li>
			<li>odta:CarnivalParade</li>
			<li>odta:CarnivalSession</li>
			<li>odta:FestivalEnumeration</li>
			<li>odta:OpenAirTheater</li>
			<li>odta:HistoricalMarket</li>
			<li>odta:HistoricalParade</li>
			<li>odta:ChildrenTheater</li>
			<li>odta:Comedy</li>
			<li>odta:ArtsAndCraftsFair</li>
			<li>odta:FestivalOfLights</li>
			<li>odta:MedievalMarket</li>
			<li>odta:Musical</li>
			<li>odta:MusicalTheater</li>
			<li>odta:Opera</li>
			<li>odta:Operetta</li>
			<li>odta:CityFestival</li>
			<li>odta:StreetFoodFestival</li>
			<li>odta:DanceEventEnumeration</li>
			<li>odta:DanceTheater</li>
			<li>odta:TheaterFestival</li>
			<li>odta:VarietyShow</li>
			<li>odta:ExhibitionOpening</li>
			<li>odta:WineFestival</li>
		</ul>

	<cfelseif categoryType EQ "B">

		<h2>Events mit den Eventtypen (zu gehmigen):</h2>
		<ul>
			<li>odta:Excursion</li>
			<li>odta:Brunch</li>
			<li>odta:PermanentExhibition</li>
			<li>odta:FoodEventEnumeration</li>
			<li>odta:FoodMarket</li>
			<li>odta:Seminar</li>
			<li>odta:TheaterEventEnumeration</li>
			<li>odta:Tasting</li>
		</ul>

	<cfelseif categoryType EQ "Alle">
		<h2>Alle Events:</h2>
	</cfif>

	<table>
		<thead>
			<th>Eventname</th>
			<th>Beschreibung</th>
			<th>EventTyp</th>
			<th>Ort</th>
			<th>Termin(e)</th>
			<th>Bild(er)</th>
			<th>Veranstalter</th>
		</thead>
		<tbody>

			<cfif arrayLen(events) GT 0>

				<cfloop array="#events#" index="event">
					<tr>
						<td>#event["name"]#</td>
						<td>#event["description"]#</td>
						<td>
							<cfif structKeyExists(event, "odta:kindOfEvent")>
								<cfloop array="#event["odta:kindOfEvent"]#" index="eventType">
									#eventType#<br>
								</cfloop>
							<cfelse>
								kein EventType vorhanden
							</cfif>						
						</td>
						<td>
							<cfif structKeyExists(event, "location")>
								<cfset eventLocation = #event["location"]#>
								<cfif structKeyExists(eventLocation, "name")>
									#eventLocation["name"]#
								<cfelse>
									kein Ortsname vorhanden
								</cfif>							
							<cfelse>
								kein Ort vorhanden
							</cfif>
						</td>
						<td>
							<cfif structKeyExists(event, "eventSchedule")>
								<cfset eventSchedules = #event["eventSchedule"]#>
								<cfloop array="#eventSchedules#" index="eventSchedule">
									#LSDateFormat(eventSchedule["startDate"], "dd.mm.yyyy")#
									<cfif structKeyExists(eventSchedule, "startTime")>
										#LSTimeFormat(eventSchedule["startTime"], "HH:nn")#<br>
									<cfelse>
										<br />
									</cfif>
								</cfloop>	
							<cfelse>
								kein Termin vorhanden
							</cfif>
						</td>
						<td>
							<cfif structKeyExists(event, "image")>
								<cfloop array="#event["image"]#" index="eventImage">
									<cfif structKeyExists(eventImage, "name")>
										<img src="#eventImage["contentUrl"]#" alt="#eventImage["name"]#" width="180" />
									<cfelse>
										<img src="#eventImage["contentUrl"]#" width="180" />
									</cfif>								
								</cfloop>
							<cfelse>
								kein Bild vorhanden
							</cfif>
						</td>
						<td>
							<cfif structKeyExists(event, "organizer")>
								<cfset eventOrganizer = #event["organizer"]#>
								<cfif structKeyExists(eventOrganizer, "name")>
									#eventOrganizer["name"]#
								<cfelse>
									kein Veranstaltername vorhanden
								</cfif>
								
							<cfelse>
								kein Veranstalter vorhanden
							</cfif>
						</td>
					</tr>
				</cfloop>

			<cfelse>
				<td colspan="7">keine Daten gefunden.</td>
			</cfif>
			
		</tbody>
	</table>

	<br /><br />

</cffunction>

</cfoutput>