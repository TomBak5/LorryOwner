# Truck Implementation Guide

## Overview
This document outlines the comprehensive truck selection system implemented in the LorryOwner app, featuring 15 different truck types with detailed specifications.

## Database Structure

### Table: `tbl_trailer_types`
```sql
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
);
```

## Truck Types Available

### 1. Flatbed Trailers
- **Length:** 14.6m - 16.2m
- **Width:** 2.6m
- **Weight Capacity:** 48,000 lbs (21,772 kg)
- **Uses:** Construction equipment, lumber, steel, machinery

### 2. Dry Van Trailers (Enclosed Box)
- **Length:** 8.5m - 16.2m
- **Width:** 2.6m
- **Height:** 2.4m - 2.9m
- **Weight Capacity:** 45,000 lbs (20,412 kg)
- **Uses:** General freight, packaged goods, non-perishable items

### 3. Refrigerated Trailers (Reefers)
- **Length:** 8.5m - 16.2m
- **Width:** 2.6m
- **Height:** 2.4m - 2.9m
- **Weight Capacity:** 44,000 lbs (19,958 kg)
- **Uses:** Perishable goods, food, pharmaceuticals

### 4. Lowboy Trailers (Lowbed)
- **Length:** 7.3m - 18.3m
- **Width:** 2.6m
- **Height:** 0.5m - 0.6m
- **Weight Capacity:** 80,000 lbs (36,287 kg)
- **Uses:** Heavy machinery, construction equipment, oversized loads

### 5. Step Deck Trailers (Drop Deck)
- **Length:** 14.6m - 16.2m
- **Width:** 2.6m
- **Height:** 1.1m - 1.8m
- **Weight Capacity:** 48,000 lbs (21,772 kg)
- **Uses:** Tall equipment, vehicles, industrial goods

### 6. Double Drop Trailers (RGN)
- **Length:** 8.8m - 16.2m
- **Width:** 2.6m
- **Height:** 0.25m (lowest point)
- **Weight Capacity:** 80,000 lbs (36,287 kg)
- **Uses:** Extremely tall or heavy loads

### 7. Extendable Flatbed Trailers
- **Length:** Adjustable up to 24.4m
- **Width:** 2.6m
- **Weight Capacity:** 80,000 lbs (36,287 kg)
- **Uses:** Oversized cargo, pipes, beams, wind turbine components

### 8. Conestoga Trailers (Curtain-Sided)
- **Length:** 14.6m - 16.2m
- **Width:** 2.6m
- **Height:** 2.4m - 2.9m
- **Weight Capacity:** 45,000 lbs (20,412 kg)
- **Uses:** Sensitive cargo needing weather protection

### 9. Tanker Trailers
- **Length:** 9.1m - 16.2m
- **Width:** 2.6m
- **Height:** 3.0m - 4.0m
- **Weight Capacity:** 44,000 lbs (19,958 kg)
- **Uses:** Fuel, chemicals, milk, liquid food products

### 10. Car Hauler Trailers
- **Length:** 18.3m - 24.4m
- **Width:** 2.6m
- **Height:** 3.7m - 4.3m
- **Weight Capacity:** 80,000 lbs (36,287 kg)
- **Uses:** Vehicle transport (cars, trucks, SUVs)

### 11. Gooseneck Trailers
- **Length:** 6.1m - 12.2m
- **Width:** 2.4m
- **Weight Capacity:** 30,000 lbs (13,608 kg)
- **Uses:** Livestock, equipment, boats

### 12. Dump Trailers
- **Length:** 3.7m - 9.1m
- **Width:** 2.6m
- **Height:** 1.5m - 2.1m
- **Weight Capacity:** 22,680 lbs (10,287 kg)
- **Uses:** Construction debris, gravel, sand, agricultural use

### 13. Sidekit Trailers
- **Length:** 14.6m - 16.2m
- **Width:** 2.6m
- **Height:** 2.4m
- **Weight Capacity:** 45,000 lbs (20,412 kg)
- **Uses:** Bulky items, lumber, pipes, large crates

### 14. Livestock Trailers
- **Length:** 6.1m - 16.2m
- **Width:** 2.4m
- **Height:** 1.8m - 2.4m
- **Weight Capacity:** 22,680 lbs (10,287 kg)
- **Uses:** Transporting cattle, horses, pigs, sheep

### 15. Container Chassis Trailers
- **Length:** 6.1m - 16.2m
- **Width:** 2.4m
- **Height:** 2.6m
- **Weight Capacity:** 67,200 lbs (30,481 kg)
- **Uses:** Shipping containers (intermodal transport)

## API Endpoints

### 1. Fetch Comprehensive Truck Types
- **Endpoint:** `GET /list_comprehensive_trailer_types.php`
- **Response:** JSON with all truck types and specifications
- **Usage:** Used in truck selection screen

### 2. Registration with Truck Information
- **Endpoint:** `POST /Api/reg_user.php`
- **New Parameters:**
  - `selected_brand`: Truck brand ID
  - `selected_trailer_type`: Trailer type ID
- **Usage:** Saves truck information during user registration

## Implementation Files

### Database
- `truck_types_data.sql` - Database table creation and data insertion
- `list_comprehensive_trailer_types.php` - API endpoint for fetching truck types

### Flutter App
- `lib/Api_Provider/api_provider.dart` - Updated with new API methods
- `lib/Controllers/singiup_controller.dart` - Added truck information storage
- `lib/Screens/sub_pages/truck_info_screen.dart` - Enhanced with comprehensive truck list

## Features

### 1. Comprehensive Truck Selection
- 15 different truck types with detailed specifications
- Length, width, height, and weight capacity information
- Category classification for easy filtering
- Common uses description for each truck type

### 2. Enhanced Registration Flow
- Truck information is captured during registration
- Brand and trailer type selection integrated into signup process
- Data is passed through the registration flow

### 3. Detailed Information Display
- Shows truck specifications when selected
- Displays both metric and imperial measurements
- Includes category and common uses information

## Next Steps

1. **Database Setup:** Run the `truck_types_data.sql` script to create the table and populate data
2. **API Deployment:** Upload `list_comprehensive_trailer_types.php` to your server
3. **Testing:** Test the truck selection flow in the app
4. **Integration:** Ensure truck information is properly saved during registration

## Notes

- All measurements are in meters (length, width, height)
- Weight capacities are provided in both pounds and kilograms
- The system supports both imperial and metric units for user convenience
- Truck information is optional during registration but recommended for lorry owners 