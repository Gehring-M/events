CREATE TABLE tvb_kategorie (
    -- column definitions
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    qualitaet_fk INT,
    created_fk INT,
    createdwhen TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    changed_fk INT,
    changedwhen TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_fk INT,
    deletedwhen TIMESTAMP,
    -- constraints
    FOREIGN KEY (qualitaet_fk) REFERENCES tvb_kategorie_qualitaet(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);