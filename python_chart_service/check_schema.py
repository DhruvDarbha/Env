from supabase import create_client, Client

# Supabase configuration
SUPABASE_URL = "https://tjpilnhmtwjvhmbaxtcx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqcGlsbmhtdHdqdmhtYmF4dGN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzODQwNDcsImV4cCI6MjA3Mzk2MDA0N30.QXd4er8enrzcDXZPJSts3qfm63IW-ZZsQ8UywbsWuog"

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def check_table_schema(table_name):
    """Check what columns a table has by getting one record"""
    try:
        response = supabase.table(table_name).select("*").limit(1).execute()
        if response.data:
            print(f"\n=== {table_name} schema ===")
            sample_record = response.data[0]
            for key, value in sample_record.items():
                print(f"  {key}: {type(value).__name__} = {value}")
            return list(sample_record.keys())
        else:
            print(f"\n=== {table_name} is empty ===")
            return []
    except Exception as e:
        print(f"Error checking {table_name}: {e}")
        return []

def main():
    print("=== Checking Table Schemas ===")

    # Check halos_data schema (it has data)
    halos_columns = check_table_schema('halos_data')

    # Check sunkist_data schema
    sunkist_columns = check_table_schema('sunkist_data')

    print(f"\n=== Schema Comparison ===")
    print(f"halos_data columns: {halos_columns}")
    print(f"sunkist_data columns: {sunkist_columns}")

if __name__ == "__main__":
    main()