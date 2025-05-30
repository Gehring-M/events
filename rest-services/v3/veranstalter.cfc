component rest="true" restpath="/veranstalter" {
    include "../../ameisen/functions.cfm";

    remote struct function getAll() httpmethod="GET" restpath="" returnformat="json" {
        // Alle Veranstalter laden
        var veranstalter = queryExecute(
            "SELECT * FROM veranstalter ORDER BY name",
            [],
            {datasource="#getConfig('DSN')#"}
        );
        return {
            success: true,
            veranstalter: veranstalter
        };
    }

    remote struct function get(numeric id restargsource="Path") httpmethod="GET" restpath="/{id}" returnformat="json" {
        // Einzelnen Veranstalter laden
        var veranstalter = queryExecute(
            "SELECT * FROM veranstalter WHERE id = :id",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );
        
        // Zugehörige Veranstaltungen über Relationstabelle laden
        var veranstaltungen = queryExecute(
            "SELECT v.* 
             FROM veranstaltung v 
             INNER JOIN r_veranstaltung_veranstalter rv ON v.id = rv.veranstaltung_fk 
             WHERE rv.veranstalter_fk = :id 
             ORDER BY v.von DESC",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );

        return {
            success: true,
            veranstalter: veranstalter,
            veranstaltungen: veranstaltungen
        };
    }
}