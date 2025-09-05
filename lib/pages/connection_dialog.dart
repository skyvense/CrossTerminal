import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import '../models/ssh_connection.dart';

class ConnectionDialog extends StatefulWidget {
  final SSHConnection? initialConnection;

  const ConnectionDialog({Key? key, this.initialConnection}) : super(key: key);

  @override
  _ConnectionDialogState createState() => _ConnectionDialogState();
}

class _ConnectionDialogState extends State<ConnectionDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hostController = TextEditingController();
  final TextEditingController _portController = TextEditingController(text: '22');
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  String _privateKeyPath = '';
  bool _useKeyAuth = false;
  bool _saveConnection = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialConnection != null) {
      _hostController.text = widget.initialConnection!.host;
      _portController.text = widget.initialConnection!.port.toString();
      _usernameController.text = widget.initialConnection!.username;
      _passwordController.text = widget.initialConnection!.password;
      _privateKeyPath = widget.initialConnection!.privateKeyPath;
      _useKeyAuth = widget.initialConnection!.useKeyAuth;
      _nameController.text = widget.initialConnection!.name;
      _saveConnection = true;
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickKeyFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _privateKeyPath = result.files.first.path!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialConnection != null ? '编辑连接' : '新建SSH连接'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 连接名称
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: '连接名称（可选）',
                  hintText: '输入一个易记的名称',
                  prefixIcon: Icon(Icons.bookmark),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              
              // 主机地址
              TextFormField(
                controller: _hostController,
                decoration: const InputDecoration(
                  labelText: '主机地址 *',
                  hintText: '例如: example.com 或 192.168.1.1',
                  prefixIcon: Icon(Icons.computer),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入主机地址';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 端口
              TextFormField(
                controller: _portController,
                decoration: const InputDecoration(
                  labelText: '端口 *',
                  hintText: '默认: 22',
                  prefixIcon: Icon(Icons.settings_ethernet),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入端口';
                  }
                  final port = int.tryParse(value);
                  if (port == null || port <= 0 || port > 65535) {
                    return '请输入有效的端口号 (1-65535)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 用户名
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: '用户名 *',
                  hintText: '例如: root 或 admin',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '请输入用户名';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // 认证方式选择
              SwitchListTile(
                title: const Text('使用SSH密钥认证'),
                subtitle: const Text('切换使用密码或密钥文件认证'),
                value: _useKeyAuth,
                activeColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _useKeyAuth = value;
                  });
                },
              ),
              const SizedBox(height: 8),
              
              // 根据认证方式显示不同的输入框
              if (_useKeyAuth)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _privateKeyPath.isEmpty
                                  ? '未选择密钥文件'
                                  : _privateKeyPath,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.file_open),
                          label: const Text('选择'),
                          onPressed: _pickKeyFile,
                        ),
                      ],
                    ),
                    if (_useKeyAuth && _privateKeyPath.isEmpty)
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, left: 12.0),
                        child: Text(
                          '请选择SSH密钥文件',
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                )
              else
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: '密码 *',
                    hintText: '输入SSH密码',
                    prefixIcon: Icon(Icons.lock),
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: (value) {
                    if (!_useKeyAuth && (value == null || value.isEmpty)) {
                      return '请输入密码';
                    }
                    return null;
                  },
                ),
              const SizedBox(height: 16),
              
              // 保存连接选项
              SwitchListTile(
                title: const Text('保存连接'),
                subtitle: const Text('保存此连接以便下次使用'),
                value: _saveConnection,
                activeColor: Theme.of(context).primaryColor,
                contentPadding: EdgeInsets.zero,
                onChanged: (value) {
                  setState(() {
                    _saveConnection = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              if (_useKeyAuth && _privateKeyPath.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('请选择SSH密钥文件')),
                );
                return;
              }
              
              final connection = SSHConnection(
                host: _hostController.text,
                port: int.parse(_portController.text),
                username: _usernameController.text,
                password: _passwordController.text,
                useKeyAuth: _useKeyAuth,
                privateKeyPath: _privateKeyPath,
                name: _nameController.text.isNotEmpty
                    ? _nameController.text
                    : '${_usernameController.text}@${_hostController.text}',
              );
              
              Navigator.pop(context, {
                'connection': connection,
                'save': _saveConnection,
              });
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
          ),
          child: const Text('连接'),
        ),
      ],
    );
  }
}