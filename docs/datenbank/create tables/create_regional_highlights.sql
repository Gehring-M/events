CREATE TABLE regional_highlights (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ort_fk INT,
    adresse VARCHAR(128),
    name VARCHAR(128) NOT NULL,
    beschreibung VARCHAR(256),
    kulturrelevant SMALLINT(1) NOT NULL,
    active SMALLINT(1) NOT NULL DEFAULT 0,
    bilder TEXT,
    created_fk INT,
    createdwhen DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_fk INT,
    changedwhen DATETIME ON UPDATE CURRENT_TIMESTAMP,
    deleted_fk INT,
    deletedwhen DATETIME,
    -- constraints 
    FOREIGN KEY (ort_fk) REFERENCES ort(id)
        ON DELETE SET NULL 
        ON UPDATE CASCADE
);
