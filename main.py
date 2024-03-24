import os

def main():
    os.system('bash prepare_env.sh')
    while True:
        print("\nChoose a database:")
        print("1) MySQL")
        print("2) Mariadb")
        print("3) MongoDB")
        print("4) Redis")
        print("5) Exit")
        choice = input("Enter your choice (1/2/3/4/5): ")

        if choice == '1':
            query = input("Enter your query: ")
            if query.endswith('.sql') and os.path.isfile(query):
                with open(query, 'r') as file:
                    query = file.read()
            os.system('bash run_mysql.sh "' + query + '"')
        elif choice == '2':
            query = input("Enter your query: ")
            if query.endswith('.sql') and os.path.isfile(query):
                with open(query, 'r') as file:
                    query = file.read()
            os.system('bash run_mariadb.sh "' + query + '"')
        elif choice == '3':
            query = input("Enter your query: ")
            if query.endswith('.js') and os.path.isfile(query):
                with open(query, 'r') as file:
                    query = file.read()
            os.system('bash run_mongodb.sh "' + query + '"')
        elif choice == '4':
            query = input("Enter your query: ")
            if query.endswith('.redis') and os.path.isfile(query):
                with open(query, 'r') as file:
                    query = file.read()
            os.system('bash run_redis.sh "' + query + '"')
        elif choice == '5':
            print("Exiting...")
            break
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()
