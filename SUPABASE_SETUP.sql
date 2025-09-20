-- Supabase SQL Setup for Brand Tables
-- Run these commands in your Supabase SQL Editor

-- 1. Function to execute dynamic SQL (needed for creating tables dynamically)
CREATE OR REPLACE FUNCTION execute_sql(sql TEXT)
RETURNS VOID AS $$
BEGIN
  EXECUTE sql;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. Function to get all brand table names
CREATE OR REPLACE FUNCTION get_brand_tables()
RETURNS TEXT[] AS $$
DECLARE
  table_names TEXT[];
BEGIN
  SELECT ARRAY(
    SELECT table_name
    FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name LIKE '%_data'
    AND table_name != 'brand_data'
  ) INTO table_names;

  RETURN table_names;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 3. Sample brand tables (run after setting up the functions)
-- Example for Dole brand:
CREATE TABLE IF NOT EXISTS dole_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ripeness_score DECIMAL(5,2) NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  location_description TEXT,
  fruit_type TEXT,
  analyzed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for Dole table
CREATE INDEX IF NOT EXISTS idx_dole_data_analyzed_at ON dole_data(analyzed_at);
CREATE INDEX IF NOT EXISTS idx_dole_data_location ON dole_data(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_dole_data_ripeness ON dole_data(ripeness_score);

-- Enable RLS for Dole table
ALTER TABLE dole_data ENABLE ROW LEVEL SECURITY;

-- Policies for Dole table
CREATE POLICY IF NOT EXISTS "dole_data_insert_policy" ON dole_data
  FOR INSERT WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "dole_data_select_policy" ON dole_data
  FOR SELECT USING (true);

-- Example for Chiquita brand:
CREATE TABLE IF NOT EXISTS chiquita_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ripeness_score DECIMAL(5,2) NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  location_description TEXT,
  fruit_type TEXT,
  analyzed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for Chiquita table
CREATE INDEX IF NOT EXISTS idx_chiquita_data_analyzed_at ON chiquita_data(analyzed_at);
CREATE INDEX IF NOT EXISTS idx_chiquita_data_location ON chiquita_data(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_chiquita_data_ripeness ON chiquita_data(ripeness_score);

-- Enable RLS for Chiquita table
ALTER TABLE chiquita_data ENABLE ROW LEVEL SECURITY;

-- Policies for Chiquita table
CREATE POLICY IF NOT EXISTS "chiquita_data_insert_policy" ON chiquita_data
  FOR INSERT WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "chiquita_data_select_policy" ON chiquita_data
  FOR SELECT USING (true);

-- Add more brand tables as needed following the same pattern
-- Each brand gets its own table: {brand_name}_data