ALTER TABLE veranstaltung
ADD COLUMN changed_by_kbsz INT NOT NULL DEFAULT 0,
ADD COLUMN geodatenpool_id INT;