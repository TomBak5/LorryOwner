// API Configuration for LorryOwner App
class ApiConfig {
  // HERE Navigation API Configuration
  static const String hereApiKey = 'q9Qb1k7st6oCwipGKkBErA';
  
  // HERE Geocoding and Search API v7 (Current)
  static const String hereGeocodingApiUrl = 'https://geocode.search.hereapi.com/v1/geocode';
  static const String hereSearchApiUrl = 'https://browse.search.hereapi.com/v1/browse';
  static const String hereAutocompleteApiUrl = 'https://autocomplete.search.hereapi.com/v1/autocomplete';
  
  // HERE Routing API v8
  static const String hereRoutingApiUrl = 'https://router.hereapi.com/v8/routes';
  
  // HERE Maps JavaScript API - Updated to latest version
  static const String hereMapsApiKey = 'q9Qb1k7st6oCwipGKkBErA';
  static const String hereMapsCoreUrl = 'https://js.api.here.com/v3.1/mapsjs-core.js';
  static const String hereMapsServiceUrl = 'https://js.api.here.com/v3.1/mapsjs-service.js';
  static const String hereMapsUiUrl = 'https://js.api.here.com/v3.1/mapsjs-ui.js';
  static const String hereMapsEventsUrl = 'https://js.api.here.com/v3.1/mapsjs-mapevents.js';
  
  // Base API URL for your backend
  static const String baseApiUrl = 'https://your-domain.com/AdminPanel/';
  
  // API Endpoints
  static const String fuelStationsEndpoint = 'Api/get_fuel_stations.php';
  static const String truckStopsEndpoint = 'Api/get_truck_stations.php';
  static const String weighStationsEndpoint = 'Api/get_weigh_stations.php';
}
