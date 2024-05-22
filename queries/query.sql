use olympics;
# Zapytanie wyświetlające liczbę medali zdobytych przez zawodników z konkretnego kraju w określonym roku
SELECT nr.region_name, COUNT(ce.medal_id) AS total_medals
FROM olympics.noc_region nr
JOIN olympics.person_region pr ON nr.id = pr.region_id
JOIN olympics.person p ON pr.person_id = p.id
JOIN olympics.games_competitor gc ON p.id = gc.person_id
JOIN olympics.competitor_event ce ON gc.id = ce.competitor_id
JOIN olympics.games g ON gc.games_id = g.id
JOIN olympics.medal m ON ce.medal_id = m.id
WHERE nr.region_name = 'Poland' AND g.games_year = 2000 AND m.medal_name != 'NA';