import mysql.connector
import redis

# Połączenie z MySQL
mysql_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'pass',
    'database': 'olympics'
}

mysql_conn = mysql.connector.connect(**mysql_config)
mysql_cursor = mysql_conn.cursor(dictionary=True)

# Połączenie z Redis
redis_client = redis.Redis(host='localhost', port=6379, db=0, password='pass', decode_responses=True)

# Pobierz dane z MySQL
mysql_cursor.execute("""
SELECT p.full_name 
FROM person p
JOIN games_competitor gc ON p.id = gc.person_id
JOIN competitor_event ce ON gc.id = ce.competitor_id
JOIN event e ON ce.event_id = e.id
JOIN games g ON gc.games_id = g.id
JOIN medal m ON ce.medal_id = m.id
WHERE m.medal_name = 'Gold' AND e.event_name = '100m Sprint' AND g.games_name = 'Vancouver';
""")

mysql_winners = [row['full_name'] for row in mysql_cursor.fetchall()]

# Pobierz dane z Redis - założenie: masz już klucze i strukturę dla danych w Redis
# Ta część wymaga odpowiedniej logiki dostosowanej do twojej struktury danych w Redis
# Przykładowo, załóżmy, że masz identyfikatory dla "Vancouver" i "100m Sprint", i złotego medalu
event_id = 'event:1'
gold_medal_id = 'medal:1'

redis_winners = []
competitor_ids = redis_client.smembers(f"{event_id}:competitors")
for competitor_id in competitor_ids:
    medal_id = redis_client.get(f"competitor_event:{competitor_id}:{event_id}:medal")
    if medal_id == gold_medal_id:
        person_id = redis_client.hget(f"games_competitor:{competitor_id}", "person_id")
        person_name = redis_client.hget(f"person:{person_id}", "full_name")
        redis_winners.append(person_name)

# Porównanie wyników
mysql_winners_set = set(mysql_winners)
redis_winners_set = set(redis_winners)

if mysql_winners_set == redis_winners_set:
    print("Dane z MySQL i Redis są zgodne.")
else:
    print("Dane z MySQL i Redis różnią się.")

# Sprzątanie
mysql_cursor.close()
mysql_conn.close()
