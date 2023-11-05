import requests
import csv
import json
import os

local_volume_path = os.environ.get('LOCAL_VOLUMN_PATH')
input_file = os.path.join(local_volume_path, 'data/data.csv')
temp_file = os.path.join(local_volume_path, 'data/data-temp.csv')

def is_url(url):
    return url.startswith("http://") or url.startswith("https://")

def download_file(url, output_path):
    response = requests.get(url)
    if response.status_code == 200:
        with open(output_path, 'wb') as file:
            file.write(response.content)
        return True
    return False

def convert_json_to_csv(json_data, output_path):
    if json_data:
        keys = list(json_data[0].keys())
        with open(output_path, 'w', newline='') as file:
            writer = csv.DictWriter(file, fieldnames=keys)
            writer.writeheader()
            writer.writerows(json_data)

def main():

    if os.path.isfile(input_file):
        with open(input_file, 'r') as file:
            url = file.read().strip()

        if is_url(url):
            if download_file(url, temp_file):
                with open(temp_file, 'r') as file:
                    try:
                        json_data = json.load(file)
                        convert_json_to_csv(json_data, temp_file)
                    except json.JSONDecodeError:
                        pass
            else:
                print("Failed to download the file from the URL.")
        else:
            print("The file does not contain a valid URL.")
    else:
        print("File not found.")

if __name__ == "__main__":
    main()