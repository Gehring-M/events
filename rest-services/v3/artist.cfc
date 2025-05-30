component rest="true" restpath="/artist" {
    include "../../ameisen/functions.cfm";

    remote struct function getAll() httpmethod="GET" restpath="" returnformat="json" {
        // Alle Artists laden
        var artists = queryExecute(
            "SELECT * FROM artist ORDER BY name",
            [],
            {datasource="#getConfig('DSN')#"}
        );
        return {
            success: true,
            artists: artists
        };
    }

    
    remote struct function get(numeric id restargsource="Path") httpmethod="GET" restpath="/{id}" returnformat="json" {
        // Einzelnen Artist laden
        var artist = queryExecute(
            "SELECT * FROM artist WHERE id = :id",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );
        
        // Zugehörige Veranstaltungen über die Relationstabelle laden
        var veranstaltungen = queryExecute(
            "SELECT v.* 
             FROM veranstaltung v 
             INNER JOIN r_veranstaltung_artist va ON v.id = va.veranstaltung_fk 
             WHERE va.artist_fk = :id 
             ORDER BY v.von DESC",
            {id={value=arguments.id, cfsqltype="cf_sql_integer"}},
            {datasource="#getConfig('DSN')#"}
        );

        return {
            success: true,
            artist: artist,
            veranstaltungen: veranstaltungen
        };
    }
   
}
