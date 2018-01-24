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

struct Config {
    private static let downloadDirKey = "downloadDir"

    static var downloadDir: String {
        get {
            if let dir = UserDefaults.standard.string(forKey: Config.downloadDirKey) {
                return dir.standardPath
            }
            let dirs = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
            return dirs[0]
        }
        set {
            UserDefaults.standard.set(downloadDir, forKey: Config.downloadDirKey)
        }
    }
    
    static var defaultConfig: [String: String] {
        return [
            "enable-rpc": "true",
            "rpc-listen-all": "true",
            "rpc-allow-origin-all": "true",
            "rpc-listen-port": "6800",
            "rpc-secret": "",
        ]
    }
}
