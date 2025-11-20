# Building Release APK with HTTP Server Support

## Changes Made to Support Release Builds

### 1. Android Permissions (`android/app/src/main/AndroidManifest.xml`)
Added required permissions:
- `INTERNET` - Required for HTTP server to accept connections
- `ACCESS_NETWORK_STATE` - Required to detect network interfaces
- `usesCleartextTraffic="true"` - Allows HTTP (non-HTTPS) traffic

### 2. ProGuard Rules (`android/app/proguard-rules.pro`)
Created ProGuard rules to prevent code stripping in release builds:
- Keeps Flutter framework classes
- Keeps Dart HTTP server classes
- Preserves native methods

### 3. Build Configuration (`android/app/build.gradle.kts`)
Updated release build type to use ProGuard rules

### 4. Server Service (`lib/services/server_service.dart`)
Enhanced server binding:
- Added `shared: true` parameter for better compatibility
- Improved error handling

## How to Build Release APK

### Option 1: Build Release APK
```bash
flutter build apk --release
```

The APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

### Option 2: Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
```

The bundle will be located at:
`build/app/outputs/bundle/release/app-release.aab`

### Option 3: Install and Run Release Mode
```bash
flutter run --release
```

## Testing the Release Build

1. **Install the APK**:
   ```bash
   flutter install --release
   ```
   Or manually install:
   ```bash
   adb install build/app/outputs/flutter-apk/app-release.apk
   ```

2. **Open the app** and tap "Start Server"

3. **Check the IP address** displayed in the app

4. **Test from another device**:
   ```bash
   curl http://YOUR_PHONE_IP:8080/category
   ```

## Troubleshooting

### Server Not Starting in Release Mode

1. **Check Permissions**:
   - Ensure the app has network permissions
   - On Android 9+, cleartext traffic must be enabled

2. **Check Logs**:
   ```bash
   adb logcat | grep flutter
   ```

3. **Port Already in Use**:
   - Stop any other instances of the app
   - Restart the device if needed

4. **Firewall Issues**:
   - Ensure no firewall is blocking port 8080
   - Try using a different network (not public WiFi)

### Release APK is Larger than Debug

This is normal. Release builds include optimizations but are not obfuscated by default in this configuration.

To enable minification (smaller APK):
```kotlin
// In android/app/build.gradle.kts
buildTypes {
    release {
        isMinifyEnabled = true  // Change to true
        ...
    }
}
```

Note: Test thoroughly if you enable minification, as it may affect the HTTP server functionality.

## Network Requirements

- **Same WiFi Network**: Devices must be on the same network to access the server
- **Port 8080**: Must not be blocked by router or firewall
- **Private Network**: Works best on private networks (home/office WiFi)

## Security Considerations for Production

If deploying to production:
1. Add authentication to API endpoints
2. Consider using HTTPS instead of HTTP
3. Implement rate limiting
4. Add request validation
5. Use a proper certificate for SSL/TLS

## Build Variants

### Debug Build
- Larger file size
- Includes debugging symbols
- Slower performance
- Easier to debug

```bash
flutter build apk --debug
```

### Release Build
- Smaller file size (with minification)
- Optimized performance
- No debugging symbols
- **HTTP Server works correctly** ✓

```bash
flutter build apk --release
```

### Profile Build
- Performance profiling enabled
- Some optimizations applied

```bash
flutter build apk --profile
```

## Server Status Verification

After installing the release build:

1. Open the app
2. Tap "Start Server"
3. You should see: "Server Status: Running"
4. The IP address should be displayed
5. Test from terminal:
   ```bash
   curl http://PHONE_IP:8080/category
   ```

Expected response:
```json
{
  "success": true,
  "message": "Categories retrieved",
  "data": [...]
}
```

## Common Issues

### Issue: "Server Status: Stopped" immediately after starting
**Solution**: Check logcat for errors, ensure permissions are granted

### Issue: Can't connect from another device
**Solution**: 
- Verify both devices on same network
- Check phone's IP address is correct
- Try pinging the phone: `ping PHONE_IP`
- Disable VPN on phone if active

### Issue: Works in debug but not release
**Solution**: 
- Verify all permissions are in AndroidManifest.xml
- Check ProGuard rules are applied
- Test with `flutter run --release` first

## Production Deployment Checklist

- [ ] Test HTTP server in release mode
- [ ] Verify all API endpoints work
- [ ] Test on multiple Android versions
- [ ] Test on different network configurations
- [ ] Add proper error handling
- [ ] Implement request logging
- [ ] Add security measures (authentication, rate limiting)
- [ ] Consider HTTPS implementation
- [ ] Update app icon and branding
- [ ] Test with signed release keystore
