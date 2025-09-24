# LorryOwner App - Client Testing Guide

## 📱 App Information
- **App Name**: LorryOwner (TruckBuddy)
- **Version**: 1.0.0+2
- **APK File**: `TruckBuddy-Release-v1.0.0.apk` (69.2 MB)
- **Platform**: Android (API 23+)

## 🚀 Installation Instructions

### For Client:
1. **Enable Unknown Sources**:
   - Go to Settings → Security → Unknown Sources (enable)
   - Or Settings → Apps → Special Access → Install Unknown Apps

2. **Install APK**:
   - Transfer `TruckBuddy-Release-v1.0.0.apk` to Android device
   - Tap the APK file to install
   - Follow installation prompts

3. **Grant Permissions**:
   - Location permission (required for maps and navigation)
   - Storage permission (for app data)
   - Camera permission (if using image features)

## 🧪 Testing Checklist

### Core Features to Test:
- [ ] **User Registration/Login**
  - Driver registration
  - Dispatcher registration
  - Login functionality

- [ ] **Home Screen**
  - Map display with HERE Maps
  - Current location detection
  - Driver info panel (for drivers)
  - Dispatcher menu (for dispatchers)

- [ ] **Navigation Features**
  - Route calculation
  - Turn-by-turn navigation
  - Map rotation (heading-up)
  - Zoom functionality
  - Truck icon positioning

- [ ] **Order Management**
  - Accept/Reject orders (drivers)
  - Create orders (dispatchers)
  - Order status updates
  - Route planning

- [ ] **Map Features**
  - HERE Maps tiles loading
  - Location services
  - Route visualization
  - Navigation controls

### Performance Testing:
- [ ] App startup time
- [ ] Map loading speed
- [ ] Navigation smoothness
- [ ] Memory usage
- [ ] Battery consumption

## 🐛 Bug Reporting

If you encounter issues, please provide:
1. **Device Information**:
   - Android version
   - Device model
   - Screen resolution

2. **Issue Description**:
   - What you were trying to do
   - What happened instead
   - Screenshots (if possible)

3. **Steps to Reproduce**:
   - Detailed steps to recreate the issue

## 📞 Support
- **Developer**: Your development team
- **Version**: 1.0.0+2 (Release Build)
- **Build Date**: $(Get-Date)

## 🔧 Technical Notes
- **Maps Provider**: HERE Maps
- **Navigation**: HERE Navigation API
- **Backend**: Custom PHP API
- **Database**: MySQL/PostgreSQL
- **Authentication**: Firebase Auth

## 📝 Known Limitations
- Requires internet connection for maps and navigation
- Location services must be enabled
- Some features may require backend API access
- Debug version includes additional logging

---
*This is an optimized release build for client testing. The app is production-ready with full optimizations applied.*
