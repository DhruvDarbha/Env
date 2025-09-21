-- VILLITA_DUMMY_DATA.sql
-- Mock data for Villita brand with ripeness scores 0-6 in Philadelphia area
-- Run this script in your Supabase SQL Editor

-- Create villita_data table if it doesn't exist
CREATE TABLE IF NOT EXISTS villita_data (
    id BIGSERIAL PRIMARY KEY,
    ripeness_score DECIMAL(4,2) NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL,
    location_description TEXT,
    fruit_type TEXT,
    analyzed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Clear existing data (optional - remove this line if you want to keep existing data)
-- DELETE FROM villita_data;

-- Insert Villita dummy data with ripeness scores 0-6
INSERT INTO villita_data (ripeness_score, latitude, longitude, location_description, fruit_type, analyzed_at) VALUES
    -- Center City Philadelphia locations
    (2.5, 39.9500, -75.1667, 'Fresh Grocer - Broad St', 'Banana', '2024-01-15 09:30:00-05:00'),
    (1.8, 39.9485, -75.1598, 'Whole Foods - South St', 'Banana', '2024-01-15 14:22:00-05:00'),
    (4.2, 39.9525, -75.1621, 'Trader Joes - Center City', 'Banana', '2024-01-16 11:45:00-05:00'),
    (0.8, 39.9489, -75.1789, 'ACME - Rittenhouse', 'Banana', '2024-01-16 16:18:00-05:00'),
    (5.3, 39.9467, -75.1654, 'Giant - Washington Ave', 'Banana', '2024-01-17 08:55:00-05:00'),

    -- University City locations (near UPenn)
    (3.7, 39.9522, -75.1932, 'Fresh Grocer - 40th St', 'Banana', '2024-01-17 13:30:00-05:00'),
    (2.4, 39.9512, -75.1889, 'IGA - Baltimore Ave', 'Banana', '2024-01-18 10:15:00-05:00'),
    (1.6, 39.9534, -75.1876, 'Corner Store - 42nd & Chestnut', 'Banana', '2024-01-18 17:42:00-05:00'),
    (4.9, 39.9498, -75.1943, 'Supremo - 45th & Woodland', 'Banana', '2024-01-19 12:20:00-05:00'),
    (2.2, 39.9556, -75.1821, 'ACME - Powelton Village', 'Banana', '2024-01-19 15:33:00-05:00'),

    -- West Philadelphia locations
    (3.1, 39.9578, -75.1734, 'ShopRite - Girard Ave', 'Banana', '2024-01-20 09:45:00-05:00'),
    (0.3, 39.9445, -75.1698, 'Save A Lot - South St', 'Banana', '2024-01-20 14:28:00-05:00'),
    (5.8, 39.9589, -75.1689, 'Fresh Market - Lancaster Ave', 'Banana', '2024-01-21 11:12:00-05:00'),
    (2.7, 39.9434, -75.1756, 'Corner Deli - Grays Ferry', 'Banana', '2024-01-21 16:55:00-05:00'),
    (1.9, 39.9567, -75.1612, 'Whole Foods - Fairmount', 'Banana', '2024-01-22 08:30:00-05:00'),

    -- North Philadelphia locations
    (4.5, 39.9634, -75.1823, 'Fresh Grocer - Girard', 'Banana', '2024-01-22 13:18:00-05:00'),
    (0.9, 39.9678, -75.1756, 'ACME - Brewerytown', 'Banana', '2024-01-23 10:42:00-05:00'),
    (3.6, 39.9645, -75.1634, 'ShopRite - Spring Garden', 'Banana', '2024-01-23 15:25:00-05:00'),
    (2.1, 39.9612, -75.1598, 'Trader Joes - Fairmount', 'Banana', '2024-01-24 09:38:00-05:00'),
    (1.3, 39.9689, -75.1789, 'Corner Market - Francisville', 'Banana', '2024-01-24 14:52:00-05:00'),

    -- South Philadelphia locations
    (4.3, 39.9378, -75.1634, 'Italian Market - 9th St', 'Banana', '2024-01-25 11:05:00-05:00'),
    (5.8, 39.9345, -75.1598, 'Fresh Grocer - South Philly', 'Banana', '2024-01-25 16:33:00-05:00'),
    (1.2, 39.9356, -75.1723, 'ACME - Passyunk Ave', 'Banana', '2024-01-26 08:47:00-05:00'),
    (4.1, 39.9312, -75.1689, 'ShopRite - Oregon Ave', 'Banana', '2024-01-26 13:29:00-05:00'),
    (2.5, 39.9389, -75.1756, 'Corner Store - Point Breeze', 'Banana', '2024-01-27 10:14:00-05:00'),

    -- East Philadelphia locations
    (3.4, 39.9467, -75.1456, 'Fresh Grocer - Northern Liberties', 'Banana', '2024-01-27 15:21:00-05:00'),
    (1.7, 39.9523, -75.1398, 'Whole Foods - Fishtown', 'Banana', '2024-01-28 09:56:00-05:00'),
    (4.8, 39.9445, -75.1334, 'ACME - Port Richmond', 'Banana', '2024-01-28 14:43:00-05:00'),
    (0.6, 39.9489, -75.1423, 'Corner Deli - Kensington', 'Banana', '2024-01-29 11:37:00-05:00'),
    (5.2, 39.9556, -75.1512, 'Fresh Market - Fishtown', 'Banana', '2024-01-29 16:08:00-05:00');

-- Verify the data was inserted
SELECT COUNT(*) as total_records FROM villita_data;
SELECT MIN(ripeness_score) as min_ripeness, MAX(ripeness_score) as max_ripeness FROM villita_data;
SELECT * FROM villita_data ORDER BY analyzed_at LIMIT 5;