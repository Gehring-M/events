-- Create artist category tables
-- Main categories table
CREATE TABLE IF NOT EXISTS kb_artist_category (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL UNIQUE,
    display_name VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Subcategories table
CREATE TABLE IF NOT EXISTS kb_artist_subcategory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT NOT NULL,
    name VARCHAR(255) NOT NULL,
    display_name VARCHAR(255) NOT NULL,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES kb_artist_category(id) ON DELETE CASCADE,
    UNIQUE KEY unique_category_subcategory (category_id, name)
);

-- Junction table to associate artists with subcategories (many-to-many)
CREATE TABLE IF NOT EXISTS kb_artist_has_subcategory (
    artist_id INT NOT NULL,
    subcategory_id INT NOT NULL,
    added_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (artist_id, subcategory_id),
    FOREIGN KEY (artist_id) REFERENCES kb_artist(id) ON DELETE CASCADE,
    FOREIGN KEY (subcategory_id) REFERENCES kb_artist_subcategory(id) ON DELETE CASCADE
);

-- Insert main categories
INSERT INTO kb_artist_category (name, display_name, sort_order) VALUES
('musik', 'Musik und Konzerte', 1),
('theater', 'Theater und Kleinkunst', 2),
('literatur', 'Literatur und Lesungen', 3),
('kunst', 'Kunst und Ausstellungen', 4),
('film', 'Film und Kino', 5),
('design', 'Design und Grafik', 6),
('kulturvermittlung', 'Kulturvermittlung / Pädagogik', 7),
('sonstiges', 'Sonstiges', 8);

-- Insert subcategories for Musik und Konzerte
INSERT INTO kb_artist_subcategory (category_id, name, display_name, sort_order) VALUES
((SELECT id FROM kb_artist_category WHERE name = 'musik'), 'musik_gesang', 'Musik / Gesang', 1),
((SELECT id FROM kb_artist_category WHERE name = 'musik'), 'komposition_songwriting', 'Komposition / Songwriting', 2),
((SELECT id FROM kb_artist_category WHERE name = 'musik'), 'bands_ensembles', 'Bands / Ensembles', 3),
((SELECT id FROM kb_artist_category WHERE name = 'musik'), 'dj_musikproduktion', 'DJ / Musikproduktion', 4),
((SELECT id FROM kb_artist_category WHERE name = 'musik'), 'soundgestaltung', 'Soundgestaltung', 5),
((SELECT id FROM kb_artist_category WHERE name = 'musik'), 'dirigieren', 'Dirigieren', 6);

-- Insert subcategories for Theater und Kleinkunst
INSERT INTO kb_artist_subcategory (category_id, name, display_name, sort_order) VALUES
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'schauspiel_buehne', 'Schauspiel / Bühnenperformance', 1),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'regie_buehnenleitung', 'Regie / Bühnenleitung', 2),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'spielleitung', 'Spielleitung', 3),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'dramaturgie', 'Dramaturgie', 4),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'choreografie_tanz', 'Choreografie / Tanz', 5),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'performance', 'Performance', 6),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'theatertechnik', 'Theatertechnik (Bühne, Licht, Ton)', 7),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'kleinkunst_kabarett', 'Kleinkunst / Kabarett', 8),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'theaterpädagogik', 'Theaterpädagogik', 9),
((SELECT id FROM kb_artist_category WHERE name = 'theater'), 'poetryslam', 'Poetryslam', 10);

-- Insert subcategories for Literatur und Lesungen
INSERT INTO kb_artist_subcategory (category_id, name, display_name, sort_order) VALUES
((SELECT id FROM kb_artist_category WHERE name = 'literatur'), 'literarisches_schaffen', 'Literarisches Schaffen', 1),
((SELECT id FROM kb_artist_category WHERE name = 'literatur'), 'lyrik_poesie', 'Lyrik / Poesie', 2),
((SELECT id FROM kb_artist_category WHERE name = 'literatur'), 'drehbuchschreiben', 'Drehbuchschreiben', 3),
((SELECT id FROM kb_artist_category WHERE name = 'literatur'), 'uebersetzen_lektorieren', 'Übersetzen / Lektorieren', 4),
((SELECT id FROM kb_artist_category WHERE name = 'literatur'), 'hoerbuch_einsprechen', 'Hörbuch / Einsprechen', 5);

