---
name: profile-image
description: A comprehensive guide to implementing a profile image upload feature with camera/gallery selection, Base64 conversion, and Odoo JSON-RPC integration.
---

# Implementing Profile Image Upload with Odoo (Zero to Hero)

This skill provides a complete guide on how to build a profile image upload system in Flutter. It covers picking images from the device's camera or gallery, encoding them to Base64, uploading them to an Odoo backend via JSON-RPC, and safely displaying the returned image URLs on an Android emulator.

## 1. Prerequisites

Add the required dependency to your `pubspec.yaml`:
```yaml
dependencies:
  image_picker: ^1.2.3
```

> [!WARNING]
> After adding `image_picker`, you **must completely stop and restart your app** (do not just Hot Reload). If you do not, you will encounter a `MissingPluginException` when trying to open the camera.

## 2. Native Permissions

Add the required permissions to your Android manifest file (`android/app/src/main/AndroidManifest.xml`) so your app is allowed to access the camera and gallery:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Required for camera -->
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" android:required="false" />
    <uses-feature android:name="android.hardware.camera.autofocus" android:required="false" />
    
    <!-- Required for gallery access on older Android versions -->
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
    
    <!-- Required for gallery access on Android 13+ -->
    <uses-permission android:name="android.permission.READ_MEDIA_IMAGES" />
    
    <application ...>
```

## 3. Handling Odoo Image URLs (Emulator Fix)

When Odoo returns a profile image, it often returns a full URL like `http://localhost:8069/web/image/...`.
If you use `NetworkImage(url)` on an Android Emulator, it will fail because the emulator thinks `localhost` means the phone itself. 

Create a smart getter in your model to dynamically rewrite `localhost` to `10.0.2.2` so the emulator can reach your PC's Odoo server:

**`lib/models/user_profile.dart`**
```dart
import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class UserProfile {
  // ... other fields (name, email)
  final String? imageUrl;

  UserProfile({this.imageUrl});

  ImageProvider? get profileImageProvider {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    
    // Check if it's a URL
    if (imageUrl!.startsWith('http') || imageUrl!.startsWith('/')) {
      String finalUrl = imageUrl!;
      
      // Fix host for Android emulators
      if (!kIsWeb && Platform.isAndroid) {
        finalUrl = finalUrl.replaceAll('http://localhost:', 'http://10.0.2.2:');
      }

      return NetworkImage(finalUrl);
    }
    
    // Fallback: If Odoo returned raw Base64 string directly
    try {
      return MemoryImage(base64Decode(imageUrl!.replaceAll('\n', '')));
    } catch (e) {
      return null;
    }
  }
}
```

## 4. Odoo Upload API Method

Create a global function or provider method to compress the image and send it to Odoo using JSON-RPC.

```dart
Future<bool> uploadProfileImage(WidgetRef ref, String base64Image) async {
  final authState = ref.read(authProvider);
  if (authState.token == null) return false;

  String baseUrl = !kIsWeb && Platform.isAndroid ? 'http://10.0.2.2:8069' : 'http://localhost:8069';
  final url = Uri.parse('$baseUrl/api/user/profile/image');
  
  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${authState.token}',
      },
      body: jsonEncode({
        'jsonrpc': '2.0',
        'params': {
          'image': base64Image, // Pass the Base64 string here
        }
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('result') && data['result'] != false) {
        // Invalidate the profile provider so the UI fetches the new image
        ref.invalidate(userProfileProvider);
        return true;
      }
    }
  } catch (e) {
    print('Failed to upload profile image: $e');
  }
  return false;
}
```

## 5. UI: Image Picker & Bottom Sheet

Create a `ConsumerStatefulWidget` to manage the loading state and display the `ImagePicker`.

**`lib/screens/profile_screen.dart`**
```dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// ... other imports

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _pickImage(ImageSource source) async {
    Navigator.pop(context); // Close the bottom sheet
    
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 800, // Compress width
        maxHeight: 800, // Compress height
        imageQuality: 85, // Compress quality
      );

      if (pickedFile != null) {
        setState(() => _isUploading = true);
        
        try {
          // Read bytes and convert to Base64
          final bytes = await pickedFile.readAsBytes();
          final base64Image = base64Encode(bytes);
          
          final success = await uploadProfileImage(ref, base64Image);
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(success ? 'Profile image updated!' : 'Failed to update.'),
                backgroundColor: success ? Colors.green : Colors.red,
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload Error: $e')),
            );
          }
        } finally {
          if (mounted) setState(() => _isUploading = false);
        }
      }
    } catch (e) {
      // Catch native plugin errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e. Try fully stopping and restarting the app.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a photo'),
                onTap: () => _pickImage(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... Fetch profile
    return GestureDetector(
      onTap: _showImageSourceBottomSheet,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: profile.profileImageProvider,
            child: profile.profileImageProvider == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          if (_isUploading)
            const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }
}
```
