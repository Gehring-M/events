component rest="true" restpath="/veranstaltung" {
    include "../../ameisen/functions.cfm";

    remote struct function getAll() httpmethod="GET" restpath="" returnformat="json" {
        // Alle Veranstaltungen laden
        var veranstaltungen = queryExecute(
            "SELECT * FROM veranstaltung WHERE visible = 1 ORDER BY von DESC",
            [],
            {datasource="#getConfig('DSN')#"}
        );
        return {
            success: true,
            veranstaltungen: veranstaltungen
        };
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
        
        return {
            success: true,
            veranstaltungen: veranstaltungen
        };
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
        
        return {
            success: true,
            veranstaltungen: veranstaltungen
        };
    }
    
    // Veranstaltungen der nächsten X Tage
    remote struct function getNextDays(
        numeric days restargsource="Path"
    ) httpmethod="GET" restpath="filter/next/{days}" returnformat="json" {
        // Nur bestimmte Werte für Tage zulassen
        if (arguments.days != 7 && arguments.days != 30 && arguments.days != 90) {
            return {
                success: false,
                message: "Nur 7, 30 oder 90 Tage erlaubt"
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
        
        return {
            success: true,
            veranstaltungen: veranstaltungen
        };
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
        return {
            success: true,
            veranstaltungen: veranstaltungen
        };
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

        return {
            success: true,
            veranstaltung: veranstaltung,
            artists: artists,
            veranstalter: veranstalter
        };
    }

}
