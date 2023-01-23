import Cocoa

extension NSTableView {
  open override func viewDidMoveToWindow() {
    super.viewDidMoveToWindow()
    backgroundColor = NSColor.clear
    enclosingScrollView!.drawsBackground = false
  }
}
