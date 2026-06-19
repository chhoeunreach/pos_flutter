class ServerPreset {
  final String name;
  final String url;
  final String description;

  const ServerPreset({
    required this.name,
    required this.url,
    required this.description,
  });
}

class ServerPresets {
  static const List<ServerPreset> all = [
    ServerPreset(
      name: 'systeme',
      url: 'http://systems.kneayerng.com/api/mobile',
      description: 'systems.kneayerng.com',
    ),
    ServerPreset(
      name: 'local',
      url: 'http://127.0.0.1:8000/api/mobile',
      description: '127.0.0.1:8000',
    ),
    ServerPreset(
      name: 'ar',
      url: 'https://ar.kneayerng.com/api/mobile',
      description: 'ar.kneayerng.com',
    ),
  ];

  static ServerPreset? match(String? url) {
    final cleanUrl = _clean(url);
    if (cleanUrl == null) return null;
    for (final preset in all) {
      if (_clean(preset.url) == cleanUrl) return preset;
    }
    return null;
  }

  static String displayName(String? url) {
    final preset = match(url);
    if (preset != null) return preset.name;
    return url == null || url.trim().isEmpty ? 'Not selected' : 'Custom';
  }

  static String? _clean(String? url) {
    if (url == null) return null;
    var value = url.trim();
    if (value.endsWith('/')) value = value.substring(0, value.length - 1);
    return value.toLowerCase();
  }
}
