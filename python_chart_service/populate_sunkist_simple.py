from supabase import create_client, Client
from datetime import datetime, timedelta
import random

# Supabase configuration
SUPABASE_URL = "https://tjpilnhmtwjvhmbaxtcx.supabase.co"
SUPABASE_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InRqcGlsbmhtdHdqdmhtYmF4dGN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTgzODQwNDcsImV4cCI6MjA3Mzk2MDA0N30.QXd4er8enrzcDXZPJSts3qfm63IW-ZZsQ8UywbsWuog"

# Initialize Supabase client
supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

def populate_sunkist_data():
    """Populate sunkist_data table with sample data matching halos_data schema"""
    try:
        print("Populating sunkist_data with sample data...")

        # Generate sample data for the last 10 days
        sample_data = []
        base_date = datetime.now() - timedelta(days=10)

        for i in range(20):  # 20 data points over 10 days
            # Random date within the last 10 days
            days_ago = random.uniform(0, 10)
            date = base_date + timedelta(days=days_ago)

            # Random ripeness score (0-15 scale)
            ripeness_score = round(random.uniform(0, 15), 2)

            # Sunkist locations (Philadelphia area)
            locations = [
                (39.9526, -75.1652),  # Philadelphia Center
                (40.0378, -75.3426),  # King of Prussia
                (39.8781, -75.2803),  # Drexel Hill
                (40.0583, -75.0862),  # Bensalem
                (39.8365, -75.3780),  # Media
            ]
            lat, lng = random.choice(locations)
            lat += random.uniform(-0.1, 0.1)
            lng += random.uniform(-0.1, 0.1)

            # Match halos_data schema exactly (no id field, let DB auto-generate)
            sample_data.append({
                'ripeness_score': ripeness_score,
                'latitude': round(lat, 6),
                'longitude': round(lng, 6),
                'location_description': f"{lat:.4f}, {lng:.4f}",
                'fruit_type': 'Orange',
                'analyzed_at': date.isoformat(),
            })

        # Insert data one by one to identify any specific issues
        success_count = 0
        for i, record in enumerate(sample_data):
            try:
                print(f"Inserting record {i+1}...")
                response = supabase.table('sunkist_data').insert(record).execute()
                success_count += 1
                print(f"✅ Record {i+1} inserted successfully")
            except Exception as e:
                print(f"❌ Error inserting record {i+1}: {e}")

        print(f"✅ Successfully inserted {success_count} out of {len(sample_data)} records into sunkist_data")
        return success_count > 0

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