-- =====================================================
-- DATENBANK: Buchtausch-App
-- DATEI: full_database.sql
-- AUTOR: Firas Alshamam
-- MATRIKELNUMMER: UPS10769810
-- KURS: DLBDSPBDM01_D
-- BESCHREIBUNG: VOLLSTÄNDIGE DATENBANK
-- =====================================================
-- ENTHÄLT:
--   1. Datenbank erstellen
--   2. Alle 14 Tabellen
--   3. Constraints (PK, FK, CHECK)
--   4. Dummy-Daten (mind. 10 pro Tabelle)
--   5. Alle Indizes
--   6. Testabfragen
-- =====================================================

-- =====================================================
-- 1. DATENBANK ERSTELLEN
-- =====================================================
DROP DATABASE IF EXISTS buchtausch;
CREATE DATABASE buchtausch CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE buchtausch;

-- =====================================================
-- 2. TABELLEN (14 Entitäten)
-- =====================================================

-- Tabelle 1: nutzer
CREATE TABLE nutzer (
    nutzer_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE,
    passwort_hash VARCHAR(255) NOT NULL,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    strasse VARCHAR(100) NOT NULL,
    plz VARCHAR(10) NOT NULL,
    stadt VARCHAR(50) NOT NULL,
    telefon VARCHAR(20),
    registrierungsdatum DATE NOT NULL DEFAULT CURRENT_DATE,
    profilbild_url VARCHAR(500),
    ist_aktiv BOOLEAN DEFAULT TRUE
);

-- Tabelle 2: verlag
CREATE TABLE verlag (
    verlag_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    ort VARCHAR(100) NOT NULL,
    website VARCHAR(200),
    email VARCHAR(100),
    telefon VARCHAR(20),
    gruendungsjahr INT
);

-- Tabelle 3: autor
CREATE TABLE autor (
    autor_id INT PRIMARY KEY AUTO_INCREMENT,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    geburtsdatum DATE,
    nationalitaet VARCHAR(50),
    biografie TEXT,
    website VARCHAR(200)
);

-- Tabelle 4: genre
CREATE TABLE genre (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    beschreibung VARCHAR(200),
    uebergeordnetes_genre_id INT,
    FOREIGN KEY (uebergeordnetes_genre_id) REFERENCES genre(genre_id)
);

-- Tabelle 5: buch
CREATE TABLE buch (
    buch_id INT PRIMARY KEY AUTO_INCREMENT,
    isbn VARCHAR(13) UNIQUE,
    titel VARCHAR(200) NOT NULL,
    untertitel VARCHAR(200),
    verlag_id INT NOT NULL,
    erscheinungsjahr INT,
    sprache VARCHAR(30) NOT NULL DEFAULT 'Deutsch',
    seitenzahl INT,
    beschreibung TEXT,
    cover_url VARCHAR(500),
    FOREIGN KEY (verlag_id) REFERENCES verlag(verlag_id)
);

-- Tabelle 6: buch_autor (M:N)
CREATE TABLE buch_autor (
    buch_id INT NOT NULL,
    autor_id INT NOT NULL,
    hauptautor BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (buch_id, autor_id),
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id) ON DELETE CASCADE,
    FOREIGN KEY (autor_id) REFERENCES autor(autor_id) ON DELETE CASCADE
);

-- Tabelle 7: buch_genre (M:N)
CREATE TABLE buch_genre (
    buch_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (buch_id, genre_id),
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id) ON DELETE CASCADE
);

-- Tabelle 8: standort
CREATE TABLE standort (
    standort_id INT PRIMARY KEY AUTO_INCREMENT,
    nutzer_id INT NOT NULL,
    bezeichnung VARCHAR(50) NOT NULL,
    strasse VARCHAR(100) NOT NULL,
    plz VARCHAR(10) NOT NULL,
    stadt VARCHAR(50) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    abholzeiten VARCHAR(200),
    versand_option BOOLEAN DEFAULT FALSE,
    ist_standard BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (nutzer_id) REFERENCES nutzer(nutzer_id) ON DELETE CASCADE
);

