select * from olympics.person;

# Wybierz wszystkich zawodników, którzy zdobyli medal
SELECT p.full_name, COUNT(m.medal_name) AS total_medals
FROM olympics.person p
JOIN olympics.games_competitor gc ON p.id = gc.person_id
JOIN olympics.competitor_event ce ON gc.id = ce.competitor_id
JOIN olympics.medal m ON ce.medal_id = m.id
WHERE m.medal_name != 'NA'
GROUP BY p.full_name
ORDER BY total_medals DESC;


# Wybierz liczbę zawodników w każdym regionie
SELECT nr.region_name, COUNT(pr.person_id) AS total_players
FROM olympics.noc_region nr
JOIN olympics.person_region pr ON nr.id = pr.region_id
GROUP BY nr.region_name
ORDER BY total_players DESC;


# Wybierz zawodników o wzroście powyżej 180 cm
SELECT p.full_name, p.height
FROM olympics.person p
WHERE p.height > 180;


# Średnia waga u kobiet w zaleznosci od roku
SELECT g.games_year, AVG(p.weight) AS average_weight
FROM olympics.person p
JOIN olympics.games_competitor gc ON p.id = gc.person_id
JOIN olympics.games g ON gc.games_id = g.id
WHERE p.gender = 'F'
GROUP BY g.games_year;


# Zapytanie wyświetlające zawodników, którzy zdobyli medal w konkretnym wydarzeniu, uporządkowane według nazwiska
SELECT p.full_name, e.event_name, m.medal_name
FROM olympics.person p
JOIN olympics.games_competitor gc ON p.id = gc.person_id
JOIN olympics.competitor_event ce ON gc.id = ce.competitor_id
JOIN olympics.event e ON ce.event_id = e.id
JOIN olympics.medal m ON ce.medal_id = m.id
WHERE e.event_name = 'Sailing Mixed Two Person Heavyweight Dinghy' AND m.medal_name != 'NA'
ORDER BY p.full_name;


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


# Zwiększenie wzrostu o 1 dla zawodnika z USA, który nie zdobył złotego medalu w określonym roku
UPDATE olympics.person AS p
JOIN olympics.person_region AS pr ON p.id = pr.person_id
JOIN olympics.noc_region AS nr ON pr.region_id = nr.id
JOIN olympics.games_competitor AS gc ON p.id = gc.person_id
JOIN olympics.competitor_event AS ce ON gc.id = ce.competitor_id
JOIN olympics.medal AS m ON ce.medal_id = m.id
JOIN olympics.games AS g ON gc.games_id = g.id
SET p.height = p.height + 1
WHERE nr.region_name = 'USA'
AND g.games_year = 1998
AND m.medal_name != 'Gold';


#Ustaw wszystki zaowdnikm z polski złoty medal
UPDATE olympics.competitor_event ce
JOIN olympics.games_competitor gc ON ce.competitor_id = gc.id
JOIN olympics.person p ON gc.person_id = p.id
JOIN olympics.person_region pr ON p.id = pr.person_id
JOIN olympics.noc_region nr ON pr.region_id = nr.id
JOIN olympics.games g ON gc.games_id = g.id
SET ce.medal_id = (
    SELECT id FROM olympics.medal WHERE medal_name = 'Gold'
)
WHERE nr.region_name = 'Poland';


# Każdy +5kg
UPDATE olympics.person
SET weight = weight + 5;
