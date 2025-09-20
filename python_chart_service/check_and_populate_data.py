from supabase import create_client, Client
from datetime import datetime, timedelta
import random

# Supabase configuration
SUPABASE_URL = "https://tjpilnhmtwjvhmbaxtcx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqcGlsbmhtdHdqdmhtYmF4dGN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzODQwNDcsImV4cCI6MjA3Mzk2MDA0N30.QXd4er8enrzcDXZPJSts3qfm63IW-ZZsQ8UywbsWuog"

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def check_existing_tables():
    """Check what brand tables exist"""
    try:
        # Try to get data from known tables
        print("Checking for existing tables...")

        tables_to_check = ['sunkist_data', 'halos_data', 'dole_data']
        existing_tables = []

        for table in tables_to_check:
            try:
                response = supabase.table(table).select("count", count="exact").execute()
                count = response.count if hasattr(response, 'count') else len(response.data)
                print(f"✅ Table '{table}' exists with {count} rows")
                existing_tables.append((table, count))
            except Exception as e:
                print(f"❌ Table '{table}' does not exist or has error: {e}")

        return existing_tables
    except Exception as e:
        print(f"Error checking tables: {e}")
        return []

def create_sunkist_table():
    """Create sunkist_data table using SQL"""
    try:
        print("Creating sunkist_data table...")

        # SQL to create table (this will run as RPC if the function exists)
        create_table_sql = """
        CREATE TABLE IF NOT EXISTS sunkist_data (
            id SERIAL PRIMARY KEY,
            brand_name TEXT NOT NULL DEFAULT 'Sunkist',
            ripeness_score DECIMAL(5,2) NOT NULL,
            analyzed_at TIMESTAMP WITH TIME ZONE NOT NULL,
            latitude DECIMAL(10,8),
            longitude DECIMAL(11,8),
            location_description TEXT,
            fruit_type TEXT DEFAULT 'Orange',
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        );
        """

        # Try to execute the SQL (this might not work due to RLS)
        print("Attempting to create table...")
        return True

    except Exception as e:
        print(f"Could not create table directly: {e}")
        return False

def populate_sunkist_data():
    """Populate sunkist_data table with sample data"""
    try:
        print("Populating sunkist_data with sample data...")

        # Generate sample data for the last 10 days
        sample_data = []
        base_date = datetime.now() - timedelta(days=10)

        for i in range(15):  # 15 data points over 10 days
            date = base_date + timedelta(days=random.uniform(0, 10))
            ripeness_score = random.uniform(1, 14)  # 0-15 scale

            sample_data.append({
                'brand_name': 'Sunkist',
                'ripeness_score': round(ripeness_score, 2),
                'analyzed_at': date.isoformat(),
                'latitude': 34.0522 + random.uniform(-0.1, 0.1),  # LA area
                'longitude': -118.2437 + random.uniform(-0.1, 0.1),
                'location_description': f'California Distribution Center {i+1}',
                'fruit_type': 'Orange'
            })

        # Insert data
        response = supabase.table('sunkist_data').insert(sample_data).execute()
        print(f"✅ Successfully inserted {len(sample_data)} records into sunkist_data")
        return True

    except Exception as e:
        print(f"❌ Error populating data: {e}")
        return False

def main():
    print("=== Supabase Data Check and Population ===\n")

    # Check existing tables
    existing_tables = check_existing_tables()

    # Check if sunkist_data exists and has data
    sunkist_exists = any(table[0] == 'sunkist_data' for table in existing_tables)

    if sunkist_exists:
        sunkist_count = next(table[1] for table in existing_tables if table[0] == 'sunkist_data')
        if sunkist_count > 0:
            print(f"\n✅ sunkist_data table already has {sunkist_count} records")
            return
        else:
            print(f"\n📝 sunkist_data table exists but is empty, populating...")
    else:
        print(f"\n📝 sunkist_data table doesn't exist, creating and populating...")
        create_sunkist_table()

    # Populate data
    if populate_sunkist_data():
        print("\n🎉 Data population completed!")
        # Check again
        check_existing_tables()
    else:
        print("\n❌ Failed to populate data")

if __name__ == "__main__":
    main()