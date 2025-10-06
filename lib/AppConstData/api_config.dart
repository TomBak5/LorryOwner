// API Configuration for LorryOwner App
class ApiConfig {
  // HERE Navigation API Configuration
  // ✅ CONFIGURED: Using your actual HERE API credentials
  
  // HERE Access Key (for basic routing)
  static const String hereApiKey = 'fnINROSL8maUgRUr2g0ql7Tgk0jgT2psDDjb2aubi88';
  
  // HERE API Configuration (using API key only)
  // Note: OAuth2 is not needed for basic HERE Maps services
  // Your API key is sufficient for routing, geocoding, and map tiles
  
  // HERE Maps API Key (for map tiles - using same access key)
  static const String hereMapsApiKey = 'fnINROSL8maUgRUr2g0ql7Tgk0jgT2psDDjb2aubi88';
  
  // HERE Maps JavaScript API URLs (for web-based maps)
  static const String hereMapsCoreUrl = 'https://js.api.here.com/v3.1/mapsjs-core.js';
  static const String hereMapsServiceUrl = 'https://js.api.here.com/v3.1/mapsjs-service.js';
  static const String hereMapsUiUrl = 'https://js.api.here.com/v3.1/mapsjs-ui.js';
  static const String hereMapsEventsUrl = 'https://js.api.here.com/v3.1/mapsjs-mapevents.js';
  
  // Base URLs for HERE APIs
  static const String hereRoutingBaseUrl = 'https://router.hereapi.com/v8/routes';
  static const String hereGeocodingBaseUrl = 'https://geocode.search.hereapi.com/v1/geocode';
  static const String hereSearchBaseUrl = 'https://browse.search.hereapi.com/v1/browse';
  static const String hereDiscoverBaseUrl = 'https://discover.search.hereapi.com/v1/discover';
  
  // Fuel stations search endpoint
  static const String fuelStationsEndpoint = 'Api/get_fuel_stations.php';
  
  // Weigh stations endpoint
  static const String weighStationsEndpoint = 'Api/get_weigh_stations.php';
}
