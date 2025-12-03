CREATE TABLE kb_organizer (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_fk INT UNSIGNED NOT NULL,
    location_fk INT NULL,
    name VARCHAR(255) NOT NULL,
    description TEXT NULL,
    address VARCHAR(255) NULL,
    phone_number VARCHAR(50) NULL,
    contact_person VARCHAR(255) NULL,
    website VARCHAR(255) NULL,
    images TEXT NULL,
    uploads TEXT NULL,
    approved TINYINT(1) NOT NULL DEFAULT 0,
    deactivated TINYINT(1) NOT NULL DEFAULT 0,
    changed_when DATETIME NULL, 
    approved_when DATETIME NULL,
    deactivated_when DATETIME NULL,
    CONSTRAINT fk_kb_organizer_user
        FOREIGN KEY (user_fk) REFERENCES kb_user(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_kb_organizer_location
        FOREIGN KEY (location_fk) REFERENCES ort(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);