-- Tabelle 9: buch_exemplar
CREATE TABLE buch_exemplar (
    exemplar_id INT PRIMARY KEY AUTO_INCREMENT,
    buch_id INT NOT NULL,
    besitzer_id INT NOT NULL,
    standort_id INT NOT NULL,
    zustand VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'verfügbar',
    max_leihdauer_tage INT NOT NULL DEFAULT 30,
    notizen TEXT,
    erstellungsdatum DATE NOT NULL DEFAULT CURRENT_DATE,
    anzahl_ausleihen INT DEFAULT 0,
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id) ON DELETE CASCADE,
    FOREIGN KEY (besitzer_id) REFERENCES nutzer(nutzer_id) ON DELETE CASCADE,
    FOREIGN KEY (standort_id) REFERENCES standort(standort_id)
);

-- Tabelle 10: ausleihe
CREATE TABLE ausleihe (
    ausleihe_id INT PRIMARY KEY AUTO_INCREMENT,
    exemplar_id INT NOT NULL,
    verleiher_id INT NOT NULL,
    entleiher_id INT NOT NULL,
    standort_id INT NOT NULL,
    startdatum DATE NOT NULL,
    enddatum DATE NOT NULL,
    rueckgabedatum DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'angefragt',
    notizen TEXT,
    erstellungsdatum DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (exemplar_id) REFERENCES buch_exemplar(exemplar_id),
    FOREIGN KEY (verleiher_id) REFERENCES nutzer(nutzer_id),
    FOREIGN KEY (entleiher_id) REFERENCES nutzer(nutzer_id),
    FOREIGN KEY (standort_id) REFERENCES standort(standort_id)
);

-- Tabelle 11: ausleihe_anfrage (TERNÄR)
CREATE TABLE ausleihe_anfrage (
    anfrage_id INT PRIMARY KEY AUTO_INCREMENT,
    nutzer_id INT NOT NULL,
    exemplar_id INT NOT NULL,
    gewuenschter_start DATE NOT NULL,
    gewuenschtes_ende DATE NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'offen',
    nachricht TEXT,
    anfragedatum DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (nutzer_id) REFERENCES nutzer(nutzer_id),
    FOREIGN KEY (exemplar_id) REFERENCES buch_exemplar(exemplar_id)
);

-- Tabelle 12: bewertung
CREATE TABLE bewertung (
    bewertung_id INT PRIMARY KEY AUTO_INCREMENT,
    bewertende_id INT NOT NULL,
    bewertete_id INT,
    exemplar_id INT,
    ausleihe_id INT,
    sterne INT NOT NULL,
    kommentar TEXT,
    datum DATE NOT NULL DEFAULT CURRENT_DATE,
    FOREIGN KEY (bewertende_id) REFERENCES nutzer(nutzer_id),
    FOREIGN KEY (bewertete_id) REFERENCES nutzer(nutzer_id),
    FOREIGN KEY (exemplar_id) REFERENCES buch_exemplar(exemplar_id),
    FOREIGN KEY (ausleihe_id) REFERENCES ausleihe(ausleihe_id)
);

-- Tabelle 13: nachricht
CREATE TABLE nachricht (
    nachricht_id INT PRIMARY KEY AUTO_INCREMENT,
    sender_id INT NOT NULL,
    empfaenger_id INT NOT NULL,
    betreff VARCHAR(100) NOT NULL,
    inhalt TEXT NOT NULL,
    zeitstempel DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    gelesen BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_id) REFERENCES nutzer(nutzer_id),
    FOREIGN KEY (empfaenger_id) REFERENCES nutzer(nutzer_id)
);

-- Tabelle 14: buch_suche (TERNÄR)
CREATE TABLE buch_suche (
    suche_id INT PRIMARY KEY AUTO_INCREMENT,
    nutzer_id INT NOT NULL,
    standort_id INT,
    genre_id INT,
    suchradius_km INT,
    suchbegriff VARCHAR(200),
    suchzeitpunkt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    ergebnis_anzahl INT,
    FOREIGN KEY (nutzer_id) REFERENCES nutzer(nutzer_id),
    FOREIGN KEY (standort_id) REFERENCES standort(standort_id),
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id)
);

SELECT '✅ 1. Alle 14 Tabellen wurden erstellt!' AS Meldung;

