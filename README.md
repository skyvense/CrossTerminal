# CrossTerminal

一个功能强大的跨平台SSH终端客户端，基于Flutter构建，支持多标签页、SSH密钥认证和自定义终端设置。

## 功能特点

- **多标签页支持**：在一个窗口中管理多个SSH连接
- **SSH认证方式**：支持密码认证和SSH密钥认证
- **自定义终端设置**：可调整字体大小、颜色主题等
- **复制粘贴支持**：方便的文本操作
- **连接管理**：自动重试连接、详细的错误信息显示
- **现代化UI**：美观易用的界面设计

## 安装

### 依赖项

确保你已安装以下依赖：

```yaml
dependencies:
  flutter:
    sdk: flutter
  dartssh2: ^2.8.2
  xterm: ^3.5.0
  file_picker: ^6.1.1
  shared_preferences: ^2.2.2
```

### 构建和运行

```bash
# 获取依赖
flutter pub get

# 运行应用
flutter run
```

## 使用指南

### 创建新连接

1. 点击界面中的"新建连接"按钮
2. 输入SSH连接信息：
   - 主机地址
   - 端口（默认22）
   - 用户名
   - 认证方式（密码或SSH密钥）
   - 密码或选择SSH密钥文件
3. 点击"连接"按钮

### 终端操作

- **复制文本**：选中文本后点击工具栏中的复制按钮
- **粘贴文本**：点击工具栏中的粘贴按钮
- **调整字体大小**：使用工具栏中的字体大小调整按钮
- **重新连接**：点击工具栏中的刷新按钮

### 自定义设置

点击应用右上角的设置图标，可以自定义以下选项：

- **字体大小**：调整终端字体大小
- **颜色主题**：选择深色、浅色、蓝色或绿色主题
- **连接设置**：配置是否显示连接信息、最大重试次数等

## 技术实现

CrossTerminal使用以下技术和库：

- **Flutter**：跨平台UI框架
- **dartssh2**：SSH连接实现
- **xterm**：终端模拟器
- **file_picker**：文件选择功能
- **shared_preferences**：设置保存

## 贡献

欢迎提交问题报告和功能请求！如果你想贡献代码，请遵循以下步骤：

1. Fork项目
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建Pull Request

## 许可证

本项目采用MIT许可证 - 详情请参阅LICENSE文件
