import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // 默认设置值
  double _fontSize = 14.0;
  String _colorTheme = 'dark';
  bool _showConnectionInfo = true;
  int _maxRetries = 3;
  
  // 主题选项
  final List<Map<String, dynamic>> _themes = [
    {'name': '深色', 'value': 'dark', 'color': Colors.grey[850]},
    {'name': '浅色', 'value': 'light', 'color': Colors.grey[50]},
    {'name': '蓝色', 'value': 'blue', 'color': Colors.blue[700]},
    {'name': '绿色', 'value': 'green', 'color': Colors.green[700]},
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // 从SharedPreferences加载设置
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _fontSize = prefs.getDouble('fontSize') ?? 14.0;
      _colorTheme = prefs.getString('colorTheme') ?? 'dark';
      _showConnectionInfo = prefs.getBool('showConnectionInfo') ?? true;
      _maxRetries = prefs.getInt('maxRetries') ?? 3;
    });
  }

  // 保存设置到SharedPreferences
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontSize', _fontSize);
    await prefs.setString('colorTheme', _colorTheme);
    await prefs.setBool('showConnectionInfo', _showConnectionInfo);
    await prefs.setInt('maxRetries', _maxRetries);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('设置已保存')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveSettings,
            tooltip: '保存设置',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // 终端外观设置组
          _buildSectionHeader('终端外观'),
          _buildFontSizeSetting(),
          _buildThemeSetting(),
          const Divider(),
          
          // 连接设置组
          _buildSectionHeader('连接设置'),
          _buildConnectionInfoSetting(),
          _buildMaxRetriesSetting(),
          const Divider(),
          
          // 关于应用
          _buildSectionHeader('关于'),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('CrossTerminal'),
            subtitle: const Text('版本 1.0.0'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.0,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildFontSizeSetting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('字体大小: ${_fontSize.toStringAsFixed(1)}'),
              Text('${_fontSize.toStringAsFixed(1)} pt'),
            ],
          ),
        ),
        Slider(
          value: _fontSize,
          min: 8.0,
          max: 24.0,
          divisions: 16,
          label: _fontSize.toStringAsFixed(1),
          onChanged: (value) {
            setState(() {
              _fontSize = value;
            });
          },
        ),
        // 字体大小预览
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(4.0),
          ),
          child: Text(
            'user@host:~\$ echo "Hello, CrossTerminal!"\nHello, CrossTerminal!',
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: _fontSize,
              color: Colors.green[300],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThemeSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('颜色主题'),
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _themes.map((theme) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _colorTheme = theme['value'];
                  });
                },
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: theme['color'],
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: _colorTheme == theme['value']
                          ? Theme.of(context).primaryColor
                          : Colors.transparent,
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      theme['name'],
                      style: TextStyle(
                        color: _colorTheme == theme['value']
                            ? Theme.of(context).primaryColor
                            : (theme['value'] == 'light' ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionInfoSetting() {
    return SwitchListTile(
      title: const Text('显示连接信息'),
      subtitle: const Text('在终端工具栏中显示主机和用户信息'),
      value: _showConnectionInfo,
      onChanged: (value) {
        setState(() {
          _showConnectionInfo = value;
        });
      },
    );
  }

  Widget _buildMaxRetriesSetting() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('最大重试次数'),
                Text('$_maxRetries 次'),
              ],
            ),
          ),
          Slider(
            value: _maxRetries.toDouble(),
            min: 0,
            max: 10,
            divisions: 10,
            label: _maxRetries.toString(),
            onChanged: (value) {
              setState(() {
                _maxRetries = value.toInt();
              });
            },
          ),
        ],
      ),
    );
  }
}