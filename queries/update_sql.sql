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