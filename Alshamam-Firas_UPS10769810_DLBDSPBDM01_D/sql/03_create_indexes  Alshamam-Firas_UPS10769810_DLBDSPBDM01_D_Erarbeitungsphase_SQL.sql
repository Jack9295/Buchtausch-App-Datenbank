-- =====================================================
-- DATENBANK: Buchtausch-App
-- DATEI: 03_create_indexes.sql
-- AUTOR: Firas Alshamam
-- MATRIKELNUMMER: UPS10769810
-- KURS: DLBDSPBDM01_D
-- BESCHREIBUNG: Erstellt Indizes für Performance-Optimierung
-- =====================================================

-- =====================================================
-- Indizes für NUTZER-Tabelle
-- =====================================================

-- Für schnelle Login-Abfragen
CREATE INDEX idx_nutzer_email ON nutzer(email);

-- Für Namenssuche
CREATE INDEX idx_nutzer_name ON nutzer(nachname, vorname);

-- Für Standort-Filterung (PLZ)
CREATE INDEX idx_nutzer_plz ON nutzer(plz);

-- Für Stadt-Filterung
CREATE INDEX idx_nutzer_stadt ON nutzer(stadt);

-- Für Registrierungsdatum (z.B. neue Nutzer)
CREATE INDEX idx_nutzer_registrierung ON nutzer(registrierungsdatum);

-- =====================================================
-- Indizes für BUCH-Tabelle
-- =====================================================

-- Für ISBN-Suche (sehr schnell)
CREATE INDEX idx_buch_isbn ON buch(isbn);

-- Für Titelsuche
CREATE INDEX idx_buch_titel ON buch(titel);

-- Für Verlag-Filterung
CREATE INDEX idx_buch_verlag ON buch(verlag_id);

-- Für Erscheinungsjahr-Filterung
CREATE INDEX idx_buch_erscheinungsjahr ON buch(erscheinungsjahr);

-- Für Sprach-Filterung
CREATE INDEX idx_buch_sprache ON buch(sprache);

-- =====================================================
-- Indizes für AUTOR-Tabelle
-- =====================================================

-- Für Autorensuche
CREATE INDEX idx_autor_name ON autor(nachname, vorname);

-- Für Nationalitäten-Filterung
CREATE INDEX idx_autor_nationalitaet ON autor(nationalitaet);

-- =====================================================
-- Indizes für VERLAG-Tabelle
-- =====================================================

-- Für Verlagsnamen-Suche
CREATE INDEX idx_verlag_name ON verlag(name);

-- Für Verlagsort-Filterung
CREATE INDEX idx_verlag_ort ON verlag(ort);

-- =====================================================
-- Indizes für GENRE-Tabelle
-- =====================================================

-- Für Genre-Suche
CREATE INDEX idx_genre_name ON genre(name);

-- Für Genre-Hierarchie (selbstreferenzierend)
CREATE INDEX idx_genre_uebergeordnet ON genre(uebergeordnetes_genre_id);

-- =====================================================
-- Indizes für STANDORT-Tabelle
-- =====================================================

-- Für Nutzer-Standorte
CREATE INDEX idx_standort_nutzer ON standort(nutzer_id);

-- Für PLZ/Stadt-Filterung
CREATE INDEX idx_standort_plz ON standort(plz);
CREATE INDEX idx_standort_stadt ON standort(stadt);

-- Für RÄUMLICHE SUCHE (sehr wichtig!)
CREATE INDEX idx_standort_koordinaten ON standort(latitude, longitude);

-- Für Standard-Standort
CREATE INDEX idx_standort_standard ON standort(ist_standard);

-- =====================================================
-- Indizes für BUCH_EXEMPLAR-Tabelle
-- =====================================================

-- Für Buch-Filterung
CREATE INDEX idx_exemplar_buch ON buch_exemplar(buch_id);

-- Für Besitzer-Filterung
CREATE INDEX idx_exemplar_besitzer ON buch_exemplar(besitzer_id);

-- Für Standort-Filterung
CREATE INDEX idx_exemplar_standort ON buch_exemplar(standort_id);

-- Für Status-Filterung (verfügbar/ausgeliehen)
CREATE INDEX idx_exemplar_status ON buch_exemplar(status);

-- Für Zustand-Filterung
CREATE INDEX idx_exemplar_zustand ON buch_exemplar(zustand);

-- Für Datums-Filterung
CREATE INDEX idx_exemplar_erstellungsdatum ON buch_exemplar(erstellungsdatum);

-- Kombinierter Index für Verfügbarkeitsprüfung (häufige Abfrage!)
CREATE INDEX idx_exemplar_buch_status ON buch_exemplar(buch_id, status);

-- =====================================================
-- Indizes für AUSLEIHE-Tabelle
-- =====================================================

-- Für Ausleihe-zu-Exemplar
CREATE INDEX idx_ausleihe_exemplar ON ausleihe(exemplar_id);

-- Für Verleiher-Filterung
CREATE INDEX idx_ausleihe_verleiher ON ausleihe(verleiher_id);

