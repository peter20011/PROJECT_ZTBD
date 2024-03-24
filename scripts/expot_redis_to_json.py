import redis
import json

# Połączenie z Redis
redis_client = redis.Redis(host='localhost', port=6379, db=0, password='pass', decode_responses=True)

# Ścieżka do pliku, w którym zostaną zapisane dane - dostosuj do swoich potrzeb
output_file = r'C:\Users\Lenovo\Desktop\Studia\ZTBD\redis_exported\redis_export.json'

# Lista tabel, które zostały zmigrowane z MySQL
tables = [
    'medal', 'noc_region', 'sport', 'city', 'event', 'games', 
    'person', 'games_competitor', 'person_region', 'games_city', 'competitor_event'
]

# Słownik na eksportowane dane
export_data = {table: [] for table in tables}

# Eksport danych dla każdej tabeli
for table in tables:
    keys = redis_client.keys(f"{table}:*")
    for key in keys:
        key_type = redis_client.type(key)
        if key_type == 'hash':
            data = redis_client.hgetall(key)
        elif key_type == 'set':
            data = list(redis_client.smembers(key))
        elif key_type == 'zset':
            data = list(redis_client.zrange(key, 0, -1, withscores=True))
        elif key_type == 'list':
            data = redis_client.lrange(key, 0, -1)
        else:
            data = redis_client.get(key)
        export_data[table].append({key: data})

# Zapis do pliku JSON
with open(output_file, 'w', encoding='utf-8') as file:
    json.dump(export_data, file, ensure_ascii=False, indent=4)

print(f"Dane z Redis zostały zapisane do {output_file}")
