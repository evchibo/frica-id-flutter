# Changelog

## 1.0.3

- Robust response payload unpacking: seamlessly support both standard RFC OAuth responses and nested envelopes.
- Graceful non-blocking user profile caching on authorization code redirect callbacks.
- Whitespace trimming and safety checks on Bearer access tokens before `/oauth/userinfo` retrieval.

## 1.0.2

- Enhance error message when fetching user profile to include full HTTP status code and response payload.

## 1.0.1

- Fix type cast error (`type 'Null' is not a subtype of 'String' in type cast`) when parsing user profile claims and token responses with optional fields.
- Robust parsing for `sub`, `name`, `email`, and `phoneNumber`.

## 1.0.0

- Initial release of `frica_id_flutter`.
- Official OAuth 2.1 Authorization Code Flow with PKCE (RFC 7636).
- Built-in `FricaSignInButton` Widget with AMOLED pure black and Frica Gold styling.
- Secure token exchange and refresh lifecycle management.
- User profile retrieval and deep link integration for iOS, Android, and Web.
