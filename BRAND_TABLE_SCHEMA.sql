-- Generic Brand Table Schema and Naming Convention
-- This defines the standard for all brand tables in the system

/*
NAMING SCHEMA:
- All brand tables follow: {sanitized_brand_name}_data
- Sanitization rules:
  1. Convert to lowercase
  2. Replace spaces and special chars with underscores
  3. Remove multiple consecutive underscores
  4. Remove leading/trailing underscores

Examples:
- "Dole" → "dole_data"
- "Del Monte" → "del_monte_data"
- "Driscoll's" → "driscolls_data"
- "Tanimura & Antle" → "tanimura_antle_data"
- "Andy Boy" → "andy_boy_data"
*/

-- Function to create brand table with standard schema
CREATE OR REPLACE FUNCTION create_brand_table(brand_name TEXT)
RETURNS TEXT AS $$
DECLARE
    table_name TEXT;
    sanitized_name TEXT;
BEGIN
    -- Sanitize brand name following our naming convention
    sanitized_name := LOWER(brand_name);
    sanitized_name := REGEXP_REPLACE(sanitized_name, '[^a-z0-9]', '_', 'g');
    sanitized_name := REGEXP_REPLACE(sanitized_name, '_+', '_', 'g');
    sanitized_name := TRIM(BOTH '_' FROM sanitized_name);

    table_name := sanitized_name || '_data';

    -- Create the table with standard schema
    EXECUTE format('
        CREATE TABLE IF NOT EXISTS %I (
            id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
            ripeness_score DECIMAL(5,2) NOT NULL,
            latitude DECIMAL(10,8),
            longitude DECIMAL(11,8),
            location_description TEXT,
            fruit_type TEXT,
            analyzed_at TIMESTAMP WITH TIME ZONE NOT NULL,
            created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
        )', table_name);

    -- Create standard indexes
    EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_analyzed_at ON %I(analyzed_at)', table_name, table_name);
    EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_location ON %I(latitude, longitude)', table_name, table_name);
    EXECUTE format('CREATE INDEX IF NOT EXISTS idx_%I_ripeness ON %I(ripeness_score)', table_name, table_name);

    -- Enable Row Level Security
    EXECUTE format('ALTER TABLE %I ENABLE ROW LEVEL SECURITY', table_name);

    -- Drop existing policies if they exist
    EXECUTE format('DROP POLICY IF EXISTS "%I_insert_policy" ON %I', table_name, table_name);
    EXECUTE format('DROP POLICY IF EXISTS "%I_select_policy" ON %I', table_name, table_name);

    -- Create standard policies
    EXECUTE format('CREATE POLICY "%I_insert_policy" ON %I FOR INSERT WITH CHECK (true)', table_name, table_name);
    EXECUTE format('CREATE POLICY "%I_select_policy" ON %I FOR SELECT USING (true)', table_name, table_name);

    RETURN table_name;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to get sanitized table name (for app to use)
CREATE OR REPLACE FUNCTION get_brand_table_name(brand_name TEXT)
RETURNS TEXT AS $$
DECLARE
    sanitized_name TEXT;
BEGIN
    sanitized_name := LOWER(brand_name);
    sanitized_name := REGEXP_REPLACE(sanitized_name, '[^a-z0-9]', '_', 'g');
    sanitized_name := REGEXP_REPLACE(sanitized_name, '_+', '_', 'g');
    sanitized_name := TRIM(BOTH '_' FROM sanitized_name);

    RETURN sanitized_name || '_data';
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create tables for common brands
SELECT create_brand_table('Halos');
SELECT create_brand_table('Sunkist');
SELECT create_brand_table('Dole');
SELECT create_brand_table('Chiquita');
SELECT create_brand_table('Del Monte');
SELECT create_brand_table('Driscoll''s');
SELECT create_brand_table('Stemilt');
SELECT create_brand_table('Wonderful');
SELECT create_brand_table('Zespri');

-- Test the naming function
SELECT
    brand_name,
    get_brand_table_name(brand_name) as table_name
FROM (VALUES
    ('Halos'),
    ('Sunkist'),
    ('Del Monte'),
    ('Driscoll''s'),
    ('Tanimura & Antle'),
    ('Andy Boy'),
    ('Ocean Mist'),
    ('Green Giant')
) AS brands(brand_name);

-- Show all created brand tables
SELECT
    table_name,
    SUBSTRING(table_name FROM '^(.+)_data$') as brand_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name LIKE '%_data'
AND table_name != 'brand_data'
ORDER BY table_name;