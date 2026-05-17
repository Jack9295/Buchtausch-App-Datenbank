-- =====================================================
-- DATENBANK: Buchtausch-App
-- DATEI: 04_test_queries.sql
-- AUTOR: Firas Alshamam
-- MATRIKELNUMMER: UPS10769810
-- KURS: DLBDSPBDM01_D
-- BESCHREIBUNG: 10 Testfälle zur Validierung der Datenbank
-- =====================================================

-- =====================================================
-- TESTFALL 1: Verfügbare Bücher in Berlin
-- Zeigt alle verfügbaren Buchexemplare mit Standort Berlin
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 1: Verfügbare Bücher in Berlin' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    CONCAT(n.vorname, ' ', n.nachname) AS Besitzer,
    b.titel AS Buchtitel,
    be.zustand AS Zustand,
    s.strasse AS Strasse,
    s.plz AS PLZ,
    s.stadt AS Stadt,
    be.max_leihdauer_tage AS max_Leihdauer_Tage
FROM buch_exemplar be
JOIN buch b ON be.buch_id = b.buch_id
JOIN nutzer n ON be.besitzer_id = n.nutzer_id
JOIN standort s ON be.standort_id = s.standort_id
WHERE be.status = 'verfügbar' 
  AND s.stadt = 'Berlin'
ORDER BY b.titel;

SELECT CONCAT('Anzahl gefundener Bücher: ', COUNT(*)) AS Ergebnis 
FROM buch_exemplar be
JOIN standort s ON be.standort_id = s.standort_id
WHERE be.status = 'verfügbar' AND s.stadt = 'Berlin';

-- =====================================================
-- TESTFALL 2: Aktive Ausleihen mit Fälligkeitsdatum
-- Zeigt alle aktiven Ausleihen und berechnet den Status
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 2: Aktive Ausleihen mit Fälligkeit' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    a.ausleihe_id AS Ausleihe_ID,
    CONCAT(n_entleiher.vorname, ' ', n_entleiher.nachname) AS Entleiher,
    CONCAT(n_verleiher.vorname, ' ', n_verleiher.nachname) AS Verleiher,
    b.titel AS Buchtitel,
    a.startdatum AS Startdatum,
    a.enddatum AS Faellig_am,
    a.rueckgabedatum AS Rueckgabe,
    CASE 
        WHEN a.rueckgabedatum IS NOT NULL THEN '✓ Zurückgegeben'
        WHEN a.enddatum < CURRENT_DATE THEN '⚠ Überfällig'
        WHEN a.startdatum <= CURRENT_DATE AND a.enddatum >= CURRENT_DATE THEN '● Aktiv'
        WHEN a.startdatum > CURRENT_DATE THEN '○ Geplant'
        ELSE a.status
    END AS Status,
    DATEDIFF(a.enddatum, CURRENT_DATE) AS Tage_bis_faellig
FROM ausleihe a
JOIN nutzer n_entleiher ON a.entleiher_id = n_entleiher.nutzer_id
JOIN nutzer n_verleiher ON a.verleiher_id = n_verleiher.nutzer_id
JOIN buch_exemplar be ON a.exemplar_id = be.exemplar_id
JOIN buch b ON be.buch_id = b.buch_id
WHERE a.status IN ('aktiv', 'bestätigt', 'angefragt')
ORDER BY a.enddatum;

-- =====================================================
-- TESTFALL 3: Top bewertete Bücher (Durchschnittsbewertung ≥ 4)
-- Zeigt Bücher mit den besten Bewertungen
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 3: Top bewertete Bücher (≥ 4 Sterne)' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    b.titel AS Buchtitel,
    b.isbn AS ISBN,
    v.name AS Verlag,
    ROUND(AVG(bew.sterne), 2) AS Durchschnitt,
    COUNT(bew.bewertung_id) AS Anzahl_Bewertungen
