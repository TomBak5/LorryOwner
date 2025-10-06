# iOS Code Signing Setup for Codemagic

## The Error You're Seeing:
```
No matching profiles found for bundle identifier "com.moverslorryowner" 
and distribution type "app_store"
```

This means you need to set up code signing in Codemagic. Here are two ways to do it:

---

## **Option 1: Automatic Code Signing (EASIEST)** ⭐

This is the recommended approach - Codemagic handles everything for you!

### **Steps:**

1. **Go to Codemagic Dashboard**
   - Open your app in Codemagic
   - Click on **Settings** (gear icon)

2. **Navigate to Code Signing**
   - Go to **Code signing identities** → **iOS**

3. **Enable Automatic Code Signing**
   - Click **"Enable automatic code signing"**
   - Enter your **Apple ID** (your developer account email)
   - Enter your **App-specific password** (generate this in Apple ID settings)

4. **Authorize Codemagic**
   - Codemagic will connect to your Apple Developer account
   - It will automatically:
     - Create certificates if needed
     - Create provisioning profiles
     - Register devices
     - Keep everything up to date

5. **That's it!** ✅
   - Codemagic now handles all code signing
   - No manual certificate/profile management needed

### **How to Generate App-Specific Password:**
1. Go to [appleid.apple.com](https://appleid.apple.com)
2. Sign in with your Apple ID
3. Go to **Security** → **App-Specific Passwords**
4. Click **"+"** to generate a new password
5. Give it a name (e.g., "Codemagic")
6. Copy the password and paste it in Codemagic

---

## **Option 2: Manual Code Signing** 🔧

If you prefer manual control or already have certificates:

### **Prerequisites:**
You need these files from Apple Developer Portal:
1. **Distribution Certificate** (.p12 file)
2. **App Store Provisioning Profile** (.mobileprovision file)

### **Steps:**

#### **A. Create App ID (if not exists):**
1. Go to [Apple Developer Portal](https://developer.apple.com/account)
2. Go to **Certificates, Identifiers & Profiles**
3. Click **Identifiers** → **"+"**
4. Select **App IDs** → Continue
5. Enter:
   - Description: `TruckBuddy`
   - Bundle ID: `com.moverslorryowner`
6. Select capabilities your app needs (Location, Push Notifications, etc.)
7. Click **Continue** → **Register**

#### **B. Create Distribution Certificate (if not exists):**
1. In **Certificates, Identifiers & Profiles**
2. Click **Certificates** → **"+"**
3. Select **Apple Distribution** → Continue
4. Upload a Certificate Signing Request (CSR):
   - Open **Keychain Access** on Mac
   - Menu: **Keychain Access** → **Certificate Assistant** → **Request a Certificate from a Certificate Authority**
   - Enter your email
   - Select "Saved to disk"
   - Upload the .certSigningRequest file
5. Download the certificate (.cer)
6. Double-click to install in Keychain
7. Export as .p12:
   - Open Keychain Access
   - Find the certificate
   - Right-click → **Export**
   - Save as .p12 with password

#### **C. Create Provisioning Profile:**
1. In **Certificates, Identifiers & Profiles**
2. Click **Profiles** → **"+"**
3. Select **App Store** → Continue
4. Select App ID: `com.moverslorryowner`
5. Select your Distribution Certificate
6. Enter profile name: `TruckBuddy App Store`
7. Download the .mobileprovision file

#### **D. Upload to Codemagic:**
1. In Codemagic: **Settings** → **Code signing identities** → **iOS**
2. Click **"Upload certificate"**
   - Upload your .p12 file
   - Enter the password you set
3. Click **"Add profile"**
   - Upload your .mobileprovision file

---

## **Option 3: Remove Code Signing Temporarily (Testing)**

If you just want to test the build without App Store deployment:

Use the **ios-simulator** workflow instead:
```yaml
workflows:
  ios-simulator:
    # No code signing needed
    # Builds for simulator only
```

This won't require any provisioning profiles!

---

## **Recommendation:**

🌟 **Use Option 1 (Automatic Code Signing)**
- Easiest setup
- Codemagic handles everything
- No certificate management headaches
- Just needs your Apple ID + app-specific password

---

## **Quick Check:**

Do you have:
- ✅ **Apple Developer Account** ($99/year)?
- ✅ **Access to your Apple ID credentials**?

If **YES** → Use Option 1 (Automatic)
If **NO** → Use Option 3 (Simulator) for now

Let me know which option you'd like to proceed with!

