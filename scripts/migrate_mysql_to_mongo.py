import mysql.connector
from pymongo import MongoClient
from bson import json_util
import json

# Parametry połączenia z MySQL
mysql_config = {
    'host': 'localhost',
    'port': 3306,  # Dodano port
    'user': 'root',
    'password': 'pass',
    'database': 'olympics'
}

# Połączenie z MongoDB z uwierzytelnianiem
mongo_uri = "mongodb://admin:pass@localhost:27017/?authSource=admin"
mongo_db_name = "olympics"

try:
    # Łączenie z MySQL
    mysql_conn = mysql.connector.connect(**mysql_config)
    mysql_cursor = mysql_conn.cursor(dictionary=True)

    # Łączenie z MongoDB
    mongo_client = MongoClient(mongo_uri)
    mongo_db = mongo_client[mongo_db_name]

    # Pobieranie listy tabel z MySQL
    mysql_cursor.execute("SHOW TABLES")
    tables = mysql_cursor.fetchall()

    for table_info in tables:
        table_name = table_info[f"Tables_in_{mysql_config['database']}"]
        mysql_cursor.execute(f"SELECT * FROM {table_name}")
        rows = mysql_cursor.fetchall()

        # Tworzenie lub czyszczenie kolekcji w MongoDB
        mongo_collection = mongo_db[table_name]
        mongo_collection.delete_many({})  # Usuwa istniejące dokumenty w kolekcji

        # Wstawianie danych do MongoDB
        if rows:  # Sprawdzenie, czy są jakieś dane do wstawienia
            # Konwersja danych do formatu zrozumiałego dla MongoDB
            rows_json = [json.loads(json_util.dumps(row)) for row in rows]
            mongo_collection.insert_many(rows_json)

finally:
    # Bezpieczne zamykanie połączeń
    if 'mysql_cursor' in locals():
        mysql_cursor.close()
    if 'mysql_conn' in locals() and mysql_conn.is_connected():
        mysql_conn.close()
    if 'mongo_client' in locals():
        mongo_client.close()

print("Migracja danych zakończona.")