-- =====================================================
-- 3. DUMMY-DATEN (mind. 10 pro Tabelle)
-- =====================================================

-- Nutzer (12)
INSERT INTO nutzer (email, passwort_hash, vorname, nachname, strasse, plz, stadt, telefon) VALUES
('anna.schmidt@email.de', 'hash123', 'Anna', 'Schmidt', 'Hauptstraße 12', '10115', 'Berlin', '01761234567'),
('ben.wagner@email.de', 'hash456', 'Ben', 'Wagner', 'Bergstraße 45', '80331', 'München', '01769876543'),
('clara.weber@email.de', 'hash789', 'Clara', 'Weber', 'Seeufer 7', '78462', 'Konstanz', '015112345678'),
('david.hoffmann@email.de', 'hashabc', 'David', 'Hoffmann', 'Marktplatz 3', '50667', 'Köln', '016012345678'),
('emma.fischer@email.de', 'hashdef', 'Emma', 'Fischer', 'Lindenweg 9', '20095', 'Hamburg', '017012345679'),
('felix.meyer@email.de', 'hashghi', 'Felix', 'Meyer', 'Schulstraße 22', '60311', 'Frankfurt', '015112345679'),
('greta.schulz@email.de', 'hashjkl', 'Greta', 'Schulz', 'Gartenweg 5', '30159', 'Hannover', '016312345678'),
('henrik.becker@email.de', 'hashmno', 'Henrik', 'Becker', 'Rathausplatz 1', '90402', 'Nürnberg', '017412345678'),
('ida.koch@email.de', 'hashpqr', 'Ida', 'Koch', 'Bahnhofstraße 15', '01067', 'Dresden', '015512345678'),
('jonas.richter@email.de', 'hashstu', 'Jonas', 'Richter', 'Am See 3', '24103', 'Kiel', '016112345678'),
('laura.baum@email.de', 'hashvwx', 'Laura', 'Baum', 'Waldstraße 8', '70173', 'Stuttgart', '01761239876'),
('marcus.wolf@email.de', 'hashyz1', 'Marcus', 'Wolf', 'Mozartweg 12', '40213', 'Düsseldorf', '01519876543');

-- Verlag (10)
INSERT INTO verlag (name, ort, website, email, gruendungsjahr) VALUES
('Suhrkamp Verlag', 'Berlin', 'www.suhrkamp.de', 'info@suhrkamp.de', 1950),
('Fischer Verlag', 'Frankfurt', 'www.fischerverlage.de', 'info@fischer.de', 1886),
('Rowohlt Verlag', 'Hamburg', 'www.rowohlt.de', 'kontakt@rowohlt.de', 1908),
('Kiepenheuer & Witsch', 'Köln', 'www.kiwi-verlag.de', 'info@kiwi.de', 1949),
('dtv Verlag', 'München', 'www.dtv.de', 'kundenservice@dtv.de', 1960),
('Piper Verlag', 'München', 'www.piper.de', 'info@piper.de', 1904),
('Carl Hanser Verlag', 'München', 'www.hanser-literatur.de', 'info@hanser.de', 1928),
('Aufbau Verlag', 'Berlin', 'www.aufbau-verlag.de', 'verlag@aufbau.de', 1945),
('Reclam Verlag', 'Stuttgart', 'www.reclam.de', 'info@reclam.de', 1828),
('Insel Verlag', 'Berlin', 'www.insel-verlag.de', 'info@insel.de', 1901);

