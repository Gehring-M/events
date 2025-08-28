CREATE TABLE tvb_kategorie_qualitaet (
    id INT AUTO_INCREMENT PRIMARY KEY,
    qualitaetsstufe INT NOT NULL, 
    beschreibung VARCHAR(128) NOT NULL,
    created_fk INT NOT NULL,
    createdwhen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_fk INT,
    changedwhen TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_fk INT,
    deletedwhen TIMESTAMP
);