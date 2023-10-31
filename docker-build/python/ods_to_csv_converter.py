import pyexcel as pe

def convert_ods_to_csv(input_ods_file, output_csv_file):
    try:
        sheet = pe.get_sheet(file_name=input_ods_file)
        sheet.save_as(output_csv_file)
        #print(f"Conversion successful. CSV file created: {output_csv_file}")
    except Exception as e:
        print("Conversion failed: " + str(e))

if __name__ == "__main__":
    input_file = "/var/solr/data/collection/conf/data/data.ods"  # Replace with your ODS file
    output_file = "/tmp/data.csv"  # Replace with the desired output CSV file

    convert_ods_to_csv(input_file, output_file)