FROM buch b
JOIN verlag v ON b.verlag_id = v.verlag_id
JOIN buch_exemplar be ON b.buch_id = be.buch_id
JOIN bewertung bew ON be.exemplar_id = bew.exemplar_id
GROUP BY b.buch_id, b.titel, b.isbn, v.name
HAVING AVG(bew.sterne) >= 4.0
ORDER BY Durchschnitt DESC, Anzahl_Bewertungen DESC;

-- =====================================================
-- TESTFALL 4: Räumliche Suche - Bücher im Umkreis von München (10km)
-- Sucht verfügbare Bücher im 10km Umkreis von München
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 4: Räumliche Suche (Umkreis München 10km)' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SET @muenchen_lat = 48.135124;
SET @muenchen_lon = 11.581981;
SET @radius_km = 10;

SELECT 
    b.titel AS Buchtitel,
    CONCAT(n.vorname, ' ', n.nachname) AS Besitzer,
    s.stadt AS Stadt,
    ROUND(
        SQRT(
            POW((s.latitude - @muenchen_lat) * 111, 2) + 
            POW((s.longitude - @muenchen_lon) * 71, 2)
        ), 1
    ) AS Entfernung_km,
    s.abholzeiten AS Abholzeiten,
    CASE WHEN s.versand_option = TRUE THEN 'Ja' ELSE 'Nein' END AS Versand
FROM buch_exemplar be
JOIN buch b ON be.buch_id = b.buch_id
JOIN nutzer n ON be.besitzer_id = n.nutzer_id
JOIN standort s ON be.standort_id = s.standort_id
WHERE be.status = 'verfügbar'
  AND s.latitude IS NOT NULL 
  AND s.longitude IS NOT NULL
HAVING Entfernung_km < @radius_km
ORDER BY Entfernung_km;

-- =====================================================
-- TESTFALL 5: Nutzer-Statistiken
-- Zeigt detaillierte Statistiken pro Nutzer
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 5: Nutzer-Statistiken' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    n.nutzer_id AS ID,
    CONCAT(n.vorname, ' ', n.nachname) AS Nutzer,
    n.stadt AS Stadt,
    COUNT(DISTINCT be.exemplar_id) AS Besitz,
    COUNT(DISTINCT a_verl.ausleihe_id) AS Verliehen,
    COUNT(DISTINCT a_entl.ausleihe_id) AS Geliehen,
    ROUND(AVG(bew_erh.sterne), 1) AS Bewertung
FROM nutzer n
LEFT JOIN buch_exemplar be ON n.nutzer_id = be.besitzer_id
LEFT JOIN ausleihe a_verl ON n.nutzer_id = a_verl.verleiher_id
LEFT JOIN ausleihe a_entl ON n.nutzer_id = a_entl.entleiher_id
LEFT JOIN bewertung bew_erh ON n.nutzer_id = bew_erh.bewertete_id
GROUP BY n.nutzer_id, n.vorname, n.nachname, n.stadt
ORDER BY Besitz DESC;

-- =====================================================
-- TESTFALL 6: Genre-Verteilung der Bücher
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 6: Genre-Verteilung' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    g.name AS Genre,
    COUNT(DISTINCT bg.buch_id) AS Anzahl_Buecher,
    COUNT(DISTINCT be.exemplar_id) AS Anzahl_Exemplare
FROM genre g
LEFT JOIN buch_genre bg ON g.genre_id = bg.genre_id
LEFT JOIN buch_exemplar be ON bg.buch_id = be.buch_id
GROUP BY g.genre_id, g.name
HAVING Anzahl_Buecher > 0
ORDER BY Anzahl_Buecher DESC;

-- =====================================================
-- TESTFALL 7: Offene Ausleihanfragen
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 7: Offene Ausleihanfragen' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    aa.anfrage_id AS ID,
    CONCAT(n.vorname, ' ', n.nachname) AS Anfragender,
    b.titel AS Buch,
    aa.gewuenschter_start AS Start,
    aa.gewuenschtes_ende AS Ende,
    aa.status AS Status,
    aa.anfragedatum AS Anfragedatum
