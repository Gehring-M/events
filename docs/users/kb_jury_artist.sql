CREATE TABLE kb_jury_artist (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    jury_fk INT UNSIGNED NOT NULL,
    artist_fk INT UNSIGNED NOT NULL,
    approved TINYINT(1) DEFAULT 0,
    rejected TINYINT(1) DEFAULT 0,
    need_action TINYINT(1) DEFAULT 0,
    INDEX idx_jury_fk (jury_fk),
    INDEX idx_artist_fk (artist_fk),
    FOREIGN KEY (jury_fk) REFERENCES kb_jury(id),
    FOREIGN KEY (artist_fk) REFERENCES kb_artist(id)
);