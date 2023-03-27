import Cocoa
import SwiftUI

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var statusBar: StatusBarController?
    var popover = NSPopover.init()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusBar = StatusBarController(popover: popover, delegate: self)
        initView()
    }
    
    func initView() {
        popover.contentSize = NSSize(width: 240, height: 340)
        popover.contentViewController = NSHostingController(rootView: HomeView(statusBar!))
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
}
