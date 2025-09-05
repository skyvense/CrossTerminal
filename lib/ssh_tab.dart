import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dartssh2/dartssh2.dart';
import 'package:xterm/xterm.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'dart:async';

class SSHTab extends StatefulWidget {
  final String host;
  final int port;
  final String username;
  final String password;
  final bool useKeyAuth;
  final String privateKeyPath;
  final double fontSize;
  final String theme;
  final int maxRetryCount;

  const SSHTab({
    super.key, 
    required this.host,
    required this.port,
    required this.username,
    required this.password,
    this.useKeyAuth = false,
    this.privateKeyPath = '',
    this.fontSize = 14.0,
    this.theme = 'dark',
    this.maxRetryCount = 3,
  });

  @override
  _SSHTabState createState() => _SSHTabState();
}

// 终端主题配置
class TerminalTheme {
  final Color backgroundColor;
  final Color foregroundColor;
  final Color cursorColor;
  final Color selectionColor;
  
  const TerminalTheme({
    required this.backgroundColor,
    required this.foregroundColor,
    required this.cursorColor,
    required this.selectionColor,
  });
  
  // 预定义主题
  static const TerminalTheme dark = TerminalTheme(
    backgroundColor: Color(0xFF1E1E1E),
    foregroundColor: Color(0xFFE0E0E0),
    cursorColor: Color(0xFFAEAFAD),
    selectionColor: Color(0xFF264F78),
  );
  
  static const TerminalTheme light = TerminalTheme(
    backgroundColor: Color(0xFFF5F5F5),
    foregroundColor: Color(0xFF333333),
    cursorColor: Color(0xFF585858),
    selectionColor: Color(0xFFADD6FF),
  );
  
  static const TerminalTheme blue = TerminalTheme(
    backgroundColor: Color(0xFF0D2E4A),
    foregroundColor: Color(0xFFE0E0E0),
    cursorColor: Color(0xFF4DA6FF),
    selectionColor: Color(0xFF264F78),
  );
  
  static const TerminalTheme green = TerminalTheme(
    backgroundColor: Color(0xFF0A2F0A),
    foregroundColor: Color(0xFFE0E0E0),
    cursorColor: Color(0xFF4CAF50),
    selectionColor: Color(0xFF2E7D32),
  );
  
  // 根据主题名称获取主题
  static TerminalTheme fromName(String name) {
    switch (name) {
      case 'light':
        return light;
      case 'blue':
        return blue;
      case 'green':
        return green;
      case 'dark':
      default:
        return dark;
    }
  }
}

class _SSHTabState extends State<SSHTab> {
  SSHClient? client;
  dynamic channel;
  bool connecting = true;
  bool connectionFailed = false;
  String errorMessage = '';
  int retryCount = 0;
  late int maxRetries;
  late Terminal terminal;
  late TerminalController terminalController;
  late double fontSize;
  late TerminalTheme terminalTheme;
  late bool showConnectionInfo;
  
  // 用于复制粘贴的控制器
  final TextEditingController _pasteController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  // 从SharedPreferences加载设置
  Future<void> _loadSettings() async {
    // 初始化设置
    fontSize = widget.fontSize;
    terminalTheme = TerminalTheme.fromName(widget.theme);
    showConnectionInfo = true;
    maxRetries = widget.maxRetryCount;
    
    // 初始化终端并应用设置
    terminal = Terminal(maxLines: 10000);
    terminalController = TerminalController();
    _applyTerminalSettings();
    
    // 加载设置后开始连接
    _connect();
  }
  
  // 应用终端设置
  void _applyTerminalSettings() {
    // 注意：xterm 3.4.0 版本可能不支持这些方法
    // 主题设置将通过 TerminalView 的 theme 参数处理
  }

  // 初始化方法已在上面重写

