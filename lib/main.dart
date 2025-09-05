import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'dart:convert';
import 'ssh_tab.dart';
import 'settings_page.dart';
import 'pages/connection_dialog.dart';
import 'pages/saved_connections_page.dart';
import 'models/ssh_connection.dart';
import 'services/connection_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CrossTerminal',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
      home: SSHHomePage(),
    );
  }
}

class SSHHomePage extends StatefulWidget {
  const SSHHomePage({super.key});

  @override
  _SSHHomePageState createState() => _SSHHomePageState();
}

class _SSHHomePageState extends State<SSHHomePage> with TickerProviderStateMixin {
  List<Widget> tabs = [];
  List<Widget> tabViews = [];

  final ConnectionService _connectionService = ConnectionService();

  void _addNewTab() async {
    final result = await showDialog(
      context: context,
      builder: (context) => const ConnectionDialog(),
    );
    
    if (result != null && result['connection'] != null) {
      final SSHConnection connection = result['connection'];
      final bool saveConnection = result['save'] ?? false;
      
      // 保存连接到SharedPreferences
      if (saveConnection) {
        await _connectionService.saveConnection(connection);
      }
      
      _connectWithConnection(connection);
    }
  }
  
  void _connectWithSavedConnection(SSHConnection connection) async {
    _connectWithConnection(connection);
  }
  
  void _connectWithConnection(SSHConnection connection) async {
    // 从SharedPreferences加载设置
    final prefs = await SharedPreferences.getInstance();
    final fontSize = prefs.getDouble('fontSize') ?? 14.0;
    final colorTheme = prefs.getString('colorTheme') ?? 'dark';
    final maxRetries = prefs.getInt('maxRetries') ?? 3;
    
    setState(() {
      tabs.add(Tab(text: connection.name));
      tabViews.add(SSHTab(
        host: connection.host,
        port: connection.port,
        username: connection.username,
        password: connection.password,
        useKeyAuth: connection.useKeyAuth,
        privateKeyPath: connection.privateKeyPath,
        fontSize: fontSize,
        theme: colorTheme,
        maxRetryCount: maxRetries,
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text('CrossTerminal', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: Icon(Icons.bookmark),
              tooltip: '已保存的连接',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SavedConnectionsPage()),
                ).then((selectedConnection) {
                  if (selectedConnection != null) {
                    _connectWithSavedConnection(selectedConnection);
                  }
                });
              },
            ),
            IconButton(
              icon: Icon(Icons.settings),
              tooltip: '设置',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                ).then((_) {
                  // 从设置页面返回后刷新UI
                  setState(() {});
                });
              },
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [
              ...tabs,
              Tab(icon: Icon(Icons.add)),
            ],
            onTap: (index) {
              if (index == tabs.length) _addNewTab();
            },
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Theme.of(context).colorScheme.primaryContainer,
            ),
            dividerColor: Colors.transparent,
          ),
        ),
        body: TabBarView(
          children: [
            ...tabViews,
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.terminal, size: 64, color: Theme.of(context).colorScheme.primary),
                  SizedBox(height: 16),
                  Text('点击 + 新建 SSH 连接', style: TextStyle(fontSize: 18)),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    icon: Icon(Icons.add),
                    label: Text('新建连接'),
                    onPressed: _addNewTab,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
