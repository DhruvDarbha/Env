import '../config/api_config.dart';
import 'supabase_service.dart';

class DataInsertionService {
  /// Insert Halos dummy data into Supabase
  static Future<bool> insertHalosDummyData() async {
    try {
      if (!SupabaseService.isReady) {
        print('Supabase not configured, cannot insert dummy data');
        return false;
      }

      // Try to insert directly without creating table first
      // The table should be created manually using HALOS_DUMMY_DATA.sql
      print('Attempting to insert data into halos_data table...');

      // Dummy data points near UPenn (39.9522°N, 75.1932°W)
      final dummyData = [
        // Center City Philadelphia locations
        {
          'ripeness_score': 85.5,
          'latitude': 39.9500,
          'longitude': -75.1667,
          'location_description': 'Fresh Grocer - Broad St',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-15T09:30:00-05:00'
        },
        {
          'ripeness_score': 78.2,
          'latitude': 39.9485,
          'longitude': -75.1598,
          'location_description': 'Whole Foods - South St',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-15T14:22:00-05:00'
        },
        {
          'ripeness_score': 92.1,
          'latitude': 39.9525,
          'longitude': -75.1621,
          'location_description': 'Trader Joes - Center City',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-16T11:45:00-05:00'
        },
        {
          'ripeness_score': 67.8,
          'latitude': 39.9489,
          'longitude': -75.1789,
          'location_description': 'ACME - Rittenhouse',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-16T16:18:00-05:00'
        },
        {
          'ripeness_score': 89.3,
          'latitude': 39.9467,
          'longitude': -75.1654,
          'location_description': 'Giant - Washington Ave',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-17T08:55:00-05:00'
        },

        // University City locations (near UPenn)
        {
          'ripeness_score': 91.7,
          'latitude': 39.9522,
          'longitude': -75.1932,
          'location_description': 'Fresh Grocer - 40th St',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-17T13:30:00-05:00'
        },
        {
          'ripeness_score': 83.4,
          'latitude': 39.9512,
          'longitude': -75.1889,
          'location_description': 'IGA - Baltimore Ave',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-18T10:15:00-05:00'
        },
        {
          'ripeness_score': 75.6,
          'latitude': 39.9534,
          'longitude': -75.1876,
          'location_description': 'Corner Store - 42nd & Chestnut',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-18T17:42:00-05:00'
        },
        {
          'ripeness_score': 88.9,
          'latitude': 39.9498,
          'longitude': -75.1943,
          'location_description': 'Supremo - 45th & Woodland',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-19T12:20:00-05:00'
        },
        {
          'ripeness_score': 79.2,
          'latitude': 39.9556,
          'longitude': -75.1821,
          'location_description': 'ACME - Powelton Village',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-19T15:33:00-05:00'
        },

        // West Philadelphia locations
        {
          'ripeness_score': 86.1,
          'latitude': 39.9578,
          'longitude': -75.1734,
          'location_description': 'ShopRite - Girard Ave',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-20T09:45:00-05:00'
        },
        {
          'ripeness_score': 72.3,
          'latitude': 39.9445,
          'longitude': -75.1698,
          'location_description': 'Save A Lot - South St',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-20T14:28:00-05:00'
        },
        {
          'ripeness_score': 94.5,
          'latitude': 39.9589,
          'longitude': -75.1689,
          'location_description': 'Fresh Market - Lancaster Ave',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-21T11:12:00-05:00'
        },
        {
          'ripeness_score': 81.7,
          'latitude': 39.9434,
          'longitude': -75.1756,
          'location_description': 'Corner Deli - Grays Ferry',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-21T16:55:00-05:00'
        },
        {
          'ripeness_score': 77.8,
          'latitude': 39.9567,
          'longitude': -75.1612,
          'location_description': 'Whole Foods - Fairmount',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-22T08:30:00-05:00'
        },

        // North Philadelphia locations
        {
          'ripeness_score': 90.2,
          'latitude': 39.9634,
          'longitude': -75.1823,
          'location_description': 'Fresh Grocer - Girard',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-22T13:18:00-05:00'
        },
        {
          'ripeness_score': 69.4,
          'latitude': 39.9678,
          'longitude': -75.1756,
          'location_description': 'ACME - Brewerytown',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-23T10:42:00-05:00'
        },
        {
          'ripeness_score': 85.6,
          'latitude': 39.9645,
          'longitude': -75.1634,
          'location_description': 'ShopRite - Spring Garden',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-23T15:25:00-05:00'
        },
        {
          'ripeness_score': 82.1,
          'latitude': 39.9612,
          'longitude': -75.1598,
          'location_description': 'Trader Joes - Fairmount',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-24T09:38:00-05:00'
        },
        {
          'ripeness_score': 76.9,
          'latitude': 39.9689,
          'longitude': -75.1789,
          'location_description': 'Corner Market - Francisville',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-24T14:52:00-05:00'
        },

        // South Philadelphia locations
        {
          'ripeness_score': 87.3,
          'latitude': 39.9378,
          'longitude': -75.1634,
          'location_description': 'Italian Market - 9th St',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-25T11:05:00-05:00'
        },
        {
          'ripeness_score': 93.8,
          'latitude': 39.9345,
          'longitude': -75.1598,
          'location_description': 'Fresh Grocer - South Philly',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-25T16:33:00-05:00'
        },
        {
          'ripeness_score': 74.2,
          'latitude': 39.9356,
          'longitude': -75.1723,
          'location_description': 'ACME - Passyunk Ave',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-26T08:47:00-05:00'
        },
        {
          'ripeness_score': 89.1,
          'latitude': 39.9312,
          'longitude': -75.1689,
          'location_description': 'ShopRite - Oregon Ave',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-26T13:29:00-05:00'
        },
        {
          'ripeness_score': 80.5,
          'latitude': 39.9389,
          'longitude': -75.1756,
          'location_description': 'Corner Store - Point Breeze',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-27T10:14:00-05:00'
        },

        // East Philadelphia locations
        {
          'ripeness_score': 91.4,
          'latitude': 39.9467,
          'longitude': -75.1456,
          'location_description': 'Fresh Grocer - Northern Liberties',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-27T15:21:00-05:00'
        },
        {
          'ripeness_score': 78.7,
          'latitude': 39.9523,
          'longitude': -75.1398,
          'location_description': 'Whole Foods - Fishtown',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-28T09:56:00-05:00'
        },
        {
          'ripeness_score': 84.3,
          'latitude': 39.9445,
          'longitude': -75.1334,
          'location_description': 'ACME - Port Richmond',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-28T14:43:00-05:00'
        },
        {
          'ripeness_score': 73.6,
          'latitude': 39.9489,
          'longitude': -75.1423,
          'location_description': 'Corner Deli - Kensington',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-29T11:37:00-05:00'
        },
        {
          'ripeness_score': 88.2,
          'latitude': 39.9556,
          'longitude': -75.1512,
          'location_description': 'Fresh Market - Fishtown',
          'fruit_type': 'Orange',
          'analyzed_at': '2024-01-29T16:08:00-05:00'
        },
      ];

      // Insert each data point directly to halos_data table
      int successCount = 0;
      for (final data in dummyData) {
        try {
          await SupabaseService.client!.from('halos_data').insert({
            'ripeness_score': data['ripeness_score'],
            'latitude': data['latitude'],
            'longitude': data['longitude'],
            'location_description': data['location_description'],
            'fruit_type': data['fruit_type'],
            'analyzed_at': data['analyzed_at'],
          });
          successCount++;
          print('Inserted: ${data['location_description']}');
        } catch (e) {
          print('Failed to insert ${data['location_description']}: $e');
        }
      }

      print('Successfully inserted $successCount out of ${dummyData.length} Halos data points');
      return successCount == dummyData.length;

    } catch (e) {
      print('Error inserting Halos dummy data: $e');
      return false;
    }
  }
}