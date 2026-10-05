# frica_id_flutter

The official Flutter SDK for **Sign in with Frica ID**. Implements OAuth 2.1 with PKCE, user authentication, session token refresh, and ready-to-use Flutter UI widgets.

[![pub package](https://img.shields.io/pub/v/frica_id_flutter.svg)](https://pub.dev/packages/frica_id_flutter)
[![License](https://img.shields.io/badge/license-Apache--2.0-blue.svg)](LICENSE)

---

## Features

- 🔐 **OAuth 2.1 PKCE by Default:** Secure authorization flow (RFC 7636). Client secrets are never embedded in mobile code.
- 📱 **Cross-Platform:** Supports iOS, Android, and Web with deep link redirect callbacks.
- 🎨 **Official Branded Widgets:** Pre-styled `FricaSignInButton` with AMOLED pure black (`#000000`) and Frica Gold (`#FFCC00`).
- 🔄 **Token Lifecycle:** Built-in token exchange, automatic refresh token rotation, and in-memory or secure storage.

---

## Installation

Add `frica_id_flutter` to your `pubspec.yaml`:

```yaml
dependencies:
  frica_id_flutter: ^1.0.0
```

Then run:
```bash
flutter pub get
```

---

## Platform Setup

### 1. Android Configuration

Open `android/app/src/main/AndroidManifest.xml` and add an `<intent-filter>` inside your `<activity android:name=".MainActivity">` to capture the redirect URI callback:

```xml
<activity
    android:name=".MainActivity"
    android:launchMode="singleTask"
    android:exported="true">

    <!-- Deep linking callback for Frica ID -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <!-- Scheme and host should match your Frica ID Developer Console redirect URI -->
        <data android:scheme="myapp" android:host="oauth-callback" />
    </intent-filter>
</activity>
```

### 2. iOS Configuration

Open `ios/Runner/Info.plist` and register your custom URL scheme:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>myapp</string>
        </array>
    </dict>
</array>
```

---

## Quickstart

### Step 1: Initialize the FricaClient

```dart
import 'package:flutter/material.dart';
import 'package:frica_id_flutter/frica_id_flutter.dart';

final fricaClient = FricaClient(
  config: const FricaConfig(
    clientId: 'fcli_my_mobile_app', // From https://frica.id/dashboard/developer
    redirectUri: 'myapp://oauth-callback',
    defaultScope: 'openid profile email phone',
  ),
);
```

### Step 2: Add the `FricaSignInButton`

```dart
import 'package:flutter/material.dart';
import 'package:frica_id_flutter/frica_id_flutter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dark AMOLED Theme (Default)
            FricaSignInButton(
              client: fricaClient,
              theme: FricaButtonTheme.dark,
              size: FricaButtonSize.large,
              onError: (err) => print('Login error: $err'),
            ),
            const SizedBox(height: 12),

            // Gold Theme
            FricaSignInButton(
              client: fricaClient,
              theme: FricaButtonTheme.gold,
              size: FricaButtonSize.medium,
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 3: Handle the Deep Link Callback

Using standard Flutter `app_links` or `uni_links`:

```dart
import 'package:app_links/app_links.dart';

void listenToAuthCallbacks(FricaClient client) {
  final appLinks = AppLinks();
  appLinks.uriLinkStream.listen((uri) async {
    if (uri.scheme == 'myapp' && uri.host == 'oauth-callback') {
      try {
        final tokens = await client.handleRedirectUri(uri);
        final user = await client.getUserInfo();
        print('Authenticated as ${user.name} (${user.email})');
      } catch (e) {
        print('Failed to complete login: $e');
      }
    }
  });
}
```

---

## API Reference

### `FricaClient` Methods

| Method | Returns | Description |
| :--- | :--- | :--- |
| `signIn()` | `Future<bool>` | Opens the Frica ID authorization page in system browser |
| `handleRedirectUri(Uri uri)` | `Future<FricaTokenResponse>` | Exchanges authorization code for access and refresh tokens |
| `getUserInfo()` | `Future<FricaUserInfo>` | Retrieves the authenticated user profile |
| `getValidAccessToken()` | `Future<String?>` | Returns a valid access token, auto-refreshing if expired |
| `refreshToken()` | `Future<FricaTokenResponse>` | Refreshes the session using the refresh token |
| `signOut()` | `Future<void>` | Revokes tokens and clears session storage |
| `isAuthenticated()` | `Future<bool>` | Checks if an active session exists |

---

## License

Apache-2.0 © Frica ID Team
