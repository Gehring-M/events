CREATE TABLE kb_jury (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_fk INT UNSIGNED NOT NULL,
    first_name VARCHAR(255),
    last_name VARCHAR(255),
    CONSTRAINT fk_kb_jury_user
        FOREIGN KEY (user_fk) REFERENCES kb_user(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);