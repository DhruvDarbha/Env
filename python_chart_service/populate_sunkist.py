from supabase import create_client, Client
from datetime import datetime, timedelta
import random
import uuid

# Supabase configuration
SUPABASE_URL = "https://tjpilnhmtwjvhmbaxtcx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqcGlsbmhtdHdqdmhtYmF4dGN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzODQwNDcsImV4cCI6MjA3Mzk2MDA0N30.QXd4er8enrzcDXZPJSts3qfm63IW-ZZsQ8UywbsWuog"

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def populate_sunkist_data():
    """Populate sunkist_data table with sample data using halos_data schema"""
    try:
        print("Populating sunkist_data with sample data...")

        # Generate sample data for the last 10 days
        sample_data = []
        base_date = datetime.now() - timedelta(days=10)

        for i in range(20):  # 20 data points over 10 days
            # Random date within the last 10 days
            days_ago = random.uniform(0, 10)
            date = base_date + timedelta(days=days_ago)

            # Random ripeness score (0-15 scale as per your specification)
            ripeness_score = round(random.uniform(0, 15), 2)

            # Sunkist locations (California citrus areas)
            locations = [
                (34.0522, -118.2437),  # Los Angeles
                (34.4208, -119.6982),  # Ventura
                (36.7378, -119.7871),  # Fresno
                (35.3733, -119.0187),  # Bakersfield
                (33.9425, -117.2297),  # Riverside
            ]
            lat, lng = random.choice(locations)
            lat += random.uniform(-0.1, 0.1)
            lng += random.uniform(-0.1, 0.1)

            sample_data.append({
                'id': str(uuid.uuid4()),
                'ripeness_score': ripeness_score,
                'latitude': round(lat, 6),
                'longitude': round(lng, 6),
                'location_description': f"{lat:.4f}, {lng:.4f}",
                'fruit_type': 'Orange',
                'analyzed_at': date.isoformat(),
                'created_at': datetime.now().isoformat()
            })

        # Insert data
        response = supabase.table('sunkist_data').insert(sample_data).execute()
        print(f"✅ Successfully inserted {len(sample_data)} records into sunkist_data")

        # Show sample of inserted data
        print("\nSample records:")
        for i, record in enumerate(sample_data[:3]):
            print(f"  {i+1}. Ripeness: {record['ripeness_score']}, Date: {record['analyzed_at'][:10]}")

        return True

    except Exception as e:
        print(f"❌ Error populating data: {e}")
        return False

def verify_data():
    """Verify the data was inserted correctly"""
    try:
        response = supabase.table('sunkist_data').select("*").limit(5).execute()
        print(f"\n✅ Verification: sunkist_data now has {len(response.data)} records (showing first 5)")
        for record in response.data:
            print(f"  - Ripeness: {record['ripeness_score']}, Date: {record['analyzed_at'][:10]}")
        return True
    except Exception as e:
        print(f"❌ Error verifying data: {e}")
        return False

def main():
    print("=== Populating sunkist_data Table ===\n")

    if populate_sunkist_data():
        print("\n🎉 Data population completed!")
        verify_data()
    else:
        print("\n❌ Failed to populate data")

if __name__ == "__main__":
    main()