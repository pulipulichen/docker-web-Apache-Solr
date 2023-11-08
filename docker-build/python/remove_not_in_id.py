import requests
import pandas as pd
import json
import os
import argparse

def main(file_path):
    # Read the CSV file and extract 'id' values
    # local_volume_path = os.environ.get('LOCAL_VOLUMN_PATH')
    # file_path = os.path.join(local_volume_path, 'data.csv')
    absolute_path = os.path.abspath(file_path)

    data = pd.read_csv(absolute_path)
    id_values = data['id'].tolist()

    if len(id_values) > 200:
        delete_url = f'http://localhost:8983/solr/collection/update?commit=true'
        delete_data = json.dumps({"delete": {"query": "*:*"}})
        requests.post(delete_url, headers={"Content-Type": "application/json"}, data=delete_data)
        print("Reset all index.")
        return

    # print(id_values)
    id_values_str = ' '.join(map(str, id_values))

    # Fetch data from Solr
    solr_endpoint = f'http://localhost:8983/solr/collection/select?q=*:*&wt=json&fq=-id:({id_values_str})&fl=id&rows=1000000'
    # print(solr_endpoint)
    response = requests.get(solr_endpoint)
    if response.status_code == 200:
        solr_data = response.json()['response']['docs']
        updated_solr_data = [item for item in solr_data if str(item.get('id')) in id_values]

        # print(solr_data)

        # Delete items not in the CSV 'id' list
        for item in solr_data:
            if str(item.get('id')) not in id_values:
                delete_url = f'http://localhost:8983/solr/collection/update?commit=true'
                delete_data = json.dumps({"delete": {"id": str(item.get('id'))}})
                requests.post(delete_url, headers={"Content-Type": "application/json"}, data=delete_data)

        # # Post updated data back to Solr
        update_url = f'http://localhost:8983/solr/collection/update?commit=true'
        update_data = json.dumps(updated_solr_data)
        requests.post(update_url, headers={"Content-Type": "application/json"}, data=update_data)
        print("Data updated in Solr. wait for next step...")
    else:
        print("Failed to fetch data from Solr.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process the file content')
    parser.add_argument('input_file', help='Path to the input file')
    args = parser.parse_args()

    main(args.input_file)