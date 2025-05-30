component rest="true" restpath="/veranstaltung" {
    include "../../ameisen/functions.cfm";

    remote struct function getAll() httpmethod="GET" restpath="" returnformat="json" {
        // Alle Veranstaltungen laden
        var veranstaltungen = queryExecute(
            "SELECT * FROM veranstaltung ORDER BY von DESC",
            [],
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
            "SELECT * FROM veranstaltung WHERE id = :id",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );
        
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
