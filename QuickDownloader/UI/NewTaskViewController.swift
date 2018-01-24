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

class NewTaskViewController: NSViewController {

    @IBOutlet weak var url: NSTextField!
    
    var aria2: Aria2?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    func downloadDir() -> String {
        if let dir = UserDefaults.standard.string(forKey: "downloadDir") {
            return dir.standardPath
        }
        let dirs = NSSearchPathForDirectoriesInDomains(.downloadsDirectory, .userDomainMask, true)
        return dirs[0]
    }
    
    @IBAction func startDownload(_ sender: Any?) {
        let url = self.url.stringValue
        // http://devstreaming.apple.com/videos/wwdc/2015/704ci202euy/704/704_hd_whats_new_in_cloudkit.mp4?dl=1
        if url.isEmpty {
            return
        }

        let dir = Config.downloadDir
        self.download(url, to: dir)
    }
    
    @IBAction func close(_ sender: Any?) {
        DispatchQueue.main.async {
            self.dismiss(sender)
        }
        //self.view.window?.close()
    }
    
    func download(_ url: String, to dir: String) {
        guard let aria2 = self.aria2 else {
            return
        }
        
        aria2.addUri([url], options: ["dir": dir], position: 0) { (gid) in
            self.close(nil)
        }
    }
}
