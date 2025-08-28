# Erweiterungen in der Datenbank

<br>
<br>

## Erstellen einer neuen Tabelle - tvb 

Diese Tabelle enthält Informationen zu den verschiedenen Tourismusverbänden, die mit der Geodatenbank in Verbindung stehen.

| id | name      | beschreibung | geodatenpool_id | sync | region_fk | created_fk | createdwhen | changed_fk | changed_when | deleted_fk | deletedwhen |
|----|-----------|--------------|-----------------|------|-----------|------------|-------------|------------|--------------|------------|-------------|
| 0  | Zillertal | ...          | ...             | ...  | ...       | ...        | ...         | ...        | ...          | ...        | ...         |


Dafür wird das folgende SQL statement verwendet. Auch als ```create_tvb_table.sql```.
```sql
CREATE TABLE tvb (
    -- column definitions
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    beschreibung VARCHAR(256),
    geodatenpool_key VARCHAR(32),
    sync BOOLEAN DEFAULT FALSE,
    region_fk INT,
    created_fk INT,
    createdwhen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_fk INT,
    changedwhen TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_fk INT,
    deletedwhen TIMESTAMP,
    -- constraints 
    FOREIGN KEY (region_fk) REFERENCES region(id)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);
```

<br>

Die Tabelle wird mit dem folgenden Skript befüllt. Auch als ```fill_tvb_table.sql```

```sql
-- created_fk = 2 (admin)
INSERT INTO tvb (name, beschreibung, geodatenpool_key, sync, region_fk, created_fk) 
VALUES 
    ('Achensee', 'Gebiet Achensee', 'agdo_lI9dBpWqUuNuaRmu', TRUE, 17, 2),
    ('Zillertal', 'Gebiet Zillertal', 'agdo_hV6fnNk0yE68XnJz', TRUE, 20, 2);
```

<br>
<br>
<br>

## Erstellen einer neuen Tabelle - tvb_kategorie_qualität

Diese Tabelle enthält alle Qualitätsstufen für den Import der Geodaten anhand der Kategorie. Bedeutet, jede Kategorie erhält einen Wert, welcher bestimmt, wie die Daten importiert werden sollen.

| id | qualitätsstufe | beschreibung                | created_fk | createdwhen | changed_fk | changedwhen | deleted_fk | deletedwhen |
|----|----------------|-----------------------------|------------|-------------|------------|-------------|------------|-------------|
| 1  | 0              | sofort importieren          | ...        | ...         | ...        | ...         | ...        | ...         |
| 2  | 1              | mit Überprüfung importieren | ...        | ...         | ...        | ...         | ...        | ...         |
| 3  | 2              | nicht importieren           | ...        | ...         | ...        | ...         | ...        | ...         |

<br>

Die Tabelle wird mit dem folgenden Skript erzeugt. Auch als ```create_tvb_category_quality_table.sql```

```sql 
CREATE TABLE tvb_kategorie_qualität (
    id INT AUTO_INCREMENT PRIMARY KEY,
    qualitätsstufe INT NOT NULL, 
    beschreibung VARCHAR(128) NOT NULL,
    created_fk INT NOT NULL,
    createdwhen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_fk INT,
    changedwhen TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_fk INT,
    deletedwhen TIMESTAMP
);
```

<br>

Die Tabelle wird mit dem folgenden Skript befüllt. Auch als ```fill_tvb_category_quality.sql```

```sql 
-- created_fk = 2 (admin)
INSERT INTO tvb_kategorie_qualität (qualitätsstufe, beschreibung, created_fk)
VALUES
    (0, 'sofort importieren', 2),
    (1, 'mit Überprüfung importieren', 2),
    (2, 'nicht importieren', 2);
```

<br>
<br>
<br>

## Erstellen einer neuen Tabelle - tvb_kategorie

Diese Tabelle enthält Informationen zu den verschiedenen Kategorien, die von den Tourismusverbänden angeboten werden.

| id | name | qualität_fk    | created_fk | createdwhen | changed_fk | changedwhen | deleted_fk | deletedwhen |
|----|------|----------------|------------|-------------|------------|-------------|------------|-------------|

