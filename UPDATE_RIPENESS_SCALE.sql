-- Update Halos Dummy Data Ripeness Scale from 0-100 to 0-15
-- Distribution: 0-3 (very ripe), 3-7 (just ripe), 7-15 (unripe)
-- Run this in your Supabase SQL Editor

-- Clear existing dummy data first
DELETE FROM halos_data;

-- Insert updated dummy data with correct 0-15 ripeness scale
INSERT INTO halos_data (ripeness_score, latitude, longitude, location_description, fruit_type, analyzed_at) VALUES

-- Center City Philadelphia locations (mixed ripeness)
(2.5, 39.9500, -75.1667, 'Fresh Grocer - Broad St', 'Orange', '2024-01-15 09:30:00-05'),        -- Very ripe
(5.2, 39.9485, -75.1598, 'Whole Foods - South St', 'Orange', '2024-01-15 14:22:00-05'),        -- Just ripe
(12.1, 39.9525, -75.1621, 'Trader Joes - Center City', 'Orange', '2024-01-16 11:45:00-05'),    -- Unripe
(1.8, 39.9489, -75.1789, 'ACME - Rittenhouse', 'Orange', '2024-01-16 16:18:00-05'),           -- Very ripe
(8.3, 39.9467, -75.1654, 'Giant - Washington Ave', 'Orange', '2024-01-17 08:55:00-05'),        -- Unripe

-- University City locations (near UPenn) - mixed distribution
(13.7, 39.9522, -75.1932, 'Fresh Grocer - 40th St', 'Orange', '2024-01-17 13:30:00-05'),       -- Unripe
(6.4, 39.9512, -75.1889, 'IGA - Baltimore Ave', 'Orange', '2024-01-18 10:15:00-05'),           -- Just ripe
(2.6, 39.9534, -75.1876, 'Corner Store - 42nd & Chestnut', 'Orange', '2024-01-18 17:42:00-05'), -- Very ripe
(10.9, 39.9498, -75.1943, 'Supremo - 45th & Woodland', 'Orange', '2024-01-19 12:20:00-05'),    -- Unripe
(4.2, 39.9556, -75.1821, 'ACME - Powelton Village', 'Orange', '2024-01-19 15:33:00-05'),       -- Just ripe

-- West Philadelphia locations - good distribution
(7.1, 39.9578, -75.1734, 'ShopRite - Girard Ave', 'Orange', '2024-01-20 09:45:00-05'),         -- Unripe
(1.3, 39.9445, -75.1698, 'Save A Lot - South St', 'Orange', '2024-01-20 14:28:00-05'),         -- Very ripe
(14.5, 39.9589, -75.1689, 'Fresh Market - Lancaster Ave', 'Orange', '2024-01-21 11:12:00-05'), -- Unripe
(5.7, 39.9434, -75.1756, 'Corner Deli - Grays Ferry', 'Orange', '2024-01-21 16:55:00-05'),     -- Just ripe
(2.8, 39.9567, -75.1612, 'Whole Foods - Fairmount', 'Orange', '2024-01-22 08:30:00-05'),       -- Very ripe

-- North Philadelphia locations - varied ripeness
(11.2, 39.9634, -75.1823, 'Fresh Grocer - Girard', 'Orange', '2024-01-22 13:18:00-05'),        -- Unripe
(0.4, 39.9678, -75.1756, 'ACME - Brewerytown', 'Orange', '2024-01-23 10:42:00-05'),            -- Very ripe
(7.6, 39.9645, -75.1634, 'ShopRite - Spring Garden', 'Orange', '2024-01-23 15:25:00-05'),      -- Unripe
(4.1, 39.9612, -75.1598, 'Trader Joes - Fairmount', 'Orange', '2024-01-24 09:38:00-05'),       -- Just ripe
(2.9, 39.9689, -75.1789, 'Corner Market - Francisville', 'Orange', '2024-01-24 14:52:00-05'),  -- Very ripe

-- South Philadelphia locations - realistic spread
(9.3, 39.9378, -75.1634, 'Italian Market - 9th St', 'Orange', '2024-01-25 11:05:00-05'),       -- Unripe
(13.8, 39.9345, -75.1598, 'Fresh Grocer - South Philly', 'Orange', '2024-01-25 16:33:00-05'),  -- Unripe
(3.2, 39.9356, -75.1723, 'ACME - Passyunk Ave', 'Orange', '2024-01-26 08:47:00-05'),           -- Just ripe
(10.1, 39.9312, -75.1689, 'ShopRite - Oregon Ave', 'Orange', '2024-01-26 13:29:00-05'),        -- Unripe
(5.5, 39.9389, -75.1756, 'Corner Store - Point Breeze', 'Orange', '2024-01-27 10:14:00-05'),   -- Just ripe

-- East Philadelphia locations - balanced distribution
(12.4, 39.9467, -75.1456, 'Fresh Grocer - Northern Liberties', 'Orange', '2024-01-27 15:21:00-05'), -- Unripe
(1.7, 39.9523, -75.1398, 'Whole Foods - Fishtown', 'Orange', '2024-01-28 09:56:00-05'),        -- Very ripe
(8.3, 39.9445, -75.1334, 'ACME - Port Richmond', 'Orange', '2024-01-28 14:43:00-05'),          -- Unripe
(2.6, 39.9489, -75.1423, 'Corner Deli - Kensington', 'Orange', '2024-01-29 11:37:00-05'),      -- Very ripe
(6.2, 39.9556, -75.1512, 'Fresh Market - Fishtown', 'Orange', '2024-01-29 16:08:00-05');       -- Just ripe

-- Verify the distribution
SELECT
    CASE
        WHEN ripeness_score >= 0 AND ripeness_score < 3 THEN 'Very Ripe (0-3)'
        WHEN ripeness_score >= 3 AND ripeness_score < 7 THEN 'Just Ripe (3-7)'
        WHEN ripeness_score >= 7 AND ripeness_score <= 15 THEN 'Unripe (7-15)'
        ELSE 'Out of Range'
    END as ripeness_category,
    COUNT(*) as count,
    ROUND(AVG(ripeness_score), 2) as avg_score,
    MIN(ripeness_score) as min_score,
    MAX(ripeness_score) as max_score
FROM halos_data
GROUP BY
    CASE
        WHEN ripeness_score >= 0 AND ripeness_score < 3 THEN 'Very Ripe (0-3)'
        WHEN ripeness_score >= 3 AND ripeness_score < 7 THEN 'Just Ripe (3-7)'
        WHEN ripeness_score >= 7 AND ripeness_score <= 15 THEN 'Unripe (7-15)'
        ELSE 'Out of Range'
    END
ORDER BY avg_score;

-- Show overall statistics
SELECT
    COUNT(*) as total_records,
    ROUND(AVG(ripeness_score), 2) as overall_avg,
    MIN(ripeness_score) as min_ripeness,
    MAX(ripeness_score) as max_ripeness
FROM halos_data;