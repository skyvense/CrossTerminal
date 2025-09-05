import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    
    // 获取主屏幕尺寸
    guard let screen = NSScreen.main else {
      super.awakeFromNib()
      return
    }
    
    let screenFrame = screen.visibleFrame
    
    // 设置窗口尺寸为屏幕的2/3
    let windowWidth = screenFrame.width * 2.0 / 3.0
    let windowHeight = screenFrame.height * 2.0 / 3.0
    
    // 计算居中位置
    let windowX = screenFrame.origin.x + (screenFrame.width - windowWidth) / 2
    let windowY = screenFrame.origin.y + (screenFrame.height - windowHeight) / 2
    
    let windowFrame = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)
    
    self.contentViewController = flutterViewController
    self.setFrame(windowFrame, display: true)
    
    // 设置最小窗口尺寸
    self.minSize = NSSize(width: 800, height: 600)

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
  }
}
