-- Create Halos brand table and insert dummy data
-- Run this in your Supabase SQL Editor

-- 1. Create the halos_data table
CREATE TABLE IF NOT EXISTS halos_data (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  ripeness_score DECIMAL(5,2) NOT NULL,
  latitude DECIMAL(10,8),
  longitude DECIMAL(11,8),
  location_description TEXT,
  fruit_type TEXT,
  analyzed_at TIMESTAMP WITH TIME ZONE NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for Halos table
CREATE INDEX IF NOT EXISTS idx_halos_data_analyzed_at ON halos_data(analyzed_at);
CREATE INDEX IF NOT EXISTS idx_halos_data_location ON halos_data(latitude, longitude);
CREATE INDEX IF NOT EXISTS idx_halos_data_ripeness ON halos_data(ripeness_score);

-- Enable RLS for Halos table
ALTER TABLE halos_data ENABLE ROW LEVEL SECURITY;

-- Policies for Halos table
CREATE POLICY IF NOT EXISTS "halos_data_insert_policy" ON halos_data
  FOR INSERT WITH CHECK (true);

CREATE POLICY IF NOT EXISTS "halos_data_select_policy" ON halos_data
  FOR SELECT USING (true);

-- 2. Insert 30 dummy data points near UPenn (39.9522°N, 75.1932°W)
-- Locations within 2-mile radius with varying ripeness scores and timestamps

INSERT INTO halos_data (ripeness_score, latitude, longitude, location_description, fruit_type, analyzed_at) VALUES

-- Center City Philadelphia locations
(85.5, 39.9500, -75.1667, 'Fresh Grocer - Broad St', 'Orange', '2024-01-15 09:30:00-05'),
(78.2, 39.9485, -75.1598, 'Whole Foods - South St', 'Orange', '2024-01-15 14:22:00-05'),
(92.1, 39.9525, -75.1621, 'Trader Joes - Center City', 'Orange', '2024-01-16 11:45:00-05'),
(67.8, 39.9489, -75.1789, 'ACME - Rittenhouse', 'Orange', '2024-01-16 16:18:00-05'),
(89.3, 39.9467, -75.1654, 'Giant - Washington Ave', 'Orange', '2024-01-17 08:55:00-05'),

-- University City locations (near UPenn)
(91.7, 39.9522, -75.1932, 'Fresh Grocer - 40th St', 'Orange', '2024-01-17 13:30:00-05'),
(83.4, 39.9512, -75.1889, 'IGA - Baltimore Ave', 'Orange', '2024-01-18 10:15:00-05'),
(75.6, 39.9534, -75.1876, 'Corner Store - 42nd & Chestnut', 'Orange', '2024-01-18 17:42:00-05'),
(88.9, 39.9498, -75.1943, 'Supremo - 45th & Woodland', 'Orange', '2024-01-19 12:20:00-05'),
(79.2, 39.9556, -75.1821, 'ACME - Powelton Village', 'Orange', '2024-01-19 15:33:00-05'),

-- West Philadelphia locations
(86.1, 39.9578, -75.1734, 'ShopRite - Girard Ave', 'Orange', '2024-01-20 09:45:00-05'),
(72.3, 39.9445, -75.1698, 'Save A Lot - South St', 'Orange', '2024-01-20 14:28:00-05'),
(94.5, 39.9589, -75.1689, 'Fresh Market - Lancaster Ave', 'Orange', '2024-01-21 11:12:00-05'),
(81.7, 39.9434, -75.1756, 'Corner Deli - Grays Ferry', 'Orange', '2024-01-21 16:55:00-05'),
(77.8, 39.9567, -75.1612, 'Whole Foods - Fairmount', 'Orange', '2024-01-22 08:30:00-05'),

-- North Philadelphia locations
(90.2, 39.9634, -75.1823, 'Fresh Grocer - Girard', 'Orange', '2024-01-22 13:18:00-05'),
(69.4, 39.9678, -75.1756, 'ACME - Brewerytown', 'Orange', '2024-01-23 10:42:00-05'),
(85.6, 39.9645, -75.1634, 'ShopRite - Spring Garden', 'Orange', '2024-01-23 15:25:00-05'),
(82.1, 39.9612, -75.1598, 'Trader Joes - Fairmount', 'Orange', '2024-01-24 09:38:00-05'),
(76.9, 39.9689, -75.1789, 'Corner Market - Francisville', 'Orange', '2024-01-24 14:52:00-05'),

-- South Philadelphia locations
(87.3, 39.9378, -75.1634, 'Italian Market - 9th St', 'Orange', '2024-01-25 11:05:00-05'),
(93.8, 39.9345, -75.1598, 'Fresh Grocer - South Philly', 'Orange', '2024-01-25 16:33:00-05'),
(74.2, 39.9356, -75.1723, 'ACME - Passyunk Ave', 'Orange', '2024-01-26 08:47:00-05'),
(89.1, 39.9312, -75.1689, 'ShopRite - Oregon Ave', 'Orange', '2024-01-26 13:29:00-05'),
(80.5, 39.9389, -75.1756, 'Corner Store - Point Breeze', 'Orange', '2024-01-27 10:14:00-05'),

-- East Philadelphia locations
(91.4, 39.9467, -75.1456, 'Fresh Grocer - Northern Liberties', 'Orange', '2024-01-27 15:21:00-05'),
(78.7, 39.9523, -75.1398, 'Whole Foods - Fishtown', 'Orange', '2024-01-28 09:56:00-05'),
(84.3, 39.9445, -75.1334, 'ACME - Port Richmond', 'Orange', '2024-01-28 14:43:00-05'),
(73.6, 39.9489, -75.1423, 'Corner Deli - Kensington', 'Orange', '2024-01-29 11:37:00-05'),
(88.2, 39.9556, -75.1512, 'Fresh Market - Fishtown', 'Orange', '2024-01-29 16:08:00-05');

-- Verify the data was inserted
SELECT COUNT(*) as total_records FROM halos_data;
SELECT AVG(ripeness_score) as avg_ripeness FROM halos_data;
SELECT MIN(analyzed_at) as earliest_date, MAX(analyzed_at) as latest_date FROM halos_data;