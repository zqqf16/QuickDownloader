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

class ViewController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    
    var timer: Timer?
    var displayStatus: StatusType = .all

    var tasks: [Aria2Task] = []
    var allTasks: [Aria2Task] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.setupTableView()
        self.setupMenu()
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        
        if let wc = self.view.window?.windowController as? WindowController {
            wc.titlebarAccessoryViewController?.delegate = self
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        
        self.startTimer()
    }
    
    override func viewDidDisappear() {
        super.viewDidDisappear()
        
        self.stopTimer()
    }
    
    private func setupTableView() {
        self.tableView.doubleAction = #selector(doubleClickedOnRow)
    }
    
    private func setupMenu() {
        let menu = NSMenu(title: "Task")
        let showItem = NSMenuItem(title: "Show in Finder", action: #selector(showInFinder), keyEquivalent: "")
        showItem.isEnabled = true
        menu.addItem(showItem)
        menu.allowsContextMenuPlugIns = true
        self.tableView.menu = menu
    }
    
    @objc func showInFinder() {
        guard let task = self.clickedTask() else {
            return
        }
        
        if let path = task.filePath {
            let url = URL(fileURLWithPath: path)
            NSWorkspace.shared.activateFileViewerSelecting([url])
        }
    }
    
    
    
    @objc func doubleClickedOnRow() {
        guard let task = self.clickedTask() else {
            return
        }
        
        switch task.status {
        case .paused:
            Aria2.global?.unpause(task.gid, completionHandler: nil)
        case .active, .waiting:
            Aria2.global?.pause(task.gid, completionHandler: nil)
        default:
            return
        }
    }
    
    private func clickedTask() -> Aria2Task? {
        let row = self.tableView.clickedRow
        if row == NSNotFound {
            return nil
        }
        
        return self.tasks[row]
    }
    
    private func selectedTasks() -> [Aria2Task] {
        var tasks: [Aria2Task] = []
        let selectedRowIndexes = self.tableView.selectedRowIndexes
        selectedRowIndexes.forEach { (index) in
            tasks.append(self.tasks[index])
        }
        
        return tasks
    }
    
    private func selectedGids() -> [String] {
        let tasks = self.selectedTasks()
        
        return tasks.map {
            return $0.gid
        }
    }
    
    private func selectGids(_ gids: [String]) {
        var indexes = IndexSet()
        for (index, task) in self.tasks.enumerated() {
            if gids.contains(task.gid) {
                indexes.insert(index)
            }
        }
        
        self.tableView.selectRowIndexes(indexes, byExtendingSelection: false)
    }
}

// MARK: - Data loading
extension ViewController {
    func startTimer() {
        self.stopTimer()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { [weak self] (timer) in
            self?.loadTasks()
        })
    }
    
    func stopTimer() {
        self.timer?.invalidate()
        self.timer = nil
    }
    
    func loadTasks() {
        Aria2.global?.tellAll { [weak self] (tasks) in
            guard let strongSelf = self else {
                return
            }
            DispatchQueue.main.async {
                strongSelf.reloadData(tasks ?? [])
                strongSelf.startTimer()
            }
        }
    }

    func reloadData(_ newTasks:[Aria2Task]) {
        let gids = self.selectedGids()
        self.allTasks = newTasks
        self.tasks = newTasks.filter({ (task) -> Bool in
            return self.displayStatus.isMatch(task)
        })
        self.tableView.reloadData()
        
        self.selectGids(gids)
    }
}

extension ViewController {
    @IBAction func pause(_ sender: Any) {
        let gids = self.selectedGids()
        gids.forEach { (gid) in
            Aria2.global?.pause(gid, completionHandler: nil)
        }
    }
    
    @IBAction func unpause(_ sender: Any) {
        let gids = self.selectedGids()
        gids.forEach { (gid) in
            Aria2.global?.unpause(gid, completionHandler: nil)
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        let tasks = self.selectedTasks()
        for task in tasks {
            self.removeTask(task)
        }
    }
    
    func removeTask(_ task: Aria2Task) {
        if task.status == .complete || task.status == .error || task.status == .removed {
            Aria2.global?.removeDownloadResult(task.gid, completionHandler: nil)
        } else {
            Aria2.global?.remove(task.gid) { (gid) in
                Aria2.global?.removeDownloadResult(task.gid, completionHandler: nil)
            }
        }
    }
    
    @IBAction func clear(_ sender: Any) {
        Aria2.global?.purgeDownloadResult(completionHandler: nil)
    }
}

// MARK: - NSTableViewDelegate & NSTableViewDataSource
extension NSUserInterfaceItemIdentifier {
    static let downloadTaskCellID = NSUserInterfaceItemIdentifier("DownloadTaskCell")
}

extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: .downloadTaskCellID, owner: nil) as! DownloadTaskCellView
        cell.downloadTask = self.tasks[row]
        return cell
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.tasks.count
    }
}

// MARK: - TitlebarAccessoryViewControllerDelegate
extension StatusType {
    func isMatch(_ task: Aria2Task) -> Bool {
        switch self {
        case .all:
            return true
        case .active:
            return task.status == .active || task.status == .waiting || task.status == .paused
        case .complete:
            return task.status == .complete
        case .error:
            return task.status == .error || task.status == .removed
        }
    }
}

extension ViewController: TitlebarAccessoryViewControllerDelegate {
    func statusDidChanged(_ new: StatusType) {
        self.displayStatus = new
        self.reloadData(self.allTasks)
    }
}
