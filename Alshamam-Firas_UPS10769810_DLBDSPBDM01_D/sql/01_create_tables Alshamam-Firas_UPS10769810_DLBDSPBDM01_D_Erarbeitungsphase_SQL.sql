-- =====================================================
-- DATENBANK: Buchtausch-App
-- DATEI: 01_create_tables.sql
-- AUTOR: Firas Alshamam
-- MATRIKELNUMMER: UPS10769810
-- KURS: DLBDSPBDM01_D
-- BESCHREIBUNG: Erstellt alle 14 Tabellen
-- =====================================================

-- =====================================================
-- TABELLE 1: nutzer
-- =====================================================
DROP TABLE IF EXISTS nutzer CASCADE;
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
    ist_aktiv BOOLEAN DEFAULT TRUE,
    CHECK (email LIKE '%_@__%.__%')
);

-- =====================================================
-- TABELLE 2: verlag
-- =====================================================
DROP TABLE IF EXISTS verlag CASCADE;
CREATE TABLE verlag (
    verlag_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    ort VARCHAR(100) NOT NULL,
    website VARCHAR(200),
    email VARCHAR(100),
    telefon VARCHAR(20),
    gruendungsjahr INT,
    CHECK (gruendungsjahr >= 1400 OR gruendungsjahr IS NULL)
);

-- =====================================================
-- TABELLE 3: autor
-- =====================================================
DROP TABLE IF EXISTS autor CASCADE;
CREATE TABLE autor (
    autor_id INT PRIMARY KEY AUTO_INCREMENT,
    vorname VARCHAR(50) NOT NULL,
    nachname VARCHAR(50) NOT NULL,
    geburtsdatum DATE,
    nationalitaet VARCHAR(50),
    biografie TEXT,
    website VARCHAR(200),
    CHECK (geburtsdatum <= CURRENT_DATE)
);

-- =====================================================
-- TABELLE 4: genre
-- =====================================================
DROP TABLE IF EXISTS genre CASCADE;
CREATE TABLE genre (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL UNIQUE,
    beschreibung VARCHAR(200),
    uebergeordnetes_genre_id INT,
    FOREIGN KEY (uebergeordnetes_genre_id) REFERENCES genre(genre_id)
);

-- =====================================================
-- TABELLE 5: buch
-- =====================================================
DROP TABLE IF EXISTS buch CASCADE;
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
    FOREIGN KEY (verlag_id) REFERENCES verlag(verlag_id),
    CHECK (erscheinungsjahr >= 1400 OR erscheinungsjahr IS NULL),
    CHECK (seitenzahl > 0 OR seitenzahl IS NULL)
);

-- =====================================================
-- TABELLE 6: buch_autor (M:N)
-- =====================================================
DROP TABLE IF EXISTS buch_autor CASCADE;
CREATE TABLE buch_autor (
    buch_id INT NOT NULL,
    autor_id INT NOT NULL,
    hauptautor BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (buch_id, autor_id),
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id) ON DELETE CASCADE,
    FOREIGN KEY (autor_id) REFERENCES autor(autor_id) ON DELETE CASCADE
);

-- =====================================================
-- TABELLE 7: buch_genre (M:N)
-- =====================================================
DROP TABLE IF EXISTS buch_genre CASCADE;
CREATE TABLE buch_genre (
    buch_id INT NOT NULL,
    genre_id INT NOT NULL,
    PRIMARY KEY (buch_id, genre_id),
    FOREIGN KEY (buch_id) REFERENCES buch(buch_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id) REFERENCES genre(genre_id) ON DELETE CASCADE
);

-- =====================================================
-- TABELLE 8: standort
-- =====================================================
DROP TABLE IF EXISTS standort CASCADE;
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
    FOREIGN KEY (nutzer_id) REFERENCES nutzer(nutzer_id) ON DELETE CASCADE,
    CHECK (latitude BETWEEN -90 AND 90),
    CHECK (longitude BETWEEN -180 AND 180)
);

-- =====================================================
-- TABELLE 9: buch_exemplar
-- =====================================================
DROP TABLE IF EXISTS buch_exemplar CASCADE;
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
    FOREIGN KEY (standort_id) REFERENCES standort(standort_id),
    CHECK (zustand IN ('neu', 'sehr gut', 'gut', 'akzeptabel', 'gebraucht')),
    CHECK (status IN ('verfügbar', 'reserviert', 'ausgeliehen', 'nicht verfügbar')),
    CHECK (max_leihdauer_tage BETWEEN 1 AND 365)
);

-- =====================================================
-- TABELLE 10: ausleihe
-- =====================================================
DROP TABLE IF EXISTS ausleihe CASCADE;
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
    FOREIGN KEY (standort_id) REFERENCES standort(standort_id),
    CHECK (status IN ('angefragt', 'bestätigt', 'aktiv', 'abgeschlossen', 'storniert', 'überfällig')),
    CHECK (startdatum <= enddatum),
    CHECK (rueckgabedatum >= startdatum OR rueckgabedatum IS NULL)
);

-- =====================================================
-- TABELLE 11: ausleihe_anfrage (TERNÄR)
-- =====================================================
DROP TABLE IF EXISTS ausleihe_anfrage CASCADE;
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
    FOREIGN KEY (exemplar_id) REFERENCES buch_exemplar(exemplar_id),
    CHECK (status IN ('offen', 'akzeptiert', 'abgelehnt', 'zurückgezogen')),
    CHECK (gewuenschter_start <= gewuenschtes_ende)
);

-- =====================================================
-- TABELLE 12: bewertung
-- =====================================================
DROP TABLE IF EXISTS bewertung CASCADE;
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
    FOREIGN KEY (ausleihe_id) REFERENCES ausleihe(ausleihe_id),
    CHECK (sterne BETWEEN 1 AND 5),
    CHECK (
        (bewertete_id IS NOT NULL AND exemplar_id IS NULL) OR
        (bewertete_id IS NULL AND exemplar_id IS NOT NULL)
    )
);

-- =====================================================
-- TABELLE 13: nachricht
-- =====================================================
DROP TABLE IF EXISTS nachricht CASCADE;
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

-- =====================================================
-- TABELLE 14: buch_suche (TERNÄR für Analytics)
-- =====================================================
DROP TABLE IF EXISTS buch_suche CASCADE;
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

SELECT 'Alle 14 Tabellen wurden erfolgreich erstellt!' AS Meldung;