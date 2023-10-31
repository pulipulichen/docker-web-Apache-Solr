import pandas as pd
import hashlib
import os

local_volume_path = os.environ.get('LOCAL_VOLUMN_PATH')
file_path = os.path.join(local_volume_path, 'data/data.csv')

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
