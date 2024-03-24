import mysql.connector
import redis

# Parametry połączenia z MySQL
mysql_config = {
    'host': 'localhost',
    'user': 'root',
    'password': 'pass',
    'database': 'olympics'
}

# Połączenie z Redis
redis_client = redis.Redis(host='localhost', port=6379, db=0, password='pass', decode_responses=True)

try:
    # Łączenie z MySQL
    mysql_conn = mysql.connector.connect(**mysql_config)
    mysql_cursor = mysql_conn.cursor(dictionary=True)

    # Lista tabel do migracji
    tables = ['medal', 'noc_region', 'sport', 'city', 'event', 'games', 'person', 'games_competitor', 'person_region', 'games_city', 'competitor_event']
    
    # Migracja prostych tabel
    for table in tables:
        if table not in ['games_competitor', 'person_region', 'games_city', 'competitor_event']:  # te tabele będą miały oddzielną logikę
            mysql_cursor.execute(f"SELECT * FROM {table}")
            for row in mysql_cursor.fetchall():
                # Używamy hset z mappingiem dla migracji danych
                redis_client.hset(f"{table}:{row['id']}", mapping=row)
    
    # Migracja tabeli 'games_competitor'
    mysql_cursor.execute("SELECT * FROM games_competitor")
    for row in mysql_cursor.fetchall():
        competitor_key = f"games_competitor:{row['id']}"
        redis_client.hset(competitor_key, mapping=row)
        # Dodajemy relacje do zbiorów
        redis_client.sadd(f"games:{row['games_id']}:competitors", row['id'])
        redis_client.sadd(f"person:{row['person_id']}:competitors", row['id'])

    # Migracja tabeli 'person_region'
    mysql_cursor.execute("SELECT * FROM person_region")
    for row in mysql_cursor.fetchall():
        # Tworzymy unikalny klucz dla każdego wpisu
        person_region_key = f"person:{row['person_id']}:regions"
        redis_client.sadd(person_region_key, row['region_id'])

    # Migracja tabeli 'games_city'
    mysql_cursor.execute("SELECT * FROM games_city")
    for row in mysql_cursor.fetchall():
        # Dodajemy relacje do zbiorów
        redis_client.sadd(f"games:{row['games_id']}:cities", row['city_id'])
        redis_client.sadd(f"city:{row['city_id']}:games", row['games_id'])

    # Migracja tabeli 'competitor_event'
    mysql_cursor.execute("SELECT * FROM competitor_event")
    for row in mysql_cursor.fetchall():
        # Tworzymy unikalny klucz dla każdego wpisu
        competitor_event_key = f"competitor_event:competitor:{row['competitor_id']}:event:{row['event_id']}"
        redis_client.hset(competitor_event_key, mapping=row)
        # Dodajemy relacje do zbiorów
        redis_client.sadd(f"event:{row['event_id']}:competitors", row['competitor_id'])
        # Powiązanie medalu jeśli istnieje
        if row.get('medal_id'):
            redis_client.hset(competitor_event_key, 'medal_id', row['medal_id'])

    print("Migracja danych zakończona.")

finally:
    # Bezpieczne zamykanie połączeń
    mysql_cursor.close()
    mysql_conn.close()
    redis_client.close()