<br>

Die Tabelle wird mit dem folgenden Skript erzeugt. Auch als ```create_tvb_category_table.sql```

```sql
CREATE TABLE tvb_kategorie (

    -- column definitions
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(32) NOT NULL,
    qualität_fk INT,
    created_fk INT NOT NULL,
    createdwhen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_fk INT,
    changedwhen TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_fk INT,
    deletedwhen TIMESTAMP,

    -- constraints
    FOREIGN KEY (qualität_fk) REFERENCES tvb_kategorie_qualität(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);
```

<br>

Die Tabelle wird mit dem folgenden Skript befüllt. Auch als ```fill_tvb_category_table.sql```

```sql
-- created_fk = 2 (admin)
INSERT INTO tvb_kategorie (name, qualität_fk, created_fk)
VALUES
    -- qualitätsstufe '0' ... sofort importieren
    ('odta:AdventMarket', 1, 2),
    ('odta:Ball', 1, 2),
    ('odta:Ballet', 1, 2),
    ('odta:HarvestFestival', 1, 2),
    ('odta:CarnivalParade', 1, 2),
    ('odta:CarnivalSession', 1, 2),
    ('odta:FestivalEnumeration', 1, 2),
    ('odta:OpenAirTheater', 1, 2),
    ('odta:HistoricalMarket', 1, 2),
    ('odta:HistoricalParade', 1, 2),
    ('odta:ChildrenTheater', 1, 2),
    ('odta:Comedy', 1, 2),
    ('odta:ArtsAndCraftsFair', 1, 2),
    ('odta:FestivalOfLights', 1, 2),
    ('odta:MedievalMarket', 1, 2),
    ('odta:Musical', 1, 2),
    ('odta:MusicalTheater', 1, 2),
    ('odta:Opera', 1, 2),
    ('odta:Operetta', 1, 2),
    ('odta:CityFestival', 1, 2),
    ('odta:StreetFoodFestival', 1, 2),
    ('odta:DanceEventEnumeration', 1, 2),
    ('odta:DanceTheater', 1, 2),
    ('odta:TheaterFestival', 1, 2),
    ('odta:VarietyShow', 1, 2),
    ('odta:ExhibitionOpening', 1, 2),
    ('odta:WineFestival', 1, 2),
    -- qualitätsstufe '1' ... mit Überprüfung importieren
    ('odta:Excursion', 2, 2),
    ('odta:Brunch', 2, 2),
    ('odta:PermanentExhibition', 2, 2),
    ('odta:FoodEventEnumeration', 2, 2),
    ('odta:FoodMarket', 2, 2),
    ('odta:Seminar', 2, 2),
    ('odta:TheaterEventEnumeration', 2, 2),
    ('odta:Tasting', 2, 2);
```

<br>
<br>
<br>

## Erstellen einer neuen Tabelle - veranstaltung_status

Diese Tabelle enthält Informationen zu den verschiedenen Stati, die eine Veranstaltung haben kann.

| id | status | beschreibung | created_fk | createdwhen | changed_fk | changedwhen | deleted_fk | deletedwhen |
|----|--------|--------------|------------|-------------|------------|-------------|------------|-------------|

<br>

Die Tabelle wird mit dem folgenden Skript erzeugt. Auch als ```create_veranstaltung_status_table.sql```

```sql
CREATE TABLE veranstaltung_status (
    -- column definitions
    id INT AUTO_INCREMENT PRIMARY KEY, 
    status INT NOT NULL DEFAULT 0,
    beschreibung VARCHAR(128) NOT NULL,
    created_fk INT,
    createdwhen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_fk INT,
    changedwhen TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_fk INT,
    deletedwhen TIMESTAMP
);
```

<br>

Die Tabelle wird mit dem folgenden Skript befüllt. Auch als ```fill_veranstaltung_status_table.sql```

```sql
INSERT INTO (status, beschreibung, created_fk) 
VALUES 
    (0, )
```

## Verändern der Tabelle - veranstaltung

Add two new columns ...

| existing_columns | qualität_fk | hash |
|------------------|-------------|------|
| ...              | 