-- Autor (12)
INSERT INTO autor (vorname, nachname, geburtsdatum, nationalitaet, biografie) VALUES
('Daniel', 'Kehlmann', '1975-01-01', 'Deutsch', 'Österreichisch-deutscher Schriftsteller'),
('Ferdinand', 'von Schirach', '1964-01-01', 'Deutsch', 'Deutscher Strafverteidiger'),
('Elena', 'Ferrante', '1943-01-01', 'Italienisch', 'Pseudonym einer italienischen Schriftstellerin'),
('Haruki', 'Murakami', '1949-01-01', 'Japanisch', 'Japanischer Schriftsteller'),
('Margaret', 'Atwood', '1939-01-01', 'Kanadisch', 'Kanadische Schriftstellerin'),
('Bernhard', 'Schlink', '1944-01-01', 'Deutsch', 'Deutscher Jurist und Schriftsteller'),
('Nele', 'Neuhaus', '1967-01-01', 'Deutsch', 'Deutsche Krimiautorin'),
('Sebastian', 'Fitzek', '1971-01-01', 'Deutsch', 'Deutscher Thriller-Autor'),
('Cornelia', 'Funke', '1958-01-01', 'Deutsch', 'Deutsche Kinderbuchautorin'),
('Walter', 'Moers', '1957-01-01', 'Deutsch', 'Deutscher Schriftsteller'),
('Frank', 'Schätzing', '1957-01-01', 'Deutsch', 'Deutscher Schriftsteller'),
('Charlotte', 'Link', '1963-01-01', 'Deutsch', 'Deutsche Schriftstellerin');

-- Genre (12)
INSERT INTO genre (name, beschreibung, uebergeordnetes_genre_id) VALUES
('Roman', 'Belletristische Erzählung', NULL),
('Krimi', 'Kriminalromane und Thriller', NULL),
('Science Fiction', 'Zukunftsliteratur', NULL),
('Fantasy', 'Fantastische Literatur', NULL),
('Biografie', 'Lebensbeschreibungen', NULL),
('Historischer Roman', 'Historische Erzählungen', 1),
('Liebesroman', 'Romantische Literatur', 1),
('Psychothriller', 'Spannungsromane mit psychologischem Tiefgang', 2),
('Dystopie', 'Zukunftsromane mit negativer Gesellschaftsprognose', 3),
('High Fantasy', 'Epische Fantasy-Welten', 4),
('Kurzgeschichte', 'Kurze literarische Form', 1),
('Sachbuch', 'Fach- und Sachliteratur', NULL);

-- Buch (12)
INSERT INTO buch (isbn, titel, verlag_id, erscheinungsjahr, sprache, seitenzahl, beschreibung) VALUES
('9783518465679', 'Die Vermessung der Welt', 1, 2005, 'Deutsch', 300, 'Bestseller über Gauß und Humboldt'),
('9783462046256', 'Der Vorleser', 2, 1995, 'Deutsch', 208, 'Roman über Liebe und Schuld'),
('9783499254999', 'Tschick', 3, 2010, 'Deutsch', 256, 'Jugendroman über eine Sommerreise'),
('9783462308750', 'Der Insasse', 4, 2018, 'Deutsch', 400, 'Psychothriller von Fitzek'),
('9783423280154', 'Das Parfum', 5, 1985, 'Deutsch', 320, 'Die Geschichte eines Mörders'),
('9783596701531', 'QualityLand', 6, 2017, 'Deutsch', 368, 'Satire über eine digitale Zukunft'),
('9783442488492', 'Die Tote im Starnberger See', 7, 2019, 'Deutsch', 350, 'Krimi aus Bayern'),
('9783518419221', 'Ruhm', 1, 2009, 'Deutsch', 208, 'Neun Geschichten über Ruhm'),
('9783462048533', 'Die Liebe in den Zeiten der Cholera', 4, 1985, 'Deutsch', 416, 'Klassiker'),
('9783596703009', 'Der Heimweg', 6, 2020, 'Deutsch', 450, 'Psychothriller von Fitzek'),
('9783462050886', 'Der Schwarm', 2, 2004, 'Deutsch', 1024, 'Ökothriller'),
('9783442488508', 'Die Verborgenen', 7, 2021, 'Deutsch', 380, 'Psychologischer Spannungsroman');

-- buch_autor
INSERT INTO buch_autor (buch_id, autor_id, hauptautor) VALUES
(1,1,1),(2,6,1),(3,3,1),(4,8,1),(5,7,1),(6,2,1),(7,7,1),(8,1,1),(9,4,1),(10,8,1),(11,11,1),(12,12,1);

-- buch_genre
INSERT INTO buch_genre (buch_id, genre_id) VALUES
(1,1),(1,6),(2,1),(2,6),(3,1),(4,2),(4,8),(5,1),(5,6),(6,3),(6,9),(7,2),(8,1),(8,11),(9,1),(9,7),(10,2),(10,8),(11,2),(11,3),(12,2),(12,8);