FROM ausleihe_anfrage aa
JOIN nutzer n ON aa.nutzer_id = n.nutzer_id
JOIN buch_exemplar be ON aa.exemplar_id = be.exemplar_id
JOIN buch b ON be.buch_id = b.buch_id
WHERE aa.status = 'offen'
ORDER BY aa.anfragedatum;

-- =====================================================
-- TESTFALL 8: Beliebte Bücher (nach Ausleihhäufigkeit)
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 8: Beliebte Bücher (Top 5)' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    b.titel AS Buch,
    COUNT(DISTINCT aul.ausleihe_id) AS Ausleihen,
    ROUND(AVG(bew.sterne), 2) AS Bewertung
FROM buch b
LEFT JOIN buch_exemplar be ON b.buch_id = be.buch_id
LEFT JOIN ausleihe aul ON be.exemplar_id = aul.exemplar_id
LEFT JOIN bewertung bew ON be.exemplar_id = bew.exemplar_id
GROUP BY b.buch_id, b.titel
ORDER BY Ausleihen DESC
LIMIT 5;

-- =====================================================
-- TESTFALL 9: Datenbank-Statistiken (Übersicht)
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 9: Datenbank-Statistiken' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 
    (SELECT COUNT(*) FROM nutzer) AS Nutzer,
    (SELECT COUNT(*) FROM buch) AS Buecher,
    (SELECT COUNT(*) FROM buch_exemplar) AS Exemplare,
    (SELECT COUNT(*) FROM ausleihe) AS Ausleihen,
    (SELECT COUNT(*) FROM ausleihe WHERE rueckgabedatum IS NULL AND status = 'aktiv') AS Aktive_Ausleihen,
    (SELECT COUNT(*) FROM bewertung) AS Bewertungen,
    ROUND((SELECT AVG(sterne) FROM bewertung), 2) AS Durchschnittsbewertung;

-- =====================================================
-- TESTFALL 10: Alle Tabellen mit Eintragsanzahl
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT 'TESTFALL 10: Tabellen-Statistiken' AS Testfall;
SELECT '══════════════════════════════════════════════════════════════' AS '';

SELECT 'nutzer' AS Tabelle, COUNT(*) AS Eintraege FROM nutzer
UNION ALL SELECT 'verlag', COUNT(*) FROM verlag
UNION ALL SELECT 'autor', COUNT(*) FROM autor
UNION ALL SELECT 'genre', COUNT(*) FROM genre
UNION ALL SELECT 'buch', COUNT(*) FROM buch
UNION ALL SELECT 'buch_autor', COUNT(*) FROM buch_autor
UNION ALL SELECT 'buch_genre', COUNT(*) FROM buch_genre
UNION ALL SELECT 'standort', COUNT(*) FROM standort
UNION ALL SELECT 'buch_exemplar', COUNT(*) FROM buch_exemplar
UNION ALL SELECT 'ausleihe', COUNT(*) FROM ausleihe
UNION ALL SELECT 'ausleihe_anfrage', COUNT(*) FROM ausleihe_anfrage
UNION ALL SELECT 'bewertung', COUNT(*) FROM bewertung
UNION ALL SELECT 'nachricht', COUNT(*) FROM nachricht
UNION ALL SELECT 'buch_suche', COUNT(*) FROM buch_suche
ORDER BY Tabelle;

-- =====================================================
-- Abschlussmeldung
-- =====================================================
SELECT '══════════════════════════════════════════════════════════════' AS '';
SELECT '✅ ALLE 10 TESTFÄLLE WURDEN ERFOLGREICH AUSGEFÜHRT!' AS Abschluss;
SELECT '══════════════════════════════════════════════════════════════' AS '';