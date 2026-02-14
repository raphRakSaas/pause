/// App prédéfinie (scroll) pour l'onboarding.
class PresetApp {
  const PresetApp({required this.packageName, required this.displayName});

  final String packageName;
  final String displayName;
}

/// Liste preset MVP : apps de scroll courantes (Android package names).
const List<PresetApp> presetApps = [
  PresetApp(packageName: 'com.zhiliaoapp.musically', displayName: 'TikTok'),
  PresetApp(packageName: 'com.instagram.android', displayName: 'Instagram'),
  PresetApp(packageName: 'com.google.android.youtube', displayName: 'YouTube'),
  PresetApp(packageName: 'com.facebook.katana', displayName: 'Facebook'),
  PresetApp(packageName: 'com.twitter.android', displayName: 'X (Twitter)'),
  PresetApp(packageName: 'com.reddit.frontpage', displayName: 'Reddit'),
  PresetApp(packageName: 'com.snapchat.android', displayName: 'Snapchat'),
  PresetApp(packageName: 'com.pinterest', displayName: 'Pinterest'),
  PresetApp(packageName: 'com.linkedin.android', displayName: 'LinkedIn'),
];
