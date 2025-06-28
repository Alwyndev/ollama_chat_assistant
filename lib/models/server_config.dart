class ServerConfig {
  final String ip;
  final String port;

  ServerConfig({required this.ip, required this.port});

  String get baseUrl => 'http://$ip:$port';

  ServerConfig copyWith({String? ip, String? port}) {
    return ServerConfig(ip: ip ?? this.ip, port: port ?? this.port);
  }
}
