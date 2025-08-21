# HERE API Setup Guide

## Getting a Valid HERE API Key

To fix the navigation issues in your app, you need to get a valid HERE API key:

### Step 1: Create a HERE Developer Account
1. Go to [HERE Developer Portal](https://developer.here.com/)
2. Click "Get Started" and create a free account
3. Verify your email address

### Step 2: Create a New Project
1. After logging in, click "Create App"
2. Choose "REST API" as the app type
3. Give your app a name (e.g., "LorryOwner Navigation")
4. Select the services you need:
   - **Routing API v8** (for route calculation)
   - **Geocoding API v7** (for address lookup)
   - **Search API v7** (for POI search)

### Step 3: Get Your API Key
1. Once your app is created, go to the "Credentials" tab
2. Copy the **API Key** (not the OAuth2 credentials)
3. The API key will look like: `abc123def456ghi789...`

### Step 4: Update Your Configuration
1. Open `lib/AppConstData/api_config.dart`
2. Replace `YOUR_VALID_HERE_API_KEY_HERE` with your actual API key:

```dart
static const String hereApiKey = 'your_actual_api_key_here';
static const String hereMapsApiKey = 'your_actual_api_key_here';
```

### Step 5: Test the Navigation
1. Run your app
2. Try the navigation feature
3. Check the console logs for successful API calls

## Important Notes

- **API Key vs OAuth2**: For basic routing, you only need the API key. OAuth2 is for advanced features.
- **Free Tier**: HERE offers 250,000 transactions per month for free
- **Rate Limits**: Be aware of rate limits for production use
- **Security**: Never commit your API key to public repositories

## Troubleshooting

If you still get 401 errors:
1. Verify your API key is correct
2. Check that you've enabled the Routing API service
3. Ensure your app is in "Active" status
4. Check the HERE Developer Console for any usage limits

## Alternative Solutions

If you continue having issues with HERE API:
1. Consider using Google Maps API (requires different setup)
2. Use OpenStreetMap with custom routing (free but limited)
3. Implement offline routing with stored route data

## Support

- HERE Developer Documentation: [https://developer.here.com/documentation](https://developer.here.com/documentation)
- HERE Developer Community: [https://community.here.com/](https://community.here.com/)
