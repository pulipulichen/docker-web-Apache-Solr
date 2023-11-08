import pandas as pd
import hashlib
import os
import argparse

# =================================================================

def calculate_md5(row):
    id_value = row['id']
    if pd.isnull(id_value):
        other_values = [str(val) for col, val in row.items() if col != 'id']
        id_value = ','.join(other_values)
    md5 = hashlib.md5(id_value.encode()).hexdigest()
    return md5

def process_csv(file_path):
    df = pd.read_csv(file_path)

    for index, row in df.iterrows():
        print(row['id'])
        if row['id'] != '' or row['id'] is not None:
            continue

        md5_id = calculate_md5(row)
        df.at[index, 'id'] = md5_id  # Update the 'id' column in the DataFrame
        print(f"Row {index}: Original ID: {row['id']}, Calculated MD5 ID: {md5_id}")

    # Write back to a new CSV file if needed
    df.to_csv(file_path, index=False)

# =================================================================
def main(file_path):
    # local_volume_path = os.environ.get('LOCAL_VOLUMN_PATH')
    # file_path = os.path.join(local_volume_path, 'data.csv')

    # Check if the file exists
    if not os.path.isfile(file_path):
        print(f"File {file_path} doesn't exist.")
    else:
        # Read the CSV file
        df = pd.read_csv(file_path)

        # Check if "id" column exists
        if 'id' not in df.columns:
            # Concatenate row values and calculate MD5 to create IDs
            def calculate_id(row):
                row_string = ','.join([str(val) for val in row])
                row_hash = hashlib.md5(row_string.encode()).hexdigest()
                return row_hash

            # Apply the function to each row in the DataFrame
            df['id'] = df.apply(calculate_id, axis=1)

            # Save the updated DataFrame back to the CSV file
            df.to_csv(file_path, index=False)
            print("IDs generated and saved to the CSV file.")
        else:
            print("The 'id' column already exists in the file.")
            # Replace 'your_file.csv' with the path to your CSV file
            process_csv(file_path)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process the file content')
    parser.add_argument('input_file', help='Path to the input file')
    args = parser.parse_args()

    main(args.input_file)