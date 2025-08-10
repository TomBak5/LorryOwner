-- Setup Truck Types Database
-- This file creates the tbl_trailer_types table and populates it with comprehensive truck type data

-- Drop table if it exists (for clean setup)
DROP TABLE IF EXISTS `tbl_trailer_types`;

-- Create the comprehensive truck types table
CREATE TABLE `tbl_trailer_types` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `length_min` decimal(5,2) NOT NULL,
  `length_max` decimal(5,2) NOT NULL,
  `width` decimal(4,2) NOT NULL,
  `height_min` decimal(4,2) DEFAULT NULL,
  `height_max` decimal(4,2) DEFAULT NULL,
  `weight_capacity_lbs` int(11) NOT NULL,
  `weight_capacity_kg` int(11) NOT NULL,
  `common_uses` text,
  `category` varchar(50) NOT NULL,
  `status` tinyint(1) DEFAULT 1,
  `created_at` timestamp DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert comprehensive truck types data
INSERT INTO `tbl_trailer_types` (`name`, `length_min`, `length_max`, `width`, `height_min`, `height_max`, `weight_capacity_lbs`, `weight_capacity_kg`, `common_uses`, `category`) VALUES
-- 1. Flatbed Trailers
('Flatbed Trailers', 14.60, 16.20, 2.60, NULL, NULL, 48000, 21772, 'Construction equipment, lumber, steel, machinery', 'Flatbed'),

-- 2. Dry Van Trailers (Enclosed Box Trailers)
('Dry Van Trailers (Enclosed Box)', 8.50, 16.20, 2.60, 2.40, 2.90, 45000, 20412, 'General freight, packaged goods, non-perishable items', 'Enclosed'),

-- 3. Refrigerated Trailers (Reefers)
('Refrigerated Trailers (Reefers)', 8.50, 16.20, 2.60, 2.40, 2.90, 44000, 19958, 'Perishable goods, food, pharmaceuticals', 'Refrigerated'),

-- 4. Lowboy Trailers (Lowbed Trailers)
('Lowboy Trailers (Lowbed)', 7.30, 18.30, 2.60, 0.50, 0.60, 80000, 36287, 'Heavy machinery, construction equipment, oversized loads', 'Lowbed'),

-- 5. Step Deck Trailers (Drop Deck Trailers)
('Step Deck Trailers (Drop Deck)', 14.60, 16.20, 2.60, 1.10, 1.80, 48000, 21772, 'Tall equipment, vehicles, industrial goods', 'Step Deck'),

-- 6. Double Drop Trailers (RGN – Removable Gooseneck)
('Double Drop Trailers (RGN)', 8.80, 16.20, 2.60, 0.25, NULL, 80000, 36287, 'Extremely tall or heavy loads (transformers, wind turbine blades)', 'Double Drop'),

-- 7. Extendable Flatbed Trailers
('Extendable Flatbed Trailers', 0.00, 24.40, 2.60, NULL, NULL, 80000, 36287, 'Oversized cargo (pipes, beams, wind turbine components)', 'Extendable'),

-- 8. Conestoga Trailers (Curtain-Sided Trailers)
('Conestoga Trailers (Curtain-Sided)', 14.60, 16.20, 2.60, 2.40, 2.90, 45000, 20412, 'Sensitive cargo needing weather protection (aerospace, military)', 'Curtain-Sided'),

-- 9. Tanker Trailers
('Tanker Trailers', 9.10, 16.20, 2.60, 3.00, 4.00, 44000, 19958, 'Fuel, chemicals, milk, liquid food products', 'Tanker'),

-- 10. Car Hauler Trailers (Auto Transporters)
('Car Hauler Trailers (Auto Transporters)', 18.30, 24.40, 2.60, 3.70, 4.30, 80000, 36287, 'Vehicle transport (cars, trucks, SUVs)', 'Car Hauler'),

-- 11. Gooseneck Trailers
('Gooseneck Trailers', 6.10, 12.20, 2.40, NULL, NULL, 30000, 13608, 'Livestock, equipment, boats', 'Gooseneck'),

-- 12. Dump Trailers
('Dump Trailers', 3.70, 9.10, 2.60, 1.50, 2.10, 22680, 10287, 'Construction debris, gravel, sand, agricultural use', 'Dump'),

-- 13. Sidekit Trailers
('Sidekit Trailers', 14.60, 16.20, 2.60, 2.40, NULL, 45000, 20412, 'Bulky items (lumber, pipes, large crates)', 'Sidekit'),

-- 14. Livestock Trailers
('Livestock Trailers', 6.10, 16.20, 2.40, 1.80, 2.40, 22680, 10287, 'Transporting cattle, horses, pigs, sheep', 'Livestock'),

-- 15. Container Chassis Trailers
('Container Chassis Trailers', 6.10, 16.20, 2.40, 2.60, NULL, 67200, 30481, 'Shipping containers (intermodal transport)', 'Container Chassis');

-- Verify the data was inserted
SELECT COUNT(*) as total_truck_types FROM tbl_trailer_types;
SELECT id, name, category FROM tbl_trailer_types ORDER BY id;
