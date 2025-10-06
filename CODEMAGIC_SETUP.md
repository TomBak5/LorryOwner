# Codemagic CI/CD Setup Guide for TruckBuddy

## Overview
This guide will help you set up Codemagic for building your TruckBuddy app for both Android and iOS.

## Prerequisites
1. **Codemagic Account**: Sign up at [codemagic.io](https://codemagic.io)
2. **GitHub Repository**: Your code should be on GitHub
3. **Apple Developer Account** (for iOS builds)
4. **Google Play Console Account** (for Android release)

## Step-by-Step Setup

### 1. Connect Repository to Codemagic

1. Log in to [Codemagic](https://codemagic.io)
2. Click **"Add application"**
3. Select **GitHub** and authorize Codemagic
4. Choose your repository: `TomBak5/LorryOwner`
5. Select **Flutter** as the project type

### 2. Configure Environment Variables

Go to **App settings** → **Environment variables** and add:

```
PACKAGE_NAME = com.truckbuddy.app
BUNDLE_ID = com.truckbuddy.app
```

### 3. Android Code Signing Setup

#### Generate Keystore (if you don't have one):
```bash
keytool -genkey -v -keystore truckbuddy_keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias truckbuddy
```

#### Upload to Codemagic:
1. Go to **App settings** → **Code signing identities** → **Android**
2. Upload your keystore file
3. Enter:
   - Keystore password
   - Key alias
   - Key password

### 4. iOS Code Signing Setup

#### Option A: Automatic (Recommended)
1. Go to **App settings** → **Code signing identities** → **iOS**
2. Click **"Enable automatic code signing"**
3. Enter your Apple ID credentials
4. Codemagic will automatically fetch certificates and provisioning profiles

#### Option B: Manual
1. Upload your distribution certificate (.p12)
2. Upload your provisioning profile
3. Enter certificate password

### 5. App Store Connect Configuration

1. Go to **App settings** → **Publishing** → **App Store Connect**
2. Click **"Enable App Store Connect integration"**
3. Generate an **App Store Connect API Key**:
   - Log in to [App Store Connect](https://appstoreconnect.apple.com)
   - Go to **Users and Access** → **Keys**
   - Click **"+"** to create a new key
   - Give it a name (e.g., "Codemagic")
   - Select **Developer** role
   - Download the API key (.p8 file)
4. Upload the API key to Codemagic

### 6. Google Play Console Configuration

1. Go to **App settings** → **Publishing** → **Google Play**
2. Create a service account in Google Cloud Console:
   - Go to [Google Cloud Console](https://console.cloud.google.com)
   - Create a new service account
   - Download the JSON key file
3. Grant permissions in Google Play Console:
   - Go to **Setup** → **API access**
   - Link the service account
   - Grant **Release Manager** permissions
4. Upload the service account JSON to Codemagic

### 7. Update Configuration

Edit `codemagic.yaml` and update:

```yaml
publishing:
  email:
    recipients:
      - your-email@example.com  # Change this to your email
```

### 8. Trigger a Build

#### Option 1: Automatic (on push to master)
Just push your code to the master branch:
```bash
git push origin master
```

#### Option 2: Manual
1. Go to Codemagic dashboard
2. Select your app
3. Click **"Start new build"**
4. Choose the workflow:
   - `android-release` - Build Android only
   - `ios-release` - Build iOS only
   - `all-platforms` - Build both

## Workflows Explained

### 1. `android-release`
- Builds Android APK and AAB (App Bundle)
- Runs tests and analysis
- Publishes to Google Play (internal track)

### 2. `ios-release`
- Builds iOS IPA
- Runs tests and analysis
- Publishes to TestFlight

### 3. `all-platforms`
- Builds both Android and iOS
- Triggered automatically on push to master
- Sends notifications via email/Slack

## Build Artifacts

After successful build, you'll find:
- **Android**: `build/app/outputs/flutter-apk/app-release.apk`
- **Android AAB**: `build/app/outputs/bundle/release/app-release.aab`
- **iOS**: `build/ios/ipa/truckbuddy.ipa`

## Troubleshooting

### Build Fails with "Could not find Flutter"
- Ensure `flutter: stable` is set in environment
- Check that Flutter packages are being fetched

### iOS Code Signing Issues
- Verify bundle ID matches: `com.truckbuddy.app`
- Ensure provisioning profiles are valid
- Check certificate expiration dates

### Android Signing Issues
- Verify keystore password is correct
- Check key alias matches
- Ensure keystore file is uploaded

### Large APK Warning
- The `.gitignore` now excludes APK files
- Builds are created fresh each time in Codemagic

## Free Tier Limits

Codemagic free tier includes:
- ✅ 500 build minutes/month
- ✅ Unlimited team members
- ✅ macOS, Linux, Windows builds
- ✅ Android & iOS builds

## Next Steps

1. **Set up badges**: Add build status badges to README
2. **Configure notifications**: Set up Slack/Discord webhooks
3. **Add testing**: Implement integration tests
4. **Set up staging**: Create separate workflows for dev/staging/prod

## Support

- [Codemagic Documentation](https://docs.codemagic.io)
- [Flutter CI/CD Guide](https://docs.codemagic.io/flutter-configuration/flutter-projects/)
- [Codemagic Support](https://codemagic.io/support/)

