import os
import matplotlib.pyplot as plt
import csv

def read_csv_data(file_path, columns):
    data = {column: {'x': [], 'y': []} for column in columns}
    try:
        with open(file_path, 'r') as csv_file:
            csv_reader = csv.DictReader(csv_file)
            for row in csv_reader:
                iteration = int(row['Iteration'])
                for column in columns:
                    value = float(row[column])
                    data[column]['x'].append(iteration)
                    data[column]['y'].append(value)
    except FileNotFoundError:
        print(f"File {file_path} not found.")
    return data

def plot_data(data, file_name):
    plt.clf()
    for column, values in data.items():
        plt.plot(values['x'], values['y'], marker='o', linestyle='-', label=column)
    plt.xlabel('Iteration')
    plt.ylabel('Time[s]')
    plt.title(f'Execution Time per Iteration - {file_name}')
    plt.legend()
    plt.grid(True)
    output_path = os.path.join('plots', f'{file_name}.png')
    if os.path.isfile(output_path):
        os.remove(output_path)
    plt.savefig(output_path)
    plt.show()

def generate_plot(file_name, columns):
    file_path = os.path.join('output', f'{file_name}.csv')
    data = read_csv_data(file_path, columns)
    plot_data(data, file_name)

def merge_csv_files(files, output_file):
    data = {}
    for file in files:
        file_path = os.path.join('output', f'{file}.csv')
        try:
            with open(file_path, 'r') as f:
                reader = csv.DictReader(f)
                for row in reader:
                    iteration = row['Iteration']
                    if iteration not in data:
                        data[iteration] = {}
                    for column, value in row.items():
                        if column != 'Iteration':
                            data[iteration][column] = value
        except FileNotFoundError:
            print(f"File {file_path} not found.")
            return
    output_file_path = os.path.join('output', f'{output_file}.csv')
    with open(output_file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        columns = ['Iteration'] + sorted(set(column for row in data.values() for column in row.keys()))
        writer.writerow(columns)
        for iteration, row_data in sorted(data.items()):
            row = [iteration] + [row_data.get(column, '') for column in columns[1:]]
            writer.writerow(row)

def run_database_query(script, query, iterations, file_name):
    query_file = os.path.join('queries', query)
    if os.path.isfile(query_file):
        with open(query_file, 'r') as file:
            query = file.read()
    os.system(f'bash build_containers/{script}.sh "{query}" {iterations} {file_name}')
    #generate_plot(file_name, [file_name])

def main():
    os.system('bash build_containers/prepare_env.sh')
    while True:
        print("\nChoose a database:")
        print("1) MySQL")
        print("2) MariaDB")
        print("3) MongoDB")
        print("4) Redis")
        print("5) Exit")
        print("6) Merge csv files")
        choice = input("Enter your choice (1/2/3/4/5/6): ")

        if choice in ['1', '2', '3', '4']:
            db_scripts = {
                '1': 'run_mysql',
                '2': 'run_mariadb',
                '3': 'run_mongodb',
                '4': 'run_redis'
            }
            query = input("Enter your query or file (with extension): ")
            iterations = input("Enter the iteration count: ")
            file_name = input("Enter output file name (without extension): ")
            run_database_query(db_scripts[choice], query, iterations, file_name)

        elif choice == '5':
            print("Exiting...")
            break

        elif choice == '6':
            files = input("Enter the files to merge (separated by space, without extension): ").split()
            output_file = input("Enter the output file name (without extension): ")
            merge_csv_files(files, output_file)
            generate_plot(output_file, files)

        else:
            print("Invalid choice. Please try again.")

if __name__ == "__main__":
    main()