-- Für Entleiher-Filterung
CREATE INDEX idx_ausleihe_entleiher ON ausleihe(entleiher_id);

-- Für Standort-Filterung
CREATE INDEX idx_ausleihe_standort ON ausleihe(standort_id);

-- Für Status-Filterung
CREATE INDEX idx_ausleihe_status ON ausleihe(status);

-- Für Datumsbereichs-Abfragen
CREATE INDEX idx_ausleihe_datum ON ausleihe(startdatum, enddatum);

-- Für Rückgabedatum-Filterung
CREATE INDEX idx_ausleihe_rueckgabe ON ausleihe(rueckgabedatum);

-- Kombinierter Index für aktive Ausleihen eines Nutzers (häufige Abfrage!)
CREATE INDEX idx_ausleihe_entleiher_status ON ausleihe(entleiher_id, status);

-- =====================================================
-- Indizes für AUSLEIHE_ANFRAGE-Tabelle
-- =====================================================

-- Für Anfragende-Nutzer
CREATE INDEX idx_anfrage_nutzer ON ausleihe_anfrage(nutzer_id);

-- Für angefragtes Exemplar
CREATE INDEX idx_anfrage_exemplar ON ausleihe_anfrage(exemplar_id);

-- Für Anfrage-Status
CREATE INDEX idx_anfrage_status ON ausleihe_anfrage(status);

-- Für gewünschten Zeitraum
CREATE INDEX idx_anfrage_zeitraum ON ausleihe_anfrage(gewuenschter_start, gewuenschtes_ende);

-- Für Anfragedatum
CREATE INDEX idx_anfrage_datum ON ausleihe_anfrage(anfragedatum);

-- =====================================================
-- Indizes für BEWERTUNG-Tabelle
-- =====================================================

-- Für Bewertende
CREATE INDEX idx_bewertung_bewertende ON bewertung(bewertende_id);

-- Für Bewertete
CREATE INDEX idx_bewertung_bewertete ON bewertung(bewertete_id);

-- Für Exemplar-Bewertungen
CREATE INDEX idx_bewertung_exemplar ON bewertung(exemplar_id);

-- Für Ausleihe-Kontext
CREATE INDEX idx_bewertung_ausleihe ON bewertung(ausleihe_id);

-- Für Sterne-Filterung
CREATE INDEX idx_bewertung_sterne ON bewertung(sterne);

-- Für Datums-Filterung
CREATE INDEX idx_bewertung_datum ON bewertung(datum);

-- Kombinierter Index für Buchbewertungen (häufige Abfrage!)
CREATE INDEX idx_bewertung_exemplar_sterne ON bewertung(exemplar_id, sterne);

-- =====================================================
-- Indizes für NACHRICHT-Tabelle
-- =====================================================

-- Für Sender
CREATE INDEX idx_nachricht_sender ON nachricht(sender_id);

-- Für Empfänger (mit Lesestatus für ungelesene Nachrichten)
CREATE INDEX idx_nachricht_empfaenger ON nachricht(empfaenger_id, gelesen);

-- Für Zeitstempel (Sortierung)
CREATE INDEX idx_nachricht_zeitstempel ON nachricht(zeitstempel);

-- Für Betreff-Suche
CREATE INDEX idx_nachricht_betreff ON nachricht(betreff);

-- Kombinierter Index für Posteingang (häufige Abfrage!)
CREATE INDEX idx_nachricht_empfaenger_zeit ON nachricht(empfaenger_id, zeitstempel);

-- =====================================================
-- Indizes für M:N Beziehungstabellen
-- =====================================================

-- buch_autor
CREATE INDEX idx_buch_autor_buch ON buch_autor(buch_id);
CREATE INDEX idx_buch_autor_autor ON buch_autor(autor_id);

-- buch_genre
CREATE INDEX idx_buch_genre_buch ON buch_genre(buch_id);
CREATE INDEX idx_buch_genre_genre ON buch_genre(genre_id);

-- =====================================================
-- Indizes für BUCH_SUCHE (Analytics)
-- =====================================================

-- Für Nutzer-Analytics
CREATE INDEX idx_suche_nutzer ON buch_suche(nutzer_id);

-- Für Standort-basierte Suchen
CREATE INDEX idx_suche_standort ON buch_suche(standort_id);

-- Für Genre-basierte Suchen
CREATE INDEX idx_suche_genre ON buch_suche(genre_id);

-- Für Suchzeitpunkt (Zeitreihen-Analyse)
CREATE INDEX idx_suche_zeitpunkt ON buch_suche(suchzeitpunkt);

-- Für Suchbegriff-Analyse
CREATE INDEX idx_suche_begriff ON buch_suche(suchbegriff);

-- =====================================================
-- Bestätigung
-- =====================================================

SELECT '✅ Alle Indizes wurden erfolgreich erstellt!' AS Meldung;
SELECT COUNT(*) AS Anzahl_Indizes FROM information_schema.statistics 
WHERE table_schema = 'buchtausch';