  void _connect() async {
    setState(() {
      connecting = true;
      connectionFailed = false;
      errorMessage = '';
    });
    
    try {
      terminal.write('正在连接到 ${widget.host}:${widget.port}...\r\n');
      
      final socket = await SSHSocket.connect(
        widget.host, 
        widget.port,
      ).timeout(Duration(seconds: 10), onTimeout: () {
        throw TimeoutException('连接超时，请检查网络或主机地址');
      });
      
      terminal.write('已建立连接，正在进行认证...\r\n');
      
      if (widget.useKeyAuth && widget.privateKeyPath.isNotEmpty) {
        // 使用SSH密钥认证
        final keyFile = File(widget.privateKeyPath);
        if (!await keyFile.exists()) {
          throw FileSystemException('密钥文件不存在: ${widget.privateKeyPath}');
        }
        
        try {
          final keyData = await keyFile.readAsString();
          final keyPairs = SSHKeyPair.fromPem(keyData);
          client = SSHClient(
            socket,
            username: widget.username,
            identities: keyPairs,
          );
        } catch (e) {
          throw Exception('读取或解析密钥文件失败: $e');
        }
      } else {
        // 使用密码认证
        client = SSHClient(
          socket,
          username: widget.username,
          onPasswordRequest: () => widget.password,
        );
      }
      
      terminal.write('认证成功，正在启动终端...\r\n');
      
      try {
        channel = await client!.shell();
      } catch (e) {
        throw Exception('启动Shell失败: $e');
      }

      channel!.stdout.listen(
        (data) {
          terminal.write(String.fromCharCodes(data));
        },
        onError: (error) {
          terminal.write('\r\n输出流错误: $error\r\n');
        },
      );
      
      channel!.stderr.listen(
        (data) {
          terminal.write(String.fromCharCodes(data));
        },
        onError: (error) {
          terminal.write('\r\n错误流错误: $error\r\n');
        },
      );

      terminal.onOutput = (data) {
        try {
          channel!.write(Uint8List.fromList(utf8.encode(data)));
        } catch (e) {
          terminal.write('\r\n发送数据失败: $e\r\n');
        }
      };

      // 处理终端尺寸变化
      terminal.onResize = (width, height, pixelWidth, pixelHeight) {
        try {
          // 通知SSH服务器调整远程终端尺寸
          channel?.resizeTerminal(width, height, pixelWidth, pixelHeight);
        } catch (e) {
          terminal.write('\r\n调整终端尺寸失败: $e\r\n');
        }
      };

      // 初始化时设置终端尺寸
      try {
        channel?.resizeTerminal(
          terminal.viewWidth, 
          terminal.viewHeight, 
          terminal.viewWidth * 8, // 估算像素宽度
          terminal.viewHeight * 16 // 估算像素高度
        );
      } catch (e) {
        terminal.write('\r\n设置初始终端尺寸失败: $e\r\n');
      }

      setState(() {
        connecting = false;
        retryCount = 0; // 重置重试计数
      });
      terminal.write('\r\n连接成功! 欢迎使用 CrossTerminal\r\n');
    } catch (e) {
      String errorMsg = '连接失败: $e';
      terminal.write('$errorMsg\r\n');
      
      if (retryCount < widget.maxRetryCount) {
        retryCount++;
        terminal.write('正在尝试重新连接 (${retryCount}/${widget.maxRetryCount})...\r\n');
        
        // 延迟与重试次数相关的时间后重试
        Future.delayed(Duration(seconds: widget.maxRetryCount - retryCount + 1), () {
          if (mounted) {
            _connect();
          }
        });
      } else {
        setState(() {
          connecting = false;
          connectionFailed = true;
          errorMessage = errorMsg;
          retryCount = 0; // 重置重试计数
        });
        terminal.write('\r\n连接失败，已达到最大重试次数 (${widget.maxRetryCount})\r\n');
      }
    }
  }

  @override
  void dispose() {
    channel?.close();
    client?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (connecting) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在连接到 ${widget.host}...'),
            if (retryCount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text('重试次数: $retryCount/$maxRetries', 
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      );
    }
    
    if (connectionFailed) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
            SizedBox(height: 16),
            Text('连接失败', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(errorMessage, textAlign: TextAlign.center),
            ),
            SizedBox(height: 24),
            ElevatedButton.icon(
              icon: Icon(Icons.refresh),
              label: Text('重新连接'),
              onPressed: () {
                retryCount = 0;
                _connect();
              },
            ),
          ],
        ),
      );
    }
    
    return Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                color: terminalTheme.backgroundColor,
                child: Row(
                  children: [
                    Text(
                      '${widget.username}@${widget.host}:${widget.port}',
                      style: TextStyle(color: terminalTheme.foregroundColor, fontWeight: FontWeight.bold),
                    ),
                    Spacer(),
                    // 字体大小调整按钮
                    IconButton(
                      icon: Icon(Icons.text_decrease, color: terminalTheme.foregroundColor),
                      tooltip: '减小字体',
                      onPressed: () {
                        setState(() {
                          if (fontSize > 8.0) {
                            fontSize -= 1.0;
                          }
                        });
                      },
                    ),
                    Text(
                      '${fontSize.toInt()}',
                      style: TextStyle(color: terminalTheme.foregroundColor),
                    ),
                    IconButton(
                      icon: Icon(Icons.text_increase, color: terminalTheme.foregroundColor),
                      tooltip: '增大字体',
                      onPressed: () {
                        setState(() {
                          if (fontSize < 24.0) {
                            fontSize += 1.0;
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.content_copy, color: terminalTheme.foregroundColor),
                      tooltip: '复制选中内容',
                      onPressed: () {
                        final selection = terminalController.selection;
                        if (selection != null) {
                          final text = terminal.buffer.getText(selection);
                          terminalController.clearSelection();
                          Clipboard.setData(ClipboardData(text: text));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已复制到剪贴板')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('请先选择文本')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.paste, color: terminalTheme.foregroundColor),
                      tooltip: '粘贴',
                      onPressed: () async {
                        final data = await Clipboard.getData('text/plain');
                        if (data != null && data.text != null) {
                          terminal.paste(data.text!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('已粘贴文本')),
                          );
                        }
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.refresh, color: terminalTheme.foregroundColor),
                      tooltip: '重新连接',
                      onPressed: () {
                        setState(() {
                          connecting = true;
                        });
                        channel?.close();
                        client?.close();
                        _connect();
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: terminalTheme.backgroundColor,
                    border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  margin: EdgeInsets.all(8),
                  clipBehavior: Clip.antiAlias,
                  child: TerminalView(
                    terminal,
                    controller: terminalController,
                    autofocus: true,
                    hardwareKeyboardOnly: true,
                    textStyle: TerminalStyle(
                      fontSize: fontSize,
                    ),
                  ),
                ),
              ),
            ],
          );
  }
}