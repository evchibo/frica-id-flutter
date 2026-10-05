import 'package:flutter/material.dart';
import 'package:frica_id_flutter/frica_id_flutter.dart';

void main() {
  runApp(const FricaExampleApp());
}

class FricaExampleApp extends StatelessWidget {
  const FricaExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Frica ID Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF000000),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFCC00),
          surface: Color(0xFF0C0C0C),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FricaClient _client;
  FricaUserInfo? _currentUser;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _client = FricaClient(
      config: const FricaConfig(
        clientId: 'fcli_my_mobile_app',
        redirectUri: 'fricaid://callback',
        defaultScope: 'openid profile email phone',
      ),
    );
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final user = await _client.getStoredUser();
    if (user != null && mounted) {
      setState(() => _currentUser = user);
    }
  }

  Future<void> _handleSignOut() async {
    setState(() => _isLoading = true);
    await _client.signOut();
    if (mounted) {
      setState(() {
        _currentUser = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Frica ID Flutter SDK',
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: _currentUser != null
              ? _buildUserProfileCard()
              : _buildSignInCard(),
        ),
      ),
    );
  }

  Widget _buildSignInCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const FricaLogo(size: 48),
          const SizedBox(height: 16),
          const Text(
            'Sign in with Frica ID',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'One identity for all African digital services and applications.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF888888)),
          ),
          const SizedBox(height: 32),

          // 1. Dark AMOLED Theme (Default)
          FricaSignInButton(
            client: _client,
            theme: FricaButtonTheme.dark,
            size: FricaButtonSize.large,
            onError: (err) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sign in error: $err')),
              );
            },
          ),
          const SizedBox(height: 12),

          // 2. Gold High-Contrast Theme
          FricaSignInButton(
            client: _client,
            theme: FricaButtonTheme.gold,
            size: FricaButtonSize.medium,
          ),
          const SizedBox(height: 12),

          // 3. Clean Light Theme
          FricaSignInButton(
            client: _client,
            theme: FricaButtonTheme.light,
            size: FricaButtonSize.medium,
          ),
        ],
      ),
    );
  }

  Widget _buildUserProfileCard() {
    final user = _currentUser!;
    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      padding: const EdgeInsets.all(28.0),
      decoration: BoxDecoration(
        color: const Color(0xFF0C0C0C),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF222222)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFFFCC00),
                backgroundImage: user.avatarUrl != null
                    ? NetworkImage(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFAAAAAA),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(color: Color(0xFF222222)),
          const SizedBox(height: 12),
          _buildInfoRow('User ID', user.sub),
          _buildInfoRow('Email Verified', user.emailVerified ? 'Yes' : 'No'),
          if (user.phoneNumber != null)
            _buildInfoRow('Phone', user.phoneNumber!),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleSignOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.between,
        children: [
          Text(label, style: const TextStyle(color: Color(0xFF666666), fontSize: 13)),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
