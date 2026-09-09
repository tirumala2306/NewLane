import 'package:newlane/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStorage {
  AppStorage(this._preferences);

  final SharedPreferences _preferences;

  Future<bool> saveString(String key, String value) {
    return _preferences.setString(key, value);
  }

  String? readString(String key) {
    return _preferences.getString(key);
  }

  Future<bool> saveInt(String key, int value) {
    return _preferences.setInt(key, value);
  }

  int? readInt(String key) {
    return _preferences.getInt(key);
  }

  Future<bool> remove(String key) {
    return _preferences.remove(key);
  }

  bool get hasAuthToken {
    final String? token = readString(AppConstants.authTokenKey);
    return token != null && token.isNotEmpty;
  }

  /// True after the user finishes or skips onboarding (persists across logout).
  bool get hasCompletedOnboarding {
    return readString(AppConstants.onboardingCompletedKey) == 'true';
  }

  Future<bool> setOnboardingCompleted() {
    return saveString(AppConstants.onboardingCompletedKey, 'true');
  }

  String? get rememberedEmail {
    final String? value = readString(AppConstants.rememberedEmailKey);
    if (value == null || value.trim().isEmpty) return null;
    return value.trim();
  }

  bool get rememberMeEnabled {
    return readString(AppConstants.rememberMeKey) == 'true';
  }

  /// Any persisted user/app data means this is not a fresh install.
  bool get hasLocalUserData {
    if (hasCompletedOnboarding) return true;
    if (hasAuthToken) return true;
    if (rememberedEmail != null) return true;
    if (rememberMeEnabled) return true;
    if (readInt(AppConstants.accessRequestIdKey) != null) return true;
    if (_hasText(AppConstants.accessRequestWorkEmailKey)) return true;
    if (_hasText(AppConstants.accessRequestFullNameKey)) return true;
    if (_hasText(AppConstants.accessRequestPhoneKey)) return true;
    return false;
  }

  bool _hasText(String key) {
    final String? value = readString(key);
    return value != null && value.trim().isNotEmpty;
  }

  /// Backfill the onboarding flag when older installs already have local data.
  Future<void> syncOnboardingFromLocalData() async {
    if (hasLocalUserData && !hasCompletedOnboarding) {
      await setOnboardingCompleted();
    }
  }

  /// Apple-friendly Remember Me: email only — never store the password.
  Future<void> saveRememberMe({
    required bool enabled,
    String? email,
  }) async {
    await saveString(
      AppConstants.rememberMeKey,
      enabled ? 'true' : 'false',
    );
    if (enabled) {
      final String trimmed = (email ?? rememberedEmail ?? '').trim();
      if (trimmed.isNotEmpty) {
        await saveString(AppConstants.rememberedEmailKey, trimmed);
      }
    } else {
      await remove(AppConstants.rememberedEmailKey);
    }
  }

  /// Clears the session token. Keeps Remember Me email and onboarding flag.
  Future<void> clearAuthSession() async {
    await remove(AppConstants.authTokenKey);
  }
}
