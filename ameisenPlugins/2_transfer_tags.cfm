<cfif isAdmin()>
<cfsilent>
	<head>
		<link href="../ameisen/amstyle.css" rel="stylesheet" type="text/css">
	</head>
</cfsilent>
<cfinclude template="../ameisen/gui/ameisen_html_head.cfm">
<cfset LoadStyleSheet("/ameisenPlugins/pluginstyles.css")>

<cfparam name="url['pluginmode']" default="uebersicht">
<cfset errormessages = ArrayNew(1)>
<cfset infomessages = ArrayNew(1)>
<cfset successmessages = ArrayNew(1)>

<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Überprüfungen diverser Eingaben, Speicher-Vorgänge, etc. - Meldungen in den entsprechenden Arrays hinzufügen.
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<!---
<cfset ArrayAppend(errormessages,"Das ist Fehlermeldung 1")>
<cfset ArrayAppend(infomessages,"Das ist Infomeldung 1")>
<cfset ArrayAppend(successmessages,"Das ist Successmeldung 1")>
--->

<!--- init --->
<cfset correct_types = []>
<cfset transfer_tags = []>
<cfset validInput = true>
<cfset alreadyUpdated = false>
<cfset decision = "">
<cfset typeWClause = "1=1 ">
<cfset tagWClause = "1=1 ">

<!--- fast inits --->
<cfparam name="form['start_numeric']" type="string" default="0">
<cfparam name="form['use_kb_flag']" type="string" default="0">

<!--- validate inputs --->
<cfif url['pluginmode'] EQ "transfer">

    <!--- check if the script did already execute --->
    <cfquery name="checkTable" datasource="#getConfig('DSN')#">
        SELECT * FROM typ WHERE 1 = 0;
    </cfquery>
    <cfset columnList = checkTable.columnList>
    <cfif columnList NEQ "ID,NAME,KB">
        <cfset alreadyUpdated = true>
    <cfelse>
        <cfif form['start_numeric'] AND form['use_kb_flag']>
            <cfset decision &= 'Annahme ... Ein <span class="special-word">Typ</span> beginnt mit einem <span class="special-word">numerischem Wert</span> und wird als <span class="special-word">Chip</span> auf Kulturbezirk angezeigt.'>
            <cfset typeWClause &= " AND name REGEXP '^[0-9]' AND kb = 1">
            <cfset tagWClause &= " AND name REGEXP '^[^0-9]' AND (kb = 0 OR kb IS NULL)">
        <cfelseif form['start_numeric']>
            <cfset decision &= 'Annahme ... Ein <span class="special-word">Typ</span> beginnt mit einem <span class="special-word">numerischem Wert</span>.'>
            <cfset typeWClause &= " AND name REGEXP '^[0-9]'">
            <cfset tagWClause &= " AND name REGEXP '^[^0-9]'">
        <cfelseif form['use_kb_flag']>
            <cfset decision &= 'Annahme ... Ein <span class="special-word">Typ</span> wird auf Kulturbezirk als <span class="special-word">Chip</span> angezeigt.'>
            <cfset typeWClause &= " AND kb = 1">
            <cfset tagWClause &= " AND (kb = 0 OR kb IS NULL)">
        <cfelse>
            <cfset decision &= 'Geben Sie bitte an, wie der Typ berechnet werden soll.'>
            <cfset validInput = false>
        </cfif>
    </cfif>
</cfif>


<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>

<!-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Beginn Ausgabe
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------->
<cfoutput>
<div class="cmstable">
	<div class="cmstabledivhead">
        Transfer Tags
    </div>
    <div class="cmstabledivcontent">
        <form id="transfer_button" action="2_transfer_tags.cfm?pluginmode=transfer" method="post">
            <div class="form-field">
                <label for="start_numeric">Types start numerical</label>
                <input id="start_numeric" name="start_numeric" type="checkbox" value="1">
            </div>
            <div class="form-field">
                <label for="use_kb_flag">Types are chips on KB</label>
                <input id="use_kb_flag" name="use_kb_flag" type="checkbox" value="1">
            </div>
            <!--- submit --->
            <button type="submit">Transfer</button>
        </form>
    </div>
</div>
<cfif ArrayLen(errormessages) OR ArrayLen(infomessages) OR ArrayLen(successmessages)>
	<div class="cmstable">
		<cfloop list="error,info,success" index="cMessagemode">
			<cfswitch expression="#cMessagemode#">
				<cfcase value="error"><cfset cMessageClass = "errorBox"></cfcase>
				<cfcase value="info"><cfset cMessageClass = "infoBoxImportant"></cfcase>
				<cfcase value="success"><cfset cMessageClass = "successBox"></cfcase>
			</cfswitch>
			<cfset cArray = Evaluate("#cMessagemode#messages")>
			<cfif ArrayLen(cArray)>
				<div class="#cMessageClass#">
					<cfloop from="1" to="#ArrayLen(cArray)#" index="cMessage">
						#cArray[cMessage]#<cfif cMessage neq ArrayLen(cArray)><br /></cfif>
					</cfloop>
				</div>
			</cfif>
		</cfloop>
	</div>
</cfif>
<cfswitch expression="#url['pluginmode']#">
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<cfcase value="uebersicht">
<div class="description">
	<div class="description-header">
		<h3>Beschreibung</h3> 
	</div>
    <div class="description-body">
        <p>Dieses Skript transferiert <span class="special-word">TAGS</span> aus der Tabelle [ typ ] und transferiert diese in die Tabelle [ tag ].</p>
    </div>
</div>
</cfcase>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
<cfcase value="transfer">
<div class="result">
    <cfif NOT alreadyUpdated>
	<div class="result-header">
		<h2>Starte Datentransfer ...</h2> 
	</div>
    </cfif>
    <div class="result-body">
        <!--- SHOW IF SCRIPT DID ALREADY EXECUTE --->
        <cfif alreadyUpdated>
            <div class="already-updated">
                <div class="already-updated-header">
                    <h3>Skript wurde bereits ausgeführt</h3>
                </div>
                <div class="already-updated-body">
                    <p>Die Datenbank hat bereits die richtige Struktur !</p>
                </div>
            </div>
        <!--- SHOW FOR VALID CONFIGURATION --->
        <cfelseif validInput>
            <!--- SHOW DECISION --->
            <div class="user-decision">
                <h3>Kriterium des Benutzers</h3>
                <p>#decision#</p>
            </div>

            <cfset types = getStructuredContent(nodetype=2105, whereclause=typeWClause)>
            <cfset tags = getStructuredContent(nodetype=2105, whereclause=tagWClause)>
            <cfset knownTags = getStructuredContent(nodetype=2106)>
            <cfset tagsToTransfer = []>

            <!--- get IDs --->
            <cfloop query="tags">
                <cfset ArrayAppend(tagsToTransfer, tags.id)>
            </cfloop>

            <!--- RESULTS FROM TYP --->
            <div class="extracted-fields">
                <div class="extracted-fields-header">
                    <h3>Extrahierte Zeilen aus der Tabelle [ typ ]</h3>
                </div>
                <div class="extracted-fields-body">
                    <div class="extracted-tags">
                        <div class="extracted-tags-header">
                            <h3>Tags</h3>
                        </div>
                        <div class="extracted-tags-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Name</th>
                                        <th>Als Chip auf Kulturbezirk</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!--- TABLE ROWS --->
                                    <cfloop query="tags">
                                    <tr>
                                        <td>#tags.id#</td>
                                        <td>#tags.name#</td>
                                        <td>#tags.kb#</td>
                                    </tr>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="extracted-types">
                        <div class="extracted-types-header">
                            <h3>Types</h3>
                        </div>
                        <div class="extracted-types-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>ID</th>
                                        <th>Name</th>
                                        <th>Als Chip auf Kulturbezirk</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <!--- TABLE ROWS --->
                                    <cfloop query="types">
                                    <tr>
                                        <td>#types.id#</td>
                                        <td>#types.name#</td>
                                        <td>#types.kb#</td>
                                    </tr>
                                    </cfloop>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- RESULTS FROM TAG --->
            <div class="known-tags">
                <div class="known-tags-header">
                    <h3>Bereits bestehende tags in der Tabelle [ tag ]</h3>
                </div>
                <div class="known-tags-body">
                    <table>
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                            </tr>
                        </thead>
                        <tbody>
                            <!--- TABLE ROWS --->
                            <cfloop query="knownTags">
                            <tr>
                                <td>#knownTags.id#</td>
                                <td>#knownTags.name#</td>
                            </tr>
                            </cfloop>
                        </tbody>
                    </table>
                </div>
            </div>

            <cfset typeRelations = getStructuredContent(nodetype=2115)>
            <cfset tagRelations = getStructuredContent(nodetype=2116)>

            <cfset relationTransfers = getStructuredContent(nodetype=2115, whereclause="typ_fk IN (#ArrayToList(tagsToTransfer)#)")>

            <!--- RELATIONS --->
            <div class="relations">
                <div class="relations-header">
                    <h3>Betroffene Relationen</h3>
                </div>
                <div class="relations-body">
                    <div class="tag-relations">
                        <div class="tag-relations-header">
                            <h3>Relation [ r_veranstaltung_tag ]</h3>
                        </div>
                        <div class="tag-relations-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Gesamtanzahl</th>
                                        <th>Betroffen</th>
                                        <th>Anzahl nach dem Transfer (soll)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>#tagRelations.recordCount#</td>
                                        <td>0</td>
                                        <td>#tagRelations.recordCount + relationTransfers.recordCount#</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="type-relations">
                        <div class="type-relations-header">
                            <h3>Relation [ r_veranstaltung_typ ]</h3>
                        </div>
                        <div class="type-relations-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Gesamtanzahl</th>
                                        <th>Betroffen</th>
                                        <th>Anzahl nach dem Transfer (soll)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>#typeRelations.recordCount#</td>
                                        <td>#relationTransfers.recordCount#</td>
                                        <td>#typeRelations.recordCount - relationTransfers.recordCount#</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- START TRANSFER (LOGIC) --->
            <cfset correctTagRelations = []>
            <cfset correctTypeRelations = []>
            <cfset isTag = false>
            <cfset rEventType = {}>
            <cfset rEventTag = {}>
            <cfset transferredTags = 0>

            <cfloop query="typeRelations">
                <cfset isTag = false>
                <cfloop array="#tagsToTransfer#" index="tagToTransfer">
                    <cfif typeRelations.typ_fk EQ tagToTransfer>
                        <cfset isTag = true>
                        <cfbreak>
                    </cfif>
                </cfloop>
                <cfif isTag>
                    <cfset rEventTag = {}>
                    <cfset rEventTag['id'] = typeRelations.id>
                    <cfset rEventTag['veranstaltung_fk'] = typeRelations.veranstaltung_fk>
                    <cfset rEventTag['tag_fk'] = tagToTransfer>
                    <cfset ArrayAppend(correctTagRelations, rEventTag)>
                <cfelse>
                    <cfset rEventType = {}>
                    <cfset rEventType['id'] = typeRelations.id>
                    <cfset rEventType['veranstaltung_fk'] = typeRelations.veranstaltung_fk>
                    <cfset rEventType['typ_fk'] = typeRelations.typ_fk>
                    <cfset ArrayAppend(correctTypeRelations, rEventType)>
                </cfif>
            </cfloop>

            <!--- DELETE ALL FROM r_veranstaltung_typ --->
            <cfquery name="deleteTypRelations" datasource="#getConfig('DSN')#">
                DELETE FROM r_veranstaltung_typ;
            </cfquery>
            <cfquery name="dropTypeRelations" datasource="#getConfig('DSN')#">
                DROP TABLE r_veranstaltung_typ;
            </cfquery>
            <!--- DELETE ALL FROM typ --->
            <cfquery name="deleteTyp" datasource="#getConfig('DSN')#">
                DELETE FROM typ;
            </cfquery>
            <!--- DROP TABLE typ --->
            <cfquery name="dropTyp" datasource="#getConfig('DSN')#">
                DROP TABLE typ;
            </cfquery>

            <!--- CREATE NEW TABLE typ --->
            <cfquery name="createTyp" datasource="#getConfig('DSN')#">
                CREATE TABLE typ (
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    kb_filter INT DEFAULT 0,
                    kb_form INT DEFAULT 0,
                    created_fk INT,
                    createdwhen DATETIME DEFAULT CURRENT_TIMESTAMP,
                    changed_fk INT,
                    changedwhen DATETIME ON UPDATE CURRENT_TIMESTAMP,
                    deleted_fk INT,
                    deletedwhen DATETIME
                );
            </cfquery>

            <!--- CREATE NEW TABLE r_veranstaltung_typ --->
            <cfquery name="createREventTyp" datasource="#getConfig('DSN')#">
                CREATE TABLE r_veranstaltung_typ (
                    -- column definitions
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    veranstaltung_fk INT,
                    typ_fk INT,
                    -- contraints
                    FOREIGN KEY (veranstaltung_fk) REFERENCES veranstaltung(id)
                        ON DELETE SET NULL 
                        ON UPDATE CASCADE,
                    FOREIGN KEY (typ_fk) REFERENCES typ(id)
                        ON DELETE SET NULL 
                        ON UPDATE CASCADE
                );
            </cfquery>

            <!--- START TRANSFER (UI) --->
            <div class="type-table">
                <div class="type-table-header">
                    <h3>Erstellen einer neuen Tabelle [ typ ] ...</h3>
                </div>
                <div class="type-table-body">
                    <div class="old-type-table">
                        <div class="old-type-table-header">
                            <h3>Alte Tabellenstruktur</h3>
                        </div>
                        <div class="old-type-table-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>id</th>
                                        <th>name</th>
                                        <th>kb</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>INT</td>
                                        <td>VARCHAR(255)</td>
                                        <td>INT</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="new-type-table">
                        <div class="new-type-table-header">
                            <h3>Neue Tabellenstruktur</h3>
                        </div>
                        <div class="new-type-table-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>id</th>
                                        <th>name</th>
                                        <th>kb_filter</th>
                                        <th>kb_form</th>
                                        <th>created_fk</th>
                                        <th>createdwhen</th>
                                        <th>changed_fk</th>
                                        <th>changedwhen</th>
                                        <th>deleted_fk</th>
                                        <th>deletedwhen</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>INT</td>
                                        <td>VARCHAR(255)</td>
                                        <td>INT</td>
                                        <td>INT</td>
                                        <td>INT</td>
                                        <td>DATETIME</td>
                                        <td>INT</td>
                                        <td>DATETIME</td>
                                        <td>INT</td>
                                        <td>DATETIME</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- INSERT TYPE ENTRIES --->
            <cfset insertedTypes = 0>
            <cfquery name="insertTypes" datasource="#getConfig('DSN')#">
                INSERT INTO typ (id, name, kb_filter, created_fk)
                VALUES 
                    <cfloop query="types">
                        <cfif insertedTypes EQ (types.recordCount - 1)>
                            (#types.id#, '#types.name#', 1, 2)
                            <cfset insertedTypes += 1>
                        <cfelse>
                            (#types.id#, '#types.name#', 1, 2),
                            <cfset insertedTypes += 1>
                        </cfif>
                    </cfloop>
            </cfquery>
            <!--- temp --->
            <cfquery name="dummyType" datasource="#getConfig('DSN')#" result="dummyInsert">
                INSERT INTO typ (name, kb_filter, created_fk)
                VALUES 
                    ('10 Test-Kategorie', 0, 2);
            </cfquery>
            <cfset insertedTypes += 1>
            <cfset dummyReference = dummyInsert.GENERATED_KEY>

            <cfset insertedTypeRelations = 0>
            <!--- INSERT TYPE RELATIONS BACK IN --->
            <cfquery name="insertTypeRelations" datasource="#getConfig('DSN')#">
                INSERT INTO r_veranstaltung_typ (id, veranstaltung_fk, typ_fk)
                VALUES 
                    <cfloop array="#correctTypeRelations#" item="typeRelation">
                        <cfif insertedTypeRelations EQ (ArrayLen(correctTypeRelations) - 1)>
                            (#typeRelation.id#, #typeRelation.veranstaltung_fk#, #typeRelation.typ_fk#)
                            <cfset insertedTypeRelations += 1>
                        <cfelse>
                            (#typeRelation.id#, #typeRelation.veranstaltung_fk#, #typeRelation.typ_fk#),
                            <cfset insertedTypeRelations += 1>
                        </cfif>
                    </cfloop>
            </cfquery>

            <!--- START TRANSFER (UI) --->
            <div class="type-transfer">
                <div class="type-transfer-header">
                    <h3>Befüllen der neuen Tabelle [ typ ] und der Tabelle [ r_veranstaltung_typ ] ...</h3>
                </div>
                <div class="type-transfer-body">
                    <div class="type-entity">
                        <div class="type-entity-header">
                            <h3>Einträge in der Tabelle [ typ ]</h3>
                        </div>
                        <div class="type-entity-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Geschriebene Einträge (ist)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>#insertedTypes#</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="type-relation">
                        <div class="type-relation-header">
                            <h3>Einträge in der Tabelle [ r_veranstaltung_typ ]</h3>
                        </div>
                        <div class="type-relation-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Geschriebene Einträge (ist)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>#insertedTypeRelations#</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <!--- DELETE ALL FROM r_veranstaltung_typ --->
            <cfquery name="deleteTagRelations" datasource="#getConfig('DSN')#">
                DELETE FROM r_veranstaltung_tag;
            </cfquery>
            <cfquery name="dropTagRelations" datasource="#getConfig('DSN')#">
                DROP TABLE r_veranstaltung_tag;
            </cfquery>
            <!--- DELETE ALL FROM typ --->
            <cfquery name="deleteTags" datasource="#getConfig('DSN')#">
                DELETE FROM tag;
            </cfquery>
            <!--- DROP TABLE typ --->
            <cfquery name="dropTag" datasource="#getConfig('DSN')#">
                DROP TABLE tag;
            </cfquery>

            <!--- CREATE NEW TABLE tag --->
            <cfquery name="createTag" datasource="#getConfig('DSN')#">
                CREATE TABLE tag (
                    -- column definitions
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    name VARCHAR(255) NOT NULL,
                    kb_form INT DEFAULT 0,
                    typ_fk INT, 
                    created_fk INT,
                    createdwhen DATETIME DEFAULT CURRENT_TIMESTAMP,
                    changed_fk INT,
                    changedwhen DATETIME ON UPDATE CURRENT_TIMESTAMP,
                    deleted_fk INT,
                    deletedwhen DATETIME,
                    -- constraints 
                    FOREIGN KEY (typ_fk) REFERENCES typ(id)
                        ON DELETE SET NULL 
                        ON UPDATE CASCADE
                )
            </cfquery>

            <!--- CREATE NEW TABLE r_veranstaltung_tag --->
            <cfquery name="createREventTag" datasource="#getConfig('DSN')#">
                CREATE TABLE r_veranstaltung_tag (
                    -- column definitions
                    id INT AUTO_INCREMENT PRIMARY KEY,
                    veranstaltung_fk INT,
                    tag_fk INT,
                    -- contraints
                    FOREIGN KEY (veranstaltung_fk) REFERENCES veranstaltung(id)
                        ON DELETE SET NULL 
                        ON UPDATE CASCADE,
                    FOREIGN KEY (tag_fk) REFERENCES tag(id)
                        ON DELETE SET NULL 
                        ON UPDATE CASCADE
                );
            </cfquery>

            <div class="tag-table">
                <div class="tag-table-header">
                    <h3>Erstellen einer neuen Tabelle [ tag ] ...</h3>
                </div>
                <div class="tag-table-body">
                    <div class="old-tag-table">
                        <div class="old-tag-table-header">
                            <h3>Alte Tabellenstruktur</h3>
                        </div>
                        <div class="old-tag-table-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>id</th>
                                        <th>name</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>INT</td>
                                        <td>VARCHAR(255)</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="new-tag-table">
                        <div class="new-tag-table-header">
                            <h3>Neue Tabellenstruktur</h3>
                        </div>
                        <div class="new-tag-table-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>id</th>
                                        <th>name</th>
                                        <th>kb_form</th>
                                        <th>created_fk</th>
                                        <th>createdwhen</th>
                                        <th>changed_fk</th>
                                        <th>changedwhen</th>
                                        <th>deleted_fk</th>
                                        <th>deletedwhen</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>INT</td>
                                        <td>VARCHAR(255)</td>
                                        <td>INT</td>
                                        <td>INT</td>
                                        <td>DATETIME</td>
                                        <td>INT</td>
                                        <td>DATETIME</td>
                                        <td>INT</td>
                                        <td>DATETIME</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

            <cfset mergedTags = []>
            <cfset duplicateIDs = []>
            <cfset duplicateNames = []>
            
            <!--- POPULATE INITIAL TAGS --->
            <cfloop query="knownTags">
                <cfset tagStruct = {}>
                <cfset tagStruct['id'] = knownTags.id>
                <cfset tagStruct['name'] = knownTags.name>
                <cfset ArrayAppend(mergedTags, tagStruct)>
            </cfloop>
            
            <!--- MERGE NEW TAGS --->
            <cfloop query="tags">
                <cfset foundMatch = false>
                <!--- CHECK IF THIS TAG ALREADY EXISTS --->
                <cfloop array="#mergedTags#" index="mergedTag">
                    <!--- IDENTICAL ENTRY --->
                    <cfif (mergedTag.id EQ tags.id) AND (mergedTag.name EQ tags.name)>
                        <cfset foundMatch = true>
                        <cfbreak>
                    <!--- SAME NAME = ALREADY THERE --->
                    <cfelseif (mergedTag.name EQ tags.name)>
                        <cfset duplicateNameStruct = {}>
                        <cfset duplicateNameStruct['newID'] = mergedTag.id>
                        <cfset duplicateNameStruct['oldID'] = tags.id>
                        <cfset ArrayAppend(duplicateNames, duplicateNameStruct)>
                        <cfset foundMatch = true>
                        <cfbreak>
                    <!--- SAME ID = DUPLICATE ID --->
                    <cfelseif (mergedTag.id EQ tags.id)>
                        <cfset ArrayAppend(duplicateIDs, tags.id)>
                        <cfset foundMatch = true>
                        <cfbreak>
                    </cfif>
                </cfloop>
                
                <!--- ADD NEW TAG IF NO MATCH FOUND --->
                <cfif NOT foundMatch>
                    <cfset tagStruct = {}>
                    <cfset tagStruct['id'] = tags.id>
                    <cfset tagStruct['name'] = tags.name>
                    <cfset ArrayAppend(mergedTags, tagStruct)>
                </cfif>
            </cfloop>

            <!--- HANDLE DUPLICATE IDs --->
            <cfset nextTagID = 0>
            <cfloop array="#mergedTags#" index="mergedTag">
                <cfif mergedTag.id GT nextTagID>
                    <cfset nextTagID = mergedTag.id + 1>
                </cfif>
            </cfloop>

            <!--- SET NEW ID FOR DUPLICATE ENTRIES --->
            <cfloop array="#duplicateIDs#" index="duplicateID">
                <cfset oldID = duplicateID>
                <!--- Find the tag with duplicate ID and add it with new ID --->
                <cfloop query="tags">
                    <cfif tags.id EQ oldID>
                        <cfset tagStruct = {}>
                        <cfset tagStruct['id'] = nextTagID>
                        <cfset tagStruct['name'] = tags.name>
                        <cfset ArrayAppend(mergedTags, tagStruct)>
                        <!--- Update any tag relations that reference the old duplicate ID --->
                        <cfloop array="#correctTagRelations#" index="correctTagRelation">
                            <cfif correctTagRelation.tag_fk EQ oldID>
                                <cfset correctTagRelation.tag_fk = nextTagID>
                            </cfif>
                        </cfloop>
                        <!--- Exit once we found the matching tag --->
                        <cfbreak> 
                    </cfif>
                </cfloop>
                <!------>
                <cfset nextTagID += 1>
            </cfloop>

            <!--- RESOLVE DUPLICATE NAMES --->
            <cfloop array="#duplicateNames#" index="duplicateName">
                <!--- Update any tag relations that reference the same name --->
                <cfloop array="#correctTagRelations#" index="correctTagRelation">
                    <cfif correctTagRelation.tag_fk EQ duplicateName.oldID>
                        <cfset correctTagRelation.tag_fk = duplicateName.newID>
                    </cfif>
                </cfloop>
            </cfloop>


            <div class="tag-duplicates">
                <div class="tag-duplicates-header">
                    <h3>Mergen der alten und neuen Tags + Entfernen von Duplikaten [ ID ] und [ Name ] ...</h3>
                </div>
                <div class="tag-duplicates-body">
                    <table>
                        <thead>
                            <tr>
                                <th>Duplikat IDs (neue freie ID wird berechnet)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <tr>
                                <cfset duplicatesAsString = ArrayToList(duplicateIDs)>
                                <td>#duplicatesAsString#</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!--- INSERT TAG ENTRIES --->
            <cfset insertedTags = 0>
            <cfquery name="insertTags" datasource="#getConfig('DSN')#">
                INSERT INTO tag (id, name, typ_fk, created_fk)
                VALUES 
                    <cfloop array="#mergedTags#" index="mergedTag">
                        <cfif insertedTags EQ (ArrayLen(mergedTags) - 1)>
                            (#mergedTag.id#, '#mergedTag.name#', #dummyReference#, 2)
                            <cfset insertedTags += 1>
                        <cfelse>
                            (#mergedTag.id#, '#mergedTag.name#', #dummyReference#, 2),
                            <cfset insertedTags += 1>
                        </cfif>
                    </cfloop>
            </cfquery>

            <!--- INSERT REMAINING TAG RELATIONS --->
            <cfset mergedTagRelations = []>
            <cfset duplicateRelationIDs = []>

            <!--- PREFILL TAG RELATIONS WITH PREVIOUS TAG RELATIONS --->
            <cfloop query="tagRelations">
                <cfset tagRelationStruct = {}>
                <cfset tagRelationStruct['id'] = tagRelations.id>
                <cfset tagRelationStruct['veranstaltung_fk'] = tagRelations.veranstaltung_fk>
                <cfset tagRelationStruct['tag_fk'] = tagRelations.tag_fk>
                <cfset ArrayAppend(mergedTagRelations, tagRelationStruct)>
            </cfloop>

            <!--- MERGE WITH TRANSFERRED TAG RELATIONS --->
            <cfloop array="#correctTagRelations#" index="correctTagRelation">
                <cfset foundDuplicateID = false>
                <!--- CHECK IF THIS ID ALREADY EXISTS --->
                <cfloop array="#mergedTagRelations#" index="mergedTagRelation">
                    <!--- IDENTICAL ID --->
                    <cfif (mergedTagRelation.id EQ correctTagRelation.id)>
                        <cfset foundDuplicateID = true>
                        <cfset ArrayAppend(duplicateRelationIDs, correctTagRelation.id)>
                    </cfif>
                </cfloop>
                
                <!--- ADD NEW ID IF NO MATCH WAS FOUND --->
                <cfif NOT foundDuplicateID>
                    <cfset tagRelationStruct = {}>
                    <cfset tagRelationStruct['id'] = correctTagRelation.id>
                    <cfset tagRelationStruct['veranstaltung_fk'] = correctTagRelation.veranstaltung_fk>
                    <cfset tagRelationStruct['tag_fk'] = correctTagRelation.tag_fk>
                    <cfset ArrayAppend(mergedTagRelations, tagRelationStruct)>
                </cfif>
            </cfloop>

            <!--- HANDLE DUPLICATE IDs --->
            <cfset nextTagRelationID = 0>
            <cfloop array="#mergedTagRelations#" index="mergedTagRelation">
                <cfif mergedTagRelation.id GT nextTagRelationID>
                    <cfset nextTagRelationID = mergedTagRelation.id + 1>
                </cfif>
            </cfloop>


            <!--- SET NEW ID FOR DUPLICATE ENTRIES --->
            <cfloop array="#duplicateRelationIDs#" index="duplicateRelationID">
                <cfset oldRelationID = duplicateRelationID>
                <!--- FIND RELATION WITH DUPLICATE ID AND UPDATE --->
                <cfloop array="#correctTagRelations#" index="correctTagRelation">
                    <cfif correctTagRelation.id EQ oldRelationID>
                        <cfset tagRelationStruct = {}>
                        <cfset tagRelationStruct['id'] = nextTagRelationID>
                        <cfset tagRelationStruct['veranstaltung_fk'] = correctTagRelation.veranstaltung_fk>
                        <cfset tagRelationStruct['tag_fk'] = correctTagRelation.tag_fk>
                        <cfset ArrayAppend(mergedTagRelations, tagRelationStruct)>
                        <!--- EXIT ONCE WE FOUND THE MATCHING ID --->
                        <cfbreak>
                    </cfif>
                </cfloop>
                <!--- INCREMENT --->
                <cfset nextTagRelationID += 1>
            </cfloop>

            <!--- INSERT TAG RELATIONS --->
            <cfset insertedTagRelations = 0>
            <cfquery name="insertTagRelations" datasource="#getConfig('DSN')#">
                INSERT INTO r_veranstaltung_tag (id, veranstaltung_fk, tag_fk)
                VALUES 
                    <cfloop array="#mergedTagRelations#" index="mergedTagRelation">
                        <cfif insertedTagRelations EQ (ArrayLen(mergedTagRelations) - 1)>
                            (#mergedTagRelation.id#, #mergedTagRelation.veranstaltung_fk#, #mergedTagRelation.tag_fk#)
                            <cfset insertedTagRelations += 1>
                        <cfelse>
                            (#mergedTagRelation.id#, #mergedTagRelation.veranstaltung_fk#, #mergedTagRelation.tag_fk#),
                            <cfset insertedTagRelations += 1>
                        </cfif>
                    </cfloop>
            </cfquery>

            <div class="tag-transfer">
                <div class="tag-transfer-header">
                    <h3>Befüllen der neuen Tabelle [ tag ] und der Tabelle [ r_veranstaltung_tag ] ...</h3>
                </div>
                <div class="tag-transfer-body">
                    <div class="tag-entity">
                        <div class="tag-entity-header">
                            <h3>Einträge in der Tabelle [ tag ]</h3>
                        </div>
                        <div class="tag-entity-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Geschriebene Einträge (ist)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        <td>#insertedTags#</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <div class="tag-relation">
                        <div class="tag-relation-header">
                            <h3>Einträge in der Tabelle [ r_veranstaltung_tag ]</h3>
                        </div>
                        <div class="tag-relation-body">
                            <table>
                                <thead>
                                    <tr>
                                        <th>Geschriebene Einträge (ist)</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <tr>
                                        
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>

        </cfif>
    </div>
</div>
</cfcase>
<!------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------>
</cfswitch>
</cfoutput>
</cfif>