-- standort (12)
INSERT INTO standort (nutzer_id, bezeichnung, strasse, plz, stadt, latitude, longitude, abholzeiten, versand_option, ist_standard) VALUES
(1,'Zuhause','Hauptstraße 12','10115','Berlin',52.520008,13.404954,'Mo-Fr 18-20 Uhr',1,1),
(2,'Wohnung','Bergstraße 45','80331','München',48.135124,11.581981,'Nach Vereinbarung',0,1),
(3,'Haus','Seeufer 7','78462','Konstanz',47.677950,9.173240,'Sa 10-14 Uhr',0,1),
(4,'Büro','Marktplatz 3','50667','Köln',50.937531,6.960279,'Mo-Fr 9-17 Uhr',1,0),
(5,'Zuhause','Lindenweg 9','20095','Hamburg',53.551086,9.993682,'Di+Do 16-19 Uhr',1,1),
(6,'Wohnung','Schulstraße 22','60311','Frankfurt',50.110924,8.682127,'Nach Vereinbarung',0,1),
(7,'Haus','Gartenweg 5','30159','Hannover',52.375891,9.732010,'Mo-Fr 17-20 Uhr',0,1),
(8,'Büro','Rathausplatz 1','90402','Nürnberg',49.452030,11.076750,'Mo-Fr 8-16 Uhr',1,0),
(9,'Zuhause','Bahnhofstraße 15','01067','Dresden',51.050409,13.737262,'Sa+So 10-18 Uhr',1,1),
(10,'Wohnung','Am See 3','24103','Kiel',54.323293,10.122765,'Nach Vereinbarung',0,1),
(11,'Zuhause','Waldstraße 8','70173','Stuttgart',48.775846,9.182932,'Mo-Fr 17-21 Uhr',1,1),
(12,'Büro','Mozartweg 12','40213','Düsseldorf',51.227741,6.773456,'Mo-Fr 8-15 Uhr',0,0);

-- buch_exemplar (12)
INSERT INTO buch_exemplar (buch_id, besitzer_id, standort_id, zustand, status, max_leihdauer_tage, notizen, erstellungsdatum) VALUES
(1,1,1,'sehr gut','verfügbar',28,'Fast wie neu','2024-01-15'),
(2,2,2,'gut','verfügbar',21,'Mit Notizen','2024-01-20'),
(3,3,3,'neu','verfügbar',30,'Eingeschweißt','2024-02-01'),
(1,4,4,'akzeptabel','verfügbar',14,'Abgenutzt','2024-02-10'),
(4,5,5,'sehr gut','ausgeliehen',21,'Thriller','2024-01-25'),
(5,6,6,'gut','verfügbar',28,'Klassiker','2024-02-15'),
(6,7,7,'neu','reserviert',30,'Bestseller','2024-03-01'),
(7,8,8,'sehr gut','verfügbar',21,'Krimi','2024-02-20'),
(8,9,9,'gut','verfügbar',14,'Kurzgeschichten','2024-01-10'),
(9,10,10,'akzeptabel','verfügbar',28,'Ältere Ausgabe','2024-01-05'),
(10,11,11,'sehr gut','verfügbar',21,'Neuer Fitzek','2024-03-15'),
(11,12,12,'gut','ausgeliehen',28,'Dicker Wälzer','2024-02-28');

