import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ssh_connection.dart';

/// SSH连接管理服务
class ConnectionService {
  static const String _connectionsKey = 'saved_connections';
  
  /// 获取保存的所有SSH连接
  Future<List<SSHConnection>> getAllConnections() async {
    final prefs = await SharedPreferences.getInstance();
    final connectionsJson = prefs.getStringList(_connectionsKey) ?? [];
    
    return connectionsJson
        .map((json) => SSHConnection.fromJson(jsonDecode(json)))
        .toList();
  }
  
  /// 保存SSH连接
  Future<bool> saveConnection(SSHConnection connection) async {
    final prefs = await SharedPreferences.getInstance();
    final connections = await getAllConnections();
    
    // 检查是否已存在相同名称的连接
    final existingIndex = connections.indexWhere((c) => c.name == connection.name);
    
    if (existingIndex >= 0) {
      // 更新现有连接
      connections[existingIndex] = connection;
    } else {
      // 添加新连接
      connections.add(connection);
    }
    
    // 保存到SharedPreferences
    final connectionsJson = connections
        .map((conn) => jsonEncode(conn.toJson()))
        .toList();
    
    return await prefs.setStringList(_connectionsKey, connectionsJson);
  }
  
  /// 删除SSH连接
  Future<bool> deleteConnection(String connectionName) async {
    final prefs = await SharedPreferences.getInstance();
    final connections = await getAllConnections();
    
    connections.removeWhere((c) => c.name == connectionName);
    
    // 保存到SharedPreferences
    final connectionsJson = connections
        .map((conn) => jsonEncode(conn.toJson()))
        .toList();
    
    return await prefs.setStringList(_connectionsKey, connectionsJson);
  }
  
  /// 清除所有保存的连接
  Future<bool> clearAllConnections() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.remove(_connectionsKey);
  }
  
  /// 兼容旧版API
  static Future<List<SSHConnection>> getSavedConnections() async {
    return ConnectionService().getAllConnections();
  }
  
  /// 兼容旧版API - 使用不同名称避免与实例方法冲突
  static Future<bool> staticDeleteConnection(SSHConnection connection) async {
    return ConnectionService().deleteConnection(connection.name);
  }
}