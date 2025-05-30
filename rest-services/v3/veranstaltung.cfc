component rest="true" restpath="/veranstaltung" {
    include "../../ameisen/functions.cfm";

    remote struct function getAll() httpmethod="GET" restpath="" returnformat="json" {
        // Alle Veranstaltungen laden
        var veranstaltungen = queryExecute(
            "SELECT * FROM veranstaltung WHERE visible = 1 ORDER BY von DESC",
            [],
            {datasource="#getConfig('DSN')#"}
        );
        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltungen": []
        };
        
        // Veranstaltungen in das gewünschte Format umwandeln
        for (var i = 1; i <= veranstaltungen.recordCount; i++) {
            var event = {};
            for (var col in veranstaltungen.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                event[lCase(col)] = veranstaltungen[col][i];
            }
            arrayAppend(formattedResponse.veranstaltungen, event);
        }
        
        return formattedResponse;
    }

    // Veranstaltungen nach Zeitraum filtern
    remote struct function getByDateRange(
        date fromDate restargsource="Query",
        date toDate restargsource="Query"
    ) httpmethod="GET" restpath="filter/date" returnformat="json" {
        var veranstaltungen = queryExecute(
            "SELECT * FROM veranstaltung 
             WHERE visible = 1
               AND (
                  /* Veranstaltung beginnt im Zeitraum */
                  (von >= :fromDate AND von <= :toDate)
                  /* Veranstaltung endet im Zeitraum */
                  OR (bis IS NOT NULL AND bis >= :fromDate AND bis <= :toDate)
                  /* Veranstaltung umfasst den gesamten Zeitraum */
                  OR (von <= :fromDate AND (bis IS NOT NULL AND bis >= :toDate))
               )
             ORDER BY von ASC",
            {
                fromDate={value=arguments.fromDate, cfsqltype="cf_sql_date"},
                toDate={value=arguments.toDate, cfsqltype="cf_sql_date"}
            },
            {datasource="#getConfig('DSN')#"}
        );
        
        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltungen": []
        };
        
        // Veranstaltungen in das gewünschte Format umwandeln
        for (var i = 1; i <= veranstaltungen.recordCount; i++) {
            var event = {};
            for (var col in veranstaltungen.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                event[lCase(col)] = veranstaltungen[col][i];
            }
            arrayAppend(formattedResponse.veranstaltungen, event);
        }
        
        return formattedResponse;
    }
    
    // Veranstaltungen nach Jahr filtern
    remote struct function getByYear(
        numeric year restargsource="Path"
    ) httpmethod="GET" restpath="filter/year/{year}" returnformat="json" {
        // Datumsbereich für das angegebene Jahr berechnen
        var startDate = createDate(arguments.year, 1, 1);
        var endDate = createDate(arguments.year, 12, 31);
        
        var veranstaltungen = queryExecute(
            "SELECT * FROM veranstaltung 
             WHERE visible = 1
               AND (
                  /* Veranstaltung beginnt im Jahr */
                  (von >= :startDate AND von <= :endDate)
                  /* Veranstaltung endet im Jahr */
                  OR (bis IS NOT NULL AND bis >= :startDate AND bis <= :endDate)
                  /* Veranstaltung umfasst das gesamte Jahr */
                  OR (von <= :startDate AND (bis IS NOT NULL AND bis >= :endDate))
               )
             ORDER BY von ASC",
            {
                startDate={value=startDate, cfsqltype="cf_sql_date"},
                endDate={value=endDate, cfsqltype="cf_sql_date"}
            },
            {datasource="#getConfig('DSN')#"}
        );
        
        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltungen": []
        };
        
        // Veranstaltungen in das gewünschte Format umwandeln
        for (var i = 1; i <= veranstaltungen.recordCount; i++) {
            var event = {};
            for (var col in veranstaltungen.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                event[lCase(col)] = veranstaltungen[col][i];
            }
            arrayAppend(formattedResponse.veranstaltungen, event);
        }
        
        return formattedResponse;
    }
    
    // Veranstaltungen der nächsten X Tage
    remote struct function getNextDays(
        numeric days restargsource="Path"
    ) httpmethod="GET" restpath="filter/next/{days}" returnformat="json" {
        // Sicherstellen, dass days eine positive Zahl ist
        if (arguments.days <= 0) {
            return {
                success: false,
                message: "Bitte eine positive Anzahl von Tagen angeben"
            };
        }
        
        // Optional: Maximale Anzahl von Tagen begrenzen, um Performance-Probleme zu vermeiden
        if (arguments.days > 365) {
            return {
                success: false,
                message: "Die maximale Anzahl von Tagen ist auf 365 begrenzt"
            };
        }
        
        // Datumsbereich berechnen
        var startDate = now();
        var endDate = dateAdd("d", arguments.days, startDate);
        
        var veranstaltungen = queryExecute(
            "SELECT * FROM veranstaltung 
             WHERE visible = 1
               AND (
                  /* Veranstaltung beginnt im Zeitraum */
                  (von >= :startDate AND von <= :endDate)
                  /* Veranstaltung endet im Zeitraum */
                  OR (bis IS NOT NULL AND bis >= :startDate AND bis <= :endDate)
                  /* Veranstaltung umfasst den gesamten Zeitraum */
                  OR (von <= :startDate AND (bis IS NOT NULL AND bis >= :endDate))
               )
             ORDER BY von ASC",
            {
                startDate={value=startDate, cfsqltype="cf_sql_date"},
                endDate={value=endDate, cfsqltype="cf_sql_date"}
            },
            {datasource="#getConfig('DSN')#"}
        );
        
        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltungen": []
        };
        
        // Veranstaltungen in das gewünschte Format umwandeln
        for (var i = 1; i <= veranstaltungen.recordCount; i++) {
            var event = {};
            for (var col in veranstaltungen.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                event[lCase(col)] = veranstaltungen[col][i];
            }
            arrayAppend(formattedResponse.veranstaltungen, event);
        }
        
        return formattedResponse;
    }

    // Veranstaltungen der nächsten X Tage nach Region filtern
    remote struct function getNextDaysByRegion(
        numeric days restargsource="Path",
        numeric regionId restargsource="Path"
    ) httpmethod="GET" restpath="filter/next/{days}/{regionId}" returnformat="json" {
        // Sicherstellen, dass days eine positive Zahl ist
        if (arguments.days <= 0) {
            return {
                success: false,
                message: "Bitte eine positive Anzahl von Tagen angeben"
            };
        }
        
        // Optional: Maximale Anzahl von Tagen begrenzen, um Performance-Probleme zu vermeiden
        if (arguments.days > 365) {
            return {
                success: false,
                message: "Die maximale Anzahl von Tagen ist auf 365 begrenzt"
            };
        }
        
        // Datumsbereich berechnen
        var startDate = now();
        var endDate = dateAdd("d", arguments.days, startDate);
        
        var veranstaltungen = queryExecute(
            "SELECT v.* 
             FROM veranstaltung v
             INNER JOIN r_veranstaltung_region vr ON v.id = vr.veranstaltung_fk
             WHERE v.visible = 1
             AND vr.region_fk = :regionId
             AND (
                /* Veranstaltung beginnt im Zeitraum */
                (v.von >= :startDate AND v.von <= :endDate)
                /* Veranstaltung endet im Zeitraum */
                OR (v.bis IS NOT NULL AND v.bis >= :startDate AND v.bis <= :endDate)
                /* Veranstaltung umfasst den gesamten Zeitraum */
                OR (v.von <= :startDate AND (v.bis IS NOT NULL AND v.bis >= :endDate))
             )
             ORDER BY v.von ASC",
            {
                regionId={value=arguments.regionId, cfsqltype="cf_sql_integer"},
                startDate={value=startDate, cfsqltype="cf_sql_date"},
                endDate={value=endDate, cfsqltype="cf_sql_date"}
            },
            {datasource="#getConfig('DSN')#"}
        );
        
        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltungen": []
        };
        
        // Veranstaltungen in das gewünschte Format umwandeln
        for (var i = 1; i <= veranstaltungen.recordCount; i++) {
            var event = {};
            for (var col in veranstaltungen.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                event[lCase(col)] = veranstaltungen[col][i];
            }
            arrayAppend(formattedResponse.veranstaltungen, event);
        }
        
        return formattedResponse;
    }
    
    // Veranstaltungen nach Typ/Kategorie filtern
    remote struct function getByTyp(
        numeric typId restargsource="Path"
    ) httpmethod="GET" restpath="filter/typ/{typId}" returnformat="json" {
        var veranstaltungen = queryExecute(
            "SELECT v.* 
             FROM veranstaltung v
             INNER JOIN r_veranstaltung_typ vt ON v.id = vt.veranstaltung_fk
             WHERE v.visible = 1
             AND vt.typ_fk = :typId
             ORDER BY v.von ASC",
            {typId={value=arguments.typId, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );
        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltungen": []
        };
        
        // Veranstaltungen in das gewünschte Format umwandeln
        for (var i = 1; i <= veranstaltungen.recordCount; i++) {
            var event = {};
            for (var col in veranstaltungen.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                event[lCase(col)] = veranstaltungen[col][i];
            }
            arrayAppend(formattedResponse.veranstaltungen, event);
        }
        
        return formattedResponse;
    }

    // Nächste bevorstehende Veranstaltung nach Region
    remote struct function getNextUpcomingByRegion(
        numeric regionId restargsource="Path"
    ) httpmethod="GET" restpath="filter/region/{regionId}/upcomming" returnformat="json" {
        // Aktuelles Datum für Vergleich
        var currentDate = now();
        
        // Nur die nächste bevorstehende Veranstaltung für die angegebene Region laden
        var veranstaltungen = queryExecute(
            "SELECT v.* 
             FROM veranstaltung v
             INNER JOIN r_veranstaltung_region vr ON v.id = vr.veranstaltung_fk
             WHERE v.visible = 1
             AND vr.region_fk = :regionId
             AND (v.von >= :currentDate OR (v.bis IS NOT NULL AND v.bis >= :currentDate))
             ORDER BY v.von ASC
             LIMIT 1",
            {
                regionId={value=arguments.regionId, cfsqltype="cf_sql_integer"},
                currentDate={value=currentDate, cfsqltype="cf_sql_date"}
            },
            {datasource="#getConfig('DSN')#"}
        );
        
        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltung": {}
        };
        
        // Wenn eine Veranstaltung gefunden wurde, diese formatieren
        if (veranstaltungen.recordCount > 0) {
            for (var col in veranstaltungen.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                formattedResponse.veranstaltung[lCase(col)] = veranstaltungen[col][1];
            }
        }
        
        return formattedResponse;
    }

    remote struct function get(numeric id restargsource="Path") httpmethod="GET" restpath="/{id}" returnformat="json" {
        // Einzelne Veranstaltung laden
        var veranstaltung = queryExecute(
            "SELECT * FROM veranstaltung WHERE id = :id AND visible = 1",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );
        
        // Prüfen, ob Veranstaltung gefunden wurde
        if (veranstaltung.recordCount == 0) {
            return {
                success: false,
                message: "Veranstaltung nicht gefunden oder nicht sichtbar"
            };
        }
        
        // Zugehörige Artists laden
        var artists = queryExecute(
            "SELECT a.* 
             FROM artist a 
             INNER JOIN r_veranstaltung_artist va ON a.id = va.artist_fk 
             WHERE va.veranstaltung_fk = :id 
             ORDER BY a.name",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );
        
        // Veranstalter über Relationstabelle laden
        var veranstalter = queryExecute(
            "SELECT v.* 
             FROM veranstalter v 
             INNER JOIN r_veranstaltung_veranstalter rv ON v.id = rv.veranstalter_fk 
             WHERE rv.veranstaltung_fk = :id",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );

        // Format der Antwort an die Dokumentation anpassen
        var formattedResponse = {
            "success": true,
            "veranstaltung": {},
            "artists": [],
            "veranstalter": {}
        };
        
        // Veranstaltung formatieren
        if (veranstaltung.recordCount > 0) {
            for (var col in veranstaltung.columnList.listToArray()) {
                // Alle Spalten in Kleinbuchstaben umwandeln
                formattedResponse.veranstaltung[lCase(col)] = veranstaltung[col][1];
            }
        }
        
        // Artists formatieren
        for (var i = 1; i <= artists.recordCount; i++) {
            var artist = {};
            for (var col in artists.columnList.listToArray()) {
                artist[lCase(col)] = artists[col][i];
            }
            arrayAppend(formattedResponse.artists, artist);
        }
        
        // Veranstalter formatieren
        if (veranstalter.recordCount > 0) {
            for (var col in veranstalter.columnList.listToArray()) {
                formattedResponse.veranstalter[lCase(col)] = veranstalter[col][1];
            }
        }
        
        return formattedResponse;
    }

}
