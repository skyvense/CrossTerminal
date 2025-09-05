import 'package:flutter/material.dart';
import '../models/ssh_connection.dart';
import '../services/connection_service.dart';
import 'connection_dialog.dart';

class SavedConnectionsPage extends StatefulWidget {
  const SavedConnectionsPage({Key? key}) : super(key: key);

  @override
  _SavedConnectionsPageState createState() => _SavedConnectionsPageState();
}

class _SavedConnectionsPageState extends State<SavedConnectionsPage> {
  List<SSHConnection> _connections = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  final ConnectionService _connectionService = ConnectionService();

  Future<void> _loadConnections() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final connections = await _connectionService.getAllConnections();
      setState(() {
        _connections = connections;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载连接失败: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteConnection(SSHConnection connection) async {
    try {
      await _connectionService.deleteConnection(connection.name);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已删除连接: ${connection.name}')),
      );
      _loadConnections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('删除连接失败: $e')),
      );
    }
  }
  
  Future<void> _editConnection(SSHConnection connection) async {
    final result = await showDialog(
      context: context,
      builder: (context) => ConnectionDialog(initialConnection: connection),
    );
    
    if (result != null && result['connection'] != null) {
      final SSHConnection updatedConnection = result['connection'];
      final bool saveConnection = result['save'] ?? false;
      
      if (saveConnection) {
        await _connectionService.saveConnection(updatedConnection);
        _loadConnections();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('已保存的连接'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadConnections,
            tooltip: '刷新',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _connections.isEmpty
              ? _buildEmptyState()
              : _buildConnectionsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            '没有保存的连接',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('连接后可以保存常用的SSH连接'),
        ],
      ),
    );
  }

  Widget _buildConnectionsList() {
    return ListView.builder(
      itemCount: _connections.length,
      padding: const EdgeInsets.all(8.0),
      itemBuilder: (context, index) {
        final connection = _connections[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 4.0),
          child: ListTile(
            leading: Icon(
              connection.useKeyAuth ? Icons.key : Icons.password,
              color: Theme.of(context).primaryColor,
            ),
            title: Text(connection.name),
            subtitle: Text('${connection.username}@${connection.host}:${connection.port}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.connect_without_contact),
                  tooltip: '连接',
                  onPressed: () {
                    Navigator.pop(context, connection);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: '编辑',
                  onPressed: () => _editConnection(connection),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: '删除',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('删除连接'),
                        content: Text('确定要删除连接 "${connection.name}" 吗？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('取消'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _deleteConnection(connection);
                            },
                            child: const Text('删除'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
            onTap: () {
              Navigator.pop(context, connection);
            },
          ),
        );
      },
    );
  }
}