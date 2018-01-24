// The MIT License (MIT)
//
// Copyright (c) 2018 zqqf16
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Cocoa

class StatusBarControler: NSObject, NSWindowDelegate, NSDraggingDestination {
    let statusItem: NSStatusItem
    
    override init() {
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        super.init()
        self.configStatusItem()
    }
    
    private func configStatusItem() {
        guard let button = self.statusItem.button else {
            return
        }
        
        button.image = #imageLiteral(resourceName: "download")
        button.action = #selector(showWindow(_:))
        button.target = self
        
        button.window?.registerForDraggedTypes([.backwardsCompatibleURL])
        button.window?.delegate = self
    }
    
    func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }
    
    func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        let pboard = sender.draggingPasteboard()
        if let url = pboard.string(forType: .backwardsCompatibleURL) {
            self.quickDownload(url)
        }
        return true
    }
    
    @objc func showWindow(_ sender: Any?) {
        NSApp.activate(ignoringOtherApps: true)
        for window in NSApp.windows {
            window.makeKeyAndOrderFront(nil)
        }
    }
    
    func quickDownload(_ url: String) {
        guard let aria2 = Aria2.global else {
            return
        }
        
        aria2.download(url, to: Config.downloadDir)
    }
}
