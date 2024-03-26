import os
import matplotlib.pyplot as plt
import csv

def generate_plot(file_name, columns):
    file_name_ext = file_name + '.csv'
    file_path = os.path.join('output', file_name_ext)
    data = {}
    with open(file_path, 'r') as csv_file:
        csv_reader = csv.DictReader(csv_file)
        for column in columns:
            data[column] = {'x': [], 'y': []}

        for row in csv_reader:
            iteration = int(row['Iteration'])
            for column in columns:
                value = float(row[column])
                data[column]['x'].append(iteration)
                data[column]['y'].append(value)
    plt.clf()
    plt.legend(labels=[])
    for column in columns:
        plt.plot(data[column]['x'], data[column]['y'], marker='o', linestyle='-', label=column)

    plt.xlabel('Iteration')
    plt.ylabel('Time[s]')
    plt.title('Execution Time per Iteration - ' + file_name)
    plt.legend()
    plt.grid(True)

    if os.path.isfile(os.path.join('plots', file_name + '.png')):
        os.remove(os.path.join('plots', file_name + '.png'))

    plt.savefig(os.path.join('plots', file_name + '.png'))
    plt.show()


def merge_csv_files(files, output_file):
    data = {}

    for file in files:
        file = file + '.csv'
        file_path = os.path.join('output', file)
        with open(file_path, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                iteration = row['Iteration']
                for column, value in row.items():
                    if column != 'Iteration':
                        if iteration not in data:
                            data[iteration] = {}
                        data[iteration][column] = value

    output_file = output_file + '.csv'
    output_file_path = os.path.join('output', output_file)

    with open(output_file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        columns = ['Iteration'] + sorted(list(set(column for row in data.values() for column in row.keys())))
        writer.writerow(columns)
        for iteration, row_data in data.items():
            row = [iteration] + [row_data.get(column, '') for column in columns[1:]]
            writer.writerow(row)

def main():
    os.system('bash build_containers/prepare_env.sh')
    while True:
        print("\nChoose a database:")
        print("1) MySQL")
        print("2) Mariadb")
        print("3) MongoDB")
        print("4) Redis")
        print("5) Exit")
        print("6) Merge csv files")
        choice = input("Enter your choice (1/2/3/4/5/6): ")

        if choice == '1':
            query = input("Enter your query or file (with extension): ")
            it = input("Enter the iteration count: ")
            file_name = input("Enter output file name (without extension): ")
            query_file = os.path.join('queries', query)
            if query.endswith('.sql') and os.path.isfile(query_file):
                with open(query_file, 'r') as file:
                    query = file.read()
            os.system('bash build_containers/run_mysql.sh "' + query + '"' + ' ' + it + ' ' + file_name)
            generate_plot(file_name, [file_name])

        elif choice == '2':
            query = input("Enter your query or file (with extension): ")
            it = input("Enter the iteration count: ")
            file_name = input("Enter output file name (without extension): ")
            query_file = os.path.join('queries', query)
            if query.endswith('.sql') and os.path.isfile(query_file):
                with open(query_file, 'r') as file:
                    query = file.read()
            os.system('bash build_containers/run_mariadb.sh "' + query + '"' + ' ' + it + ' ' + file_name)
            generate_plot(file_name, [file_name])
        elif choice == '3':
            query = input("Enter your query or file (with extension): ")
            it = input("Enter the iteration count: ")
            file_name = input("Enter output file name (without extension): ")
            query_file = os.path.join('queries', query)
            if query.endswith('.js') and os.path.isfile(query_file):
                with open(query_file, 'r') as file:
                    query = file.read()
            os.system('bash build_containers/run_mongodb.sh "' + query + '"' + ' ' + it + ' ' + file_name)
            generate_plot(file_name, [file_name])
        elif choice == '4':
            query = input("Enter your query or file (with extension): ")
            it = input("Enter the iteration count: ")
            file_name = input("Enter output file name (without extension): ")
            query_file = os.path.join('queries', query)
            if query.endswith('.redis') and os.path.isfile(query_file):
                with open(query_file, 'r') as file:
                    query = file.read()
            os.system('bash build_containers/run_redis.sh "' + query + '"' + ' ' + it + ' ' + file_name)
            generate_plot(file_name, [file_name])
        elif choice == '5':
            print("Exiting...")
            break
        elif choice == '6':
            files = []
            output_file = ''
            print("Merge csv files, choose the files to merge:")
            files = input("Enter the files to merge (separated by space, without extension): ").split()
            output_file = input("Enter the output file name (without extansion): ")
            try:
                merge_csv_files(files, output_file)
                generate_plot(output_file, files)
            except FileNotFoundError:
                print("One or more input files not found.")
            except Exception as e:
                print("An error occurred:", e)
        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()