-- ausleihe (12)
INSERT INTO ausleihe (exemplar_id, verleiher_id, entleiher_id, standort_id, startdatum, enddatum, rueckgabedatum, status, erstellungsdatum) VALUES
(1,1,2,1,'2024-02-01','2024-02-28','2024-02-25','abgeschlossen','2024-01-25'),
(2,2,3,2,'2024-02-15','2024-03-07',NULL,'aktiv','2024-02-10'),
(3,3,4,3,'2024-03-01','2024-03-31',NULL,'bestätigt','2024-02-20'),
(4,4,5,4,'2024-02-10','2024-02-24','2024-02-22','abgeschlossen','2024-02-05'),
(5,5,6,5,'2024-03-01','2024-03-22',NULL,'aktiv','2024-02-25'),
(6,6,7,6,'2024-01-10','2024-02-07','2024-02-05','abgeschlossen','2024-01-05'),
(7,7,8,7,'2024-03-05','2024-04-02',NULL,'bestätigt','2024-02-28'),
(8,8,9,8,'2024-02-20','2024-03-05','2024-03-01','abgeschlossen','2024-02-15'),
(9,9,10,9,'2024-02-01','2024-02-15','2024-02-14','abgeschlossen','2024-01-28'),
(10,10,1,10,'2024-03-10','2024-04-07',NULL,'aktiv','2024-03-01'),
(11,11,2,11,'2024-03-15','2024-04-05',NULL,'angefragt','2024-03-10'),
(12,12,3,12,'2024-03-01','2024-03-29','2024-03-25','abgeschlossen','2024-02-20');

-- ausleihe_anfrage (12)
INSERT INTO ausleihe_anfrage (nutzer_id, exemplar_id, gewuenschter_start, gewuenschtes_ende, status, nachricht, anfragedatum) VALUES
(2,3,'2024-04-01','2024-04-28','offen','Würde gerne im April lesen','2024-03-15'),
(4,1,'2024-03-15','2024-03-30','akzeptiert','Für zwei Wochen?','2024-03-10'),
(6,5,'2024-04-01','2024-04-22','offen','Fitzek verfügbar?','2024-03-18'),
(8,7,'2024-04-05','2024-05-03','offen','Im April lesen','2024-03-20'),
(10,9,'2024-03-20','2024-04-03','abgelehnt','Kurzfristig?','2024-03-17'),
(1,2,'2024-04-01','2024-04-15','offen','Buch noch da?','2024-03-19'),
(3,4,'2024-03-25','2024-04-08','zurückgezogen','Doch nicht nötig','2024-03-12'),
(5,6,'2024-04-10','2024-05-08','offen','Für meine Mutter','2024-03-21'),
(7,8,'2024-03-22','2024-04-05','akzeptiert','Super,danke!','2024-03-14'),
(9,10,'2024-04-15','2024-05-13','offen','Verlängern?','2024-03-22'),
(11,11,'2024-04-01','2024-04-22','offen','Neuen Fitzek lesen','2024-03-25'),
(12,12,'2024-04-05','2024-04-19','akzeptiert','Danke','2024-03-23');

-- bewertung (12)
INSERT INTO bewertung (bewertende_id, bewertete_id, exemplar_id, ausleihe_id, sterne, kommentar, datum) VALUES
(2,1,NULL,1,5,'Netter Verleiher','2024-02-26'),
(1,2,NULL,1,4,'Pünktliche Rückgabe','2024-02-26'),
(3,2,NULL,2,5,'Unkompliziert','2024-03-08'),
(4,3,NULL,3,5,'Zuverlässig','2024-03-02'),
(5,4,NULL,4,4,'Gerne wieder','2024-02-23'),
(NULL,NULL,1,1,5,'Tolles Buch','2024-02-26'),
(NULL,NULL,2,2,4,'Spannend','2024-03-07'),
(NULL,NULL,4,4,3,'Akzeptabel','2024-02-23'),
(NULL,NULL,6,6,5,'Klassiker','2024-02-06'),
(NULL,NULL,8,8,4,'Schneller Lesestoff','2024-03-02'),
(NULL,NULL,11,11,5,'Spannend','2024-03-26'),
(3,12,NULL,12,5,'Schnelle Rückgabe','2024-03-26');

