class AppConfig {
  static const apiPort = 3000;

  /// Prefer the PC Wi‑Fi LAN IP so a physical phone can reach Nest.
  /// ApiService probes hosts in order until /health responds.
  static const apiHosts = [
    'http://192.168.118.171:3000',
    'http://127.0.0.1:3000',
    'http://10.0.2.2:3000', // Android emulator → host machine
    'http://192.168.137.52:3000',
    'http://192.168.137.1:3000',
    'http://192.168.20.93:3000',
    'http://192.168.5.1:3000',
  ];
}
