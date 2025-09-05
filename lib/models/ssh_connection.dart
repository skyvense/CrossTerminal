import 'package:flutter/foundation.dart';

/// SSH连接配置模型类
class SSHConnection {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useKeyAuth;
  final String privateKeyPath;
  final String name;
  
  /// 创建一个SSH连接配置
  const SSHConnection({
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.useKeyAuth = false,
    this.privateKeyPath = '',
    String? name,
  }) : name = name ?? '$username@$host';
  
  /// 从JSON创建SSH连接配置
  factory SSHConnection.fromJson(Map<String, dynamic> json) {
    return SSHConnection(
      host: json['host'] as String,
      port: json['port'] as int,
      username: json['username'] as String,
      password: json['password'] as String,
      useKeyAuth: json['useKeyAuth'] as bool,
      privateKeyPath: json['privateKeyPath'] as String,
      name: json['name'] as String?,
    );
  }
  
  /// 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'username': username,
      'password': password,
      'useKeyAuth': useKeyAuth,
      'privateKeyPath': privateKeyPath,
      'name': name,
    };
  }
  
  /// 创建一个新的SSH连接配置，并覆盖指定的属性
  SSHConnection copyWith({
    String? host,
    int? port,
    String? username,
    String? password,
    bool? useKeyAuth,
    String? privateKeyPath,
    String? name,
  }) {
    return SSHConnection(
      host: host ?? this.host,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      useKeyAuth: useKeyAuth ?? this.useKeyAuth,
      privateKeyPath: privateKeyPath ?? this.privateKeyPath,
      name: name ?? this.name,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is SSHConnection &&
        other.host == host &&
        other.port == port &&
        other.username == username &&
        other.useKeyAuth == useKeyAuth &&
        other.privateKeyPath == privateKeyPath &&
        other.name == name;
  }
  
  @override
  int get hashCode {
    return host.hashCode ^
        port.hashCode ^
        username.hashCode ^
        useKeyAuth.hashCode ^
        privateKeyPath.hashCode ^
        name.hashCode;
  }
  
  @override
  String toString() => 'SSHConnection($name: $username@$host:$port)';
}