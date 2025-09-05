# CrossTerminal

一个基于Flutter开发的跨平台SSH终端模拟器，支持多平台运行，提供现代化的用户界面和丰富的终端功能。

## 功能特性

### 🔐 SSH连接支持
- **密码认证**：支持用户名/密码登录
- **SSH密钥认证**：支持私钥文件认证
- **连接管理**：保存和管理常用SSH连接
- **多标签页**：同时管理多个SSH会话

### 💻 终端功能
- **完整的终端模拟**：基于xterm.dart实现
- **复制粘贴**：支持文本选择和剪贴板操作
- **字体调整**：可调节终端字体大小
- **主题支持**：现代化的终端主题
- **硬件键盘优化**：针对桌面平台优化的键盘输入

### 🎨 用户界面
- **现代化设计**：Material Design风格界面
- **响应式布局**：适配不同屏幕尺寸
- **直观操作**：简洁易用的连接管理界面
- **状态指示**：清晰的连接状态显示

### 🌍 跨平台支持
- **macOS**：原生macOS应用
- **Windows**：Windows桌面应用
- **Linux**：Linux桌面应用
- **iOS/Android**：移动端支持（待完善）

## 技术栈

- **Flutter**: 跨平台UI框架
- **Dart**: 编程语言
- **dartssh2**: SSH协议实现
- **xterm**: 终端模拟器核心
- **shared_preferences**: 本地数据存储
- **file_picker**: 文件选择器

## 安装和运行

### 环境要求

- Flutter SDK >= 3.0.0
- Dart SDK >= 2.17.0
- 对应平台的开发环境（Xcode for macOS, Visual Studio for Windows等）

### 克隆项目

```bash
git clone https://github.com/yourusername/CrossTerminal.git
cd CrossTerminal/crossterminal
```

### 安装依赖

```bash
flutter pub get
```

### 运行应用

```bash
# macOS
flutter run -d macos

# Windows
flutter run -d windows

# Linux
flutter run -d linux
```

### 构建发布版本

```bash
# macOS
flutter build macos --release

# Windows
flutter build windows --release

# Linux
flutter build linux --release
```

## 使用说明

### 创建SSH连接

1. 点击主界面的"新建连接"按钮
2. 填写连接信息：
   - 主机地址
   - 端口号（默认22）
   - 用户名
   - 选择认证方式（密码或密钥）
3. 点击"连接"开始SSH会话

### 终端操作

- **复制文本**：选择文本后右键复制
- **粘贴文本**：右键粘贴或使用快捷键
- **调整字体**：使用工具栏的字体大小按钮
- **新建标签页**：点击"+"按钮创建新的SSH会话

### 连接管理

- **保存连接**：勾选"保存连接"选项
- **管理连接**：在"已保存连接"页面查看和编辑
- **快速连接**：从保存的连接列表快速启动会话

## 项目结构

```
lib/
├── main.dart                 # 应用入口
├── models/
│   └── ssh_connection.dart   # SSH连接数据模型
├── pages/
│   ├── connection_dialog.dart # 连接配置对话框
│   └── saved_connections_page.dart # 保存的连接页面
├── services/
│   └── connection_service.dart # 连接管理服务
├── settings_page.dart        # 设置页面
└── ssh_tab.dart             # SSH终端标签页
```

## 开发计划

- [ ] 添加更多终端主题
- [ ] 支持SFTP文件传输
- [ ] 添加端口转发功能
- [ ] 改进移动端体验
- [ ] 添加脚本自动化功能
- [ ] 支持多语言界面

## 贡献指南

欢迎提交Issue和Pull Request来帮助改进项目！

### 开发环境设置

1. Fork本项目
2. 创建功能分支：`git checkout -b feature/your-feature`
3. 提交更改：`git commit -am 'Add some feature'`
4. 推送分支：`git push origin feature/your-feature`
5. 创建Pull Request

## 许可证

本项目采用MIT许可证 - 查看[LICENSE](LICENSE)文件了解详情。

## 致谢

- [xterm.dart](https://github.com/TerminalStudio/xterm.dart) - 优秀的Flutter终端模拟器
- [dartssh2](https://github.com/TerminalStudio/dartssh2) - Dart SSH客户端实现
- Flutter团队提供的跨平台框架

## 联系方式

如有问题或建议，请通过以下方式联系：

- 提交Issue：[GitHub Issues](https://github.com/yourusername/CrossTerminal/issues)
- 邮箱：your.email@example.com

---

**CrossTerminal** - 让SSH连接更简单、更现代化！
