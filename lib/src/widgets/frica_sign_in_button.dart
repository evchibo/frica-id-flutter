import 'package:flutter/material.dart';
import '../frica_client.dart';
import '../models/token_response.dart';
import 'frica_logo.dart';

enum FricaButtonTheme {
  /// Pure AMOLED black button with glowing gold icon and white text.
  dark,

  /// Clean light card with subtle border and dark text.
  light,

  /// High-contrast Frica Gold button with pure black text.
  gold,
}

enum FricaButtonSize {
  small,
  medium,
  large,
}

/// Official "Sign in with Frica ID" branded widget for Flutter apps.
class FricaSignInButton extends StatefulWidget {
  final FricaClient client;
  final FricaButtonTheme theme;
  final FricaButtonSize size;
  final String text;
  final String? scope;
  final ValueChanged<FricaTokenResponse>? onSuccess;
  final ValueChanged<Object>? onError;
  final VoidCallback? onLoading;
  final bool enabled;

  const FricaSignInButton({
    super.key,
    required this.client,
    this.theme = FricaButtonTheme.dark,
    this.size = FricaButtonSize.medium,
    this.text = 'Sign in with Frica ID',
    this.scope,
    this.onSuccess,
    this.onError,
    this.onLoading,
    this.enabled = true,
  });

  @override
  State<FricaSignInButton> createState() => _FricaSignInButtonState();
}

class _FricaSignInButtonState extends State<FricaSignInButton> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    if (!widget.enabled || _isLoading) return;

    setState(() => _isLoading = true);
    widget.onLoading?.call();

    try {
      final launched = await widget.client.signIn(scope: widget.scope);
      if (!launched) {
        throw Exception('Could not launch authorization URL');
      }
    } catch (e) {
      widget.onError?.call(e);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final (height, fontSize, logoSize, hPadding) = switch (widget.size) {
      FricaButtonSize.small => (36.0, 12.5, 18.0, 12.0),
      FricaButtonSize.medium => (46.0, 14.0, 22.0, 16.0),
      FricaButtonSize.large => (54.0, 15.5, 26.0, 20.0),
    };

    final (bgColor, textColor, borderColor, logoMarkColor) = switch (widget.theme) {
      FricaButtonTheme.dark => (
          Colors.black,
          Colors.white,
          const Color(0xFF282828),
          const Color(0xFFFFCC00),
        ),
      FricaButtonTheme.light => (
          Colors.white,
          Colors.black,
          const Color(0xFFE5E7EB),
          const Color(0xFFD97706),
        ),
      FricaButtonTheme.gold => (
          const Color(0xFFFFCC00),
          Colors.black,
          const Color(0xFFE6B800),
          Colors.black,
        ),
    };

    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: widget.enabled && !_isLoading ? _handleSignIn : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: widget.theme == FricaButtonTheme.gold ? 2 : 0,
          padding: EdgeInsets.symmetric(horizontal: hPadding),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor, width: 1),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                width: logoSize,
                height: logoSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    widget.theme == FricaButtonTheme.gold ? Colors.black : const Color(0xFFFFCC00),
                  ),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FricaLogo(
                    size: logoSize,
                    backgroundColor: widget.theme == FricaButtonTheme.gold
                        ? Colors.black
                        : (widget.theme == FricaButtonTheme.light ? Colors.black : Colors.black),
                    markColor: const Color(0xFFFFCC00),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