-- nachricht (12)
INSERT INTO nachricht (sender_id, empfaenger_id, betreff, inhalt, zeitstempel, gelesen) VALUES
(2,1,'Frage','Buch verfügbar?','2024-03-01 10:30:00',1),
(1,2,'Antwort','Ja, gerne','2024-03-01 11:15:00',1),
(3,2,'Anfrage','Würde ausleihen','2024-03-02 14:20:00',1),
(2,3,'Bestätigung','Klar','2024-03-02 15:00:00',1),
(4,3,'Danke','Buch da','2024-03-05 18:30:00',0),
(5,4,'Rückgabe','Zurückgebracht','2024-02-22 16:45:00',1),
(6,5,'Verlängerung','Länger behalten?','2024-03-15 09:10:00',0),
(7,6,'Erinnerung','Bitte zurück','2024-02-28 20:00:00',1),
(8,7,'Neues Buch','Neuer Fitzek','2024-03-10 12:00:00',0),
(9,8,'Treffen','Samstag?','2024-02-25 08:30:00',1),
(10,9,'Zustand','Buch gut?','2024-03-20 14:15:00',1),
(11,10,'Abholung','Morgen abholen','2024-03-22 19:30:00',0);

-- buch_suche (12)
INSERT INTO buch_suche (nutzer_id, standort_id, genre_id, suchradius_km, suchbegriff, suchzeitpunkt, ergebnis_anzahl) VALUES
(1,1,2,5,'Krimi','2024-03-01 10:00:00',3),
(2,2,NULL,10,'Fitzek','2024-03-02 15:30:00',2),
(3,3,1,3,'Roman','2024-03-03 09:15:00',5),
(4,4,3,20,'Science Fiction','2024-03-04 18:45:00',1),
(5,5,NULL,2,'Kehlmann','2024-03-05 12:00:00',2),
(6,6,4,8,'Fantasy','2024-03-06 14:20:00',0),
(7,7,2,15,'Thriller','2024-03-07 11:10:00',4),
(8,8,NULL,25,'Historischer Roman','2024-03-08 16:30:00',1),
(9,9,1,5,'Liebesroman','2024-03-09 13:45:00',2),
(10,10,NULL,30,'Bestseller','2024-03-10 10:00:00',6),
(11,11,8,10,'Psychothriller','2024-03-21 17:20:00',3),
(12,12,NULL,5,'Schätzing','2024-03-24 11:30:00',1);

SELECT '✅ 2. Dummy-Daten wurden eingefügt!' AS Meldung;

-- =====================================================
-- 4. INDIZES
-- =====================================================
CREATE INDEX idx_nutzer_email ON nutzer(email);
CREATE INDEX idx_nutzer_name ON nutzer(nachname, vorname);
CREATE INDEX idx_nutzer_stadt ON nutzer(stadt);
CREATE INDEX idx_buch_titel ON buch(titel);
CREATE INDEX idx_buch_isbn ON buch(isbn);
CREATE INDEX idx_standort_koordinaten ON standort(latitude, longitude);
CREATE INDEX idx_exemplar_buch_status ON buch_exemplar(buch_id, status);
CREATE INDEX idx_exemplar_status ON buch_exemplar(status);
CREATE INDEX idx_ausleihe_entleiher_status ON ausleihe(entleiher_id, status);
CREATE INDEX idx_ausleihe_datum ON ausleihe(startdatum, enddatum);
CREATE INDEX idx_anfrage_status ON ausleihe_anfrage(status);
CREATE INDEX idx_nachricht_empfaenger ON nachricht(empfaenger_id, gelesen);
CREATE INDEX idx_bewertung_exemplar_sterne ON bewertung(exemplar_id, sterne);

SELECT '✅ 3. Alle Indizes wurden erstellt!' AS Meldung;

-- =====================================================
-- 5. TESTABFRAGEN
-- =====================================================
SELECT '══════════════════════════════════════════════════════' AS '';
SELECT '📊 4. TESTABFRAGE: Verfügbare Bücher in Berlin' AS '';
SELECT '══════════════════════════════════════════════════════' AS '';

SELECT CONCAT(n.vorname,' ',n.nachname) AS Besitzer, b.titel AS Buch, s.stadt AS Ort
FROM buch_exemplar be
JOIN buch b ON be.buch_id=b.buch_id
JOIN nutzer n ON be.besitzer_id=n.nutzer_id
JOIN standort s ON be.standort_id=s.standort_id
WHERE be.status='verfügbar' AND s.stadt='Berlin';

SELECT '══════════════════════════════════════════════════════' AS '';
SELECT '✅ 5. FULL_DATABASE.SQL - FERTIG!' AS '';
SELECT '══════════════════════════════════════════════════════' AS '';