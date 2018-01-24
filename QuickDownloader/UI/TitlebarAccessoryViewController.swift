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

enum StatusType {
    case all
    case active
    case complete
    case error
}

protocol TitlebarAccessoryViewControllerDelegate: class {
    func statusDidChanged(_ new: StatusType)
}

class TitlebarAccessoryViewController: NSTitlebarAccessoryViewController {

    weak var delegate: TitlebarAccessoryViewControllerDelegate?
    
    @IBOutlet weak var allButton: NSButton!
    @IBOutlet weak var activeButton: NSButton!
    @IBOutlet weak var finishedButton: NSButton!
    @IBOutlet weak var failedButton: NSButton!
    
    var statusButtons:[NSButton] = []
    var currentSelectedButton: NSButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        self.statusButtons = [allButton, activeButton, finishedButton, failedButton]
        self.currentSelectedButton = allButton
    }
    
    func changeStatus(_ sender: NSButton) {
        if sender == self.currentSelectedButton {
            return
        }
        self.currentSelectedButton = sender
        
        self.statusButtons.forEach { (btn) in
            if btn != sender {
                btn.state = .off
            }
        }
        
        if let delegate = self.delegate {
            let index = self.statusButtons.index(of: sender)!
            let types:[StatusType] = [.all, .active, .complete, .error]
            let type = types[index]
            delegate.statusDidChanged(type)
        }
    }
    
    @IBAction func changeStatusToAll(_ sender: NSButton) {
        self.changeStatus(sender)
    }
    
    @IBAction func changeStatusToActive(_ sender: NSButton) {
        self.changeStatus(sender)
    }
    
    @IBAction func changeStatusToFinished(_ sender: NSButton) {
        self.changeStatus(sender)
    }
    
    @IBAction func changeStatusToFailed(_ sender: NSButton) {
        self.changeStatus(sender)
    }
}
