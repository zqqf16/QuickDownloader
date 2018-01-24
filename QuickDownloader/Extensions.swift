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

import Foundation
import Cocoa

extension String {
    var standardPath: String {
        if self.hasPrefix("/") {
            return self
        }
        
        var path = self
        if path.hasPrefix("~") {
            let startIndex = self.index(self.startIndex, offsetBy: 1)
            path = String(path[startIndex...])
        }
        
        if path.hasPrefix("/") {
            let startIndex = self.index(self.startIndex, offsetBy: 1)
            path = String(path[startIndex...])
        }
        
        let home = FileManager.default.homeDirectoryForCurrentUser
        let url = home.appendingPathComponent(path)
        return url.path
    }
    
    var size: String {
        guard var value = Double(self) else {
            return self
        }
        
        let formats: [String] = ["%.0f B", "%.0f KB", "%.2f MB", "%.2f GB"]
        var index = 0
        let max = formats.count - 1
        
        while value > 1024 {
            value /= 1024
            index += 1
            if index >= max {
                break
            }
        }
        
        let fmt = formats[index]
        return String(format: fmt, value)
    }
    
    var speed: String {
        return self.size + "/s"
    }
}

extension Int {
    var time: String {
        if self < 60 {
            return "\(self)s"
        }
        let sec = self % 60
        var min = self / 60
        if min < 60 {
            return "\(min)m\(sec)s"
        }
        
        min = min % 60
        let hou = self / 60 / 60
        return "\(hou)h\(min)m\(sec)s"
    }
}

extension NSPasteboard.PasteboardType {
    static let backwardsCompatibleURL: NSPasteboard.PasteboardType = {
        if #available(OSX 10.13, *) {
            return NSPasteboard.PasteboardType.URL
        } else {
            return NSPasteboard.PasteboardType(kUTTypeURL as String)
        }
    } ()
}
