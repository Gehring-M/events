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