-- Insert subcategories for Kunst und Ausstellungen
INSERT INTO kb_artist_subcategory (category_id, name, display_name, sort_order) VALUES
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'malerei', 'Malerei', 1),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'bildhauerei', 'Bildhauerei', 2),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'installations_multimedia', 'Installations- / Multimedia-Kunst', 3),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'illustration', 'Illustration', 4),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'fotografie', 'Fotografie', 5),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'videokunst', 'Videokunst', 6),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'konzept_multimedia', 'Konzept- / Multimediakunst', 7),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'kuratierung_ausstellung', 'Kuratierung / Ausstellungsgestaltung', 8),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'visuals', 'Visuals', 9),
((SELECT id FROM kb_artist_category WHERE name = 'kunst'), 'kunstpaedagogik_vermittlung', 'Kunstpädagogik / Kulturvermittlung', 10);

-- Insert subcategories for Film und Kino
INSERT INTO kb_artist_subcategory (category_id, name, display_name, sort_order) VALUES
((SELECT id FROM kb_artist_category WHERE name = 'film'), 'filmproduktion_regie', 'Filmproduktion / Regie', 1),
((SELECT id FROM kb_artist_category WHERE name = 'film'), 'kameraarbeit', 'Kameraarbeit', 2),
((SELECT id FROM kb_artist_category WHERE name = 'film'), 'schnitt_editing', 'Schnitt / Editing', 3),
((SELECT id FROM kb_artist_category WHERE name = 'film'), 'drehbuch_film', 'Drehbuchschreiben', 4),
((SELECT id FROM kb_artist_category WHERE name = 'film'), 'animation_motiondesign', 'Animation / Motion Design', 5),
((SELECT id FROM kb_artist_category WHERE name = 'film'), 'soundgestaltung_film', 'Soundgestaltung für Film', 6);

-- Insert subcategories for Design und Grafik
INSERT INTO kb_artist_subcategory (category_id, name, display_name, sort_order) VALUES
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'design', 'Design', 1),
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'grafik_medien', 'Grafik / Medien', 2),
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'web_ui_ux', 'Web- / UI/UX-Design', 3),
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'produkt_industriedesign', 'Produkt- / Industriedesign', 4),
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'mode_textildesign', 'Mode- / Textildesign', 5),
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'innenarchitektur', 'Innenarchitektur', 6),
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'gamedesign', 'Game-Design', 7),
((SELECT id FROM kb_artist_category WHERE name = 'design'), '3d_cgi', '3D / CGI', 8),
((SELECT id FROM kb_artist_category WHERE name = 'design'), 'vr_ar', 'VR / AR', 9);

-- Insert subcategories for Kulturvermittlung / Pädagogik
INSERT INTO kb_artist_subcategory (category_id, name, display_name, sort_order) VALUES
((SELECT id FROM kb_artist_category WHERE name = 'kulturvermittlung'), 'theaterpädagogik_kv', 'Theaterpädagogik', 1),
((SELECT id FROM kb_artist_category WHERE name = 'kulturvermittlung'), 'kunstpaedagogik_kv', 'Kunstpädagogik', 2),
((SELECT id FROM kb_artist_category WHERE name = 'kulturvermittlung'), 'kulturvermittlung', 'Kulturvermittlung', 3),
((SELECT id FROM kb_artist_category WHERE name = 'kulturvermittlung'), 'workshop_leitung', 'Workshop-Leitung', 4),
((SELECT id FROM kb_artist_category WHERE name = 'kulturvermittlung'), 'ausstellungsvermittlung', 'Ausstellungsvermittlung', 5);
