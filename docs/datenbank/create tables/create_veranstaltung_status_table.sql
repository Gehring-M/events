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