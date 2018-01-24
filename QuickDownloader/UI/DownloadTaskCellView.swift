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

extension NSColor {
    static let progressColor = NSColor(hex6: 0xDFF5FF, alpha: 1)
    static let splitLineColor = NSColor(hex6: 0xE9ECEC, alpha: 1)
}

extension NSColor.Name {
    static let bgPaused = NSColor.Name(rawValue: "bgPaused")
    static let bgActive = NSColor.Name(rawValue: "bgActive")
    static let bgError = NSColor.Name(rawValue: "bgError")
    static let bgRemoved = NSColor.Name(rawValue: "bgRemoved")
    static let bgComplete = NSColor.Name(rawValue: "bgComplete")
    static let bgWaiting = NSColor.Name(rawValue: "bgWaiting")
}

extension Aria2Task {
    var title: String {
        if let files = self.files, let path = files.first?.path, let name = path.components(separatedBy: "/").last {
            return name
        }
        return self.gid
    }
    
    var progress: Float {
        guard let total = Float(self.totalLength ?? "0"),
            total > 0,
            let downloaded = Float(self.completedLength ?? "0") else {
            return 0
        }
        return downloaded/total
    }
    
    var eta: String {
        guard let total = self.totalLength, let intTotal = Int(total),
              let speed = self.downloadSpeed, let intSpeed = Int(speed), intSpeed > 0
        else {
            return "∞"
        }
        
        let downloaded = Int(self.completedLength ?? "0") ?? 0
        let remaining = (intTotal - downloaded)/intSpeed
        return remaining.time
    }
    
    var subTitle: String {
        //"100MB/s - 391MB/1.4G - 20mis remains - 49%"
        let total = (self.totalLength ?? "0").size
        let downloaded = (self.completedLength ?? "0").size
        let pgs = Int(self.progress * 100)
        let speed = (self.downloadSpeed ?? "0").speed
        
        switch self.status {
        case .active:
            return "\(speed) - \(pgs)% - \(downloaded)/\(total) - \(self.eta)"
        default:
            return "\(self.status.rawValue) - \(pgs)% - \(downloaded)/\(total)"
        }
    }
    
    var filePath: String? {
        if let path = self.files?.first?.path, !path.isEmpty {
            return path.standardPath
        }
        
        return nil
    }
    
    var thumbnail: NSImage {
        if let path = self.filePath {
            return NSWorkspace.shared.icon(forFile: path)
        }
        
        return NSWorkspace.shared.icon(forFileType: "unknow")
    }
}

extension Aria2Task.Status {
    func progressColor() -> NSColor {
        switch self {
        case .paused:
            return NSColor(named: .bgPaused)!
        case .error, .removed:
            return NSColor(named: .bgError)!
        case .complete:
            return NSColor(named: .bgComplete)!
        case .waiting:
            return NSColor(named: .bgWaiting)!
        default:
            return NSColor(named: .bgActive)!
        }
    }
}

class ProgressView: NSView {
    var value: Float = 0 {
        didSet {
            self.needsDisplay = true
        }
    }
    var status: Aria2Task.Status = .active {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        let width: CGFloat = dirtyRect.width * CGFloat(self.value)
        let rectanglePath = NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: dirtyRect.height))
        self.status.progressColor().setFill()
        rectanglePath.fill()
    }
}

class DownloadTaskCellView: NSTableCellView {

    @IBOutlet weak var image: NSImageView!
    @IBOutlet weak var title: NSTextField!
    @IBOutlet weak var subtitle: NSTextField!
    @IBOutlet weak var progress: ProgressView!
    
    var downloadTask: Aria2Task? {
        didSet {
            guard let task = downloadTask else {
                return
            }
            self.title.stringValue = task.title
            self.subtitle.stringValue = task.subTitle
            self.progress.value = task.progress
            self.progress.status = task.status
            self.image.image = task.thumbnail
        }
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        
        let bezierPath = NSBezierPath()
        bezierPath.move(to: NSPoint(x: 0, y: 0))
        bezierPath.line(to: NSPoint(x: self.frame.size.width, y: 0))
        NSColor.splitLineColor.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
    }
    
    override var backgroundStyle: NSView.BackgroundStyle {
        didSet {
            if backgroundStyle == .dark {
                self.progress.alphaValue = 0
            } else {
                self.progress.alphaValue = 1
            }
        }
    }
}
