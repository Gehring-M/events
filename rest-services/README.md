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

#### Filter-Endpoints

##### Datum und Zeitraum Filter

- `GET /rest/v3/veranstaltung/filter/date`

  ```bash
  # Events zwischen zwei Daten
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/date?fromDate=2025-06-01&toDate=2025-06-30"
  ```

  - Parameter:
    - `fromDate` - Startdatum im Format YYYY-MM-DD (Pflichtfeld)
    - `toDate` - Enddatum im Format YYYY-MM-DD (Pflichtfeld)

- `GET /rest/v3/veranstaltung/filter/year/{year}`

  ```bash
  # Events eines bestimmten Jahres
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/year/2025"
  
  # Events des Jahres 2023
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/year/2023"
  ```

  - Parameter:
    - `year` - Jahreszahl (z.B. 2023, 2025, 2026)

- `GET /rest/v3/veranstaltung/filter/next/{days}`

  ```bash
  # Events der nächsten 7 Tage
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/next/7"
  
  # Events der nächsten 30 Tage
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/next/30"
  
  # Events der nächsten 45 Tage
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/next/45"
  
  # Beliebige Anzahl von Tagen (max. 365)
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/next/120"
  ```

  - Parameter:
    - `days` - Beliebige positive Anzahl von Tagen (maximal 365)

- `GET /rest/v3/veranstaltung/filter/next/{days}/{regionId}`

  ```bash
  # Events der nächsten 30 Tage in Region 2
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/next/30/2"
  
  # Events der nächsten 7 Tage in Region 5
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/next/7/5"
  ```

  - Parameter:
    - `days` - Beliebige positive Anzahl von Tagen (maximal 365)
    - `regionId` - ID der Region (aus der Tabelle `region`)

##### Veranstaltungstyp Filter

- `GET /rest/v3/veranstaltung/filter/typ/{typId}`

  ```bash
  # Events einer bestimmten Kategorie
  curl -X GET "http://localhost/rest/v3/veranstaltung/filter/typ/2"
  ```

  - Parameter:
    - `typId` - ID des Veranstaltungstyps (aus der Tabelle typ)

Response Format

```json
{
  "success": true,
  "veranstaltungen": [
    {
      "id": 123,
      "name": "Beispiel Event",
      "von": "2025-06-01",
      "bis": "2025-06-02",
      "beschreibung": "...",
      "ort": "Innsbruck",
      "plz": "6020",
      "visible": 1
    }
  ]
}
```

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
