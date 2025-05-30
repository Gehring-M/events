# REST Services für Events

## Verfügbare Endpoints v3

### Artists
- `GET /rest/v3/artist` - Liste aller Artists
  - Sortiert nach Name
  - Response: `{ success: true, artists: [...] }`

- `GET /rest/v3/artist/{id}` - Details eines Artists
  - Inkl. verknüpfte Veranstaltungen
  - Response: `{ success: true, artist: {...}, veranstaltungen: [...] }`

### Veranstaltungen
- `GET /rest/v3/veranstaltung` - Liste aller Veranstaltungen
  - Sortiert nach Datum (von) absteigend
  - Response: `{ success: true, veranstaltungen: [...] }`

- `GET /rest/v3/veranstaltung/{id}` - Details einer Veranstaltung
  - Inkl. verknüpfte Artists
  - Inkl. Veranstalter
  - Response: `{ success: true, veranstaltung: {...}, artists: [...], veranstalter: {...} }`

### Veranstalter
- `GET /rest/v3/veranstalter` - Liste aller Veranstalter
  - Sortiert nach Name
  - Response: `{ success: true, veranstalter: [...] }`

- `GET /rest/v3/veranstalter/{id}` - Details eines Veranstalters
  - Inkl. verknüpfte Veranstaltungen
  - Response: `{ success: true, veranstalter: {...}, veranstaltungen: [...] }`

## Datenbankstruktur

### Tabellen
- `artist` - Künstler/Bands
- `veranstaltung` - Events/Veranstaltungen
- `veranstalter` - Veranstalter/Organisatoren
- `r_veranstaltung_artist` - Relation zwischen Veranstaltungen und Artists
- `r_veranstaltung_veranstalter` - Relation zwischen Veranstaltungen und Veranstaltern

## TODO

### Neue Endpoints für Datenverwaltung
1. POST Endpoints zum Erstellen:
   ```
   POST /rest/v3/artist
   POST /rest/v3/veranstaltung
   POST /rest/v3/veranstalter
   ```

2. PUT Endpoints zum Aktualisieren:
   ```
   PUT /rest/v3/artist/{id}
   PUT /rest/v3/veranstaltung/{id}
   PUT /rest/v3/veranstalter/{id}
   ```

3. DELETE Endpoints zum Löschen:
   ```
   DELETE /rest/v3/artist/{id}
   DELETE /rest/v3/veranstaltung/{id}
   DELETE /rest/v3/veranstalter/{id}
   ```

### Für React Native App
1. Authentifizierung implementieren
   - JWT Token basierte Auth
   - Login Endpoint
   - Token Validierung

2. Veranstaltung erstellen/bearbeiten:
   - Frontend: Formular mit allen Feldern
   - Backend: Endpoint muss folgendes handling implementieren:
     ```js
     // Beispiel Payload für POST /rest/v3/veranstaltung
     {
       "veranstaltung": {
         "name": "Event Name",
         "von": "2025-06-01",
         "bis": "2025-06-02",
         "beschreibung": "...",
         // ... weitere Felder
       },
       "artists": [1, 2, 3],  // Array von Artist IDs
       "veranstalter": 5      // Veranstalter ID
     }
     ```

3. Validierung:
   - Pflichtfelder prüfen
   - Datumswerte validieren
   - Beziehungen validieren

4. Zusätzliche Features:
   - Paginierung für Listen
   - Suchfunktion
   - Filter (nach Datum, Kategorie etc.)
   - Image Upload
   - Caching

## Technische Details

### DSN
Die Datenbank-Verbindung erfolgt über die DSN aus der Konfiguration:
```cfml
{datasource="#getConfig('DSN')#"}
```

### Relationstabellen
- `r_veranstaltung_artist`: `artist_fk`, `veranstaltung_fk`
- `r_veranstaltung_veranstalter`: `veranstalter_fk`, `veranstaltung_fk`
