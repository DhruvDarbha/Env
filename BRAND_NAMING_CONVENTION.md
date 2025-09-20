# Brand Table Naming Convention

## 📋 Standard Schema

Every brand gets its own table following this exact pattern:

### Naming Rules:
1. **Lowercase**: Convert brand name to lowercase
2. **Replace special chars**: Spaces, apostrophes, symbols → underscores
3. **Clean underscores**: Remove multiple consecutive underscores
4. **Add suffix**: Append `_data` to the sanitized name

### Examples:

| Brand Name | Sanitized Name | Table Name |
|------------|----------------|------------|
| Halos | halos | `halos_data` |
| Sunkist | sunkist | `sunkist_data` |
| Del Monte | del_monte | `del_monte_data` |
| Driscoll's | driscolls | `driscolls_data` |
| Tanimura & Antle | tanimura_antle | `tanimura_antle_data` |
| Andy Boy | andy_boy | `andy_boy_data` |
| Ocean Mist | ocean_mist | `ocean_mist_data` |

## 🛠️ Auto-Creation System

### Supabase Functions:
- `create_brand_table(brand_name)` - Creates standardized table
- `get_brand_table_name(brand_name)` - Returns expected table name

### Standard Table Schema:
```sql
CREATE TABLE {brand}_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ripeness_score DECIMAL(5,2) NOT NULL,        -- 0-15 scale
  latitude DECIMAL(10,8),                      -- GPS coordinates
  longitude DECIMAL(11,8),
  location_description TEXT,                   -- Human readable location
  fruit_type TEXT,                            -- Apple, Orange, etc.
  analyzed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Standard Indexes:
- `idx_{brand}_data_analyzed_at` - Time-based queries
- `idx_{brand}_data_location` - Geographic queries
- `idx_{brand}_data_ripeness` - Ripeness analytics

### Standard RLS Policies:
- `{brand}_data_insert_policy` - Allow all inserts
- `{brand}_data_select_policy` - Allow all selects

## 🚀 Usage

### Setup (Run once):
1. Execute `BRAND_TABLE_SCHEMA.sql` in Supabase SQL Editor
2. Common brands are auto-created

### App Integration:
- When new brand detected → Auto-creates table if needed
- All data follows same structure for consistent analytics
- Cross-brand queries possible with UNION

### Query Examples:
```sql
-- Single brand analytics
SELECT AVG(ripeness_score) FROM halos_data;

-- Cross-brand comparison
SELECT 'Halos' as brand, AVG(ripeness_score) FROM halos_data
UNION ALL
SELECT 'Sunkist' as brand, AVG(ripeness_score) FROM sunkist_data;

-- Geographic analysis
SELECT location_description, COUNT(*)
FROM halos_data
WHERE latitude BETWEEN 39.9 AND 40.0;
```

## 🎯 Benefits

1. **Predictable**: Know exactly what table name will be
2. **Scalable**: New brands auto-create tables
3. **Consistent**: Same schema across all brands
4. **Queryable**: Easy analytics across brands
5. **Clean**: Standardized naming prevents conflicts