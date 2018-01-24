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

class Aria2 {
    enum Method: String {
        case addUri
        case addTorrent
        case addMetalink
        case remove
        case forceRemove
        case pause
        case pauseAll
        
        case forcePause
        case forcePauseAll
        case unpause
        case unpauseAll
        case tellStatus
        case getUris
        case getFiles
        case getPeers
        case getServers
        case tellActive
        case tellWaiting
        case tellStopped
        case changePosition
        case changeUri
        
        case getOption
        case changeOption
        case getGlobalOption
        case changeGlobalOption
        case getGlobalStat
        
        case purgeDownloadResult
        case removeDownloadResult
        case getVersion
        case getSessionInfo
        case shutdown
        case forceShutdown
        case saveSession
        
        case multicall = "system.multicall"
        case listMethods = "system.listMethods"
        case listNotifications = "system.listNotifications"
    }
    
    private let session: URLSession
    
    var host: String
    var port: String
    var secret: String?
    
    init(host: String, port: String="6800", secret: String?) {
        self.host = host
        self.port = port
        self.secret = secret
        self.session = URLSession(configuration: .default)
    }
    
    private func genHTTPBody(method: Method, params: [Any]?) -> Data? {
        var newParams: [Any] = params ?? []
        if let secret = self.secret {
            newParams.insert("token:\(secret)", at: 0)
        }
        
        var methodName: String

        switch method {
        case .multicall, .listMethods, .listNotifications:
            methodName = method.rawValue
        default:
            methodName = "aria2." + method.rawValue
        }
        
        let json: [String: Any] = [
            "jsonrpc": "2.0",
            "id": "qd",
            "method": methodName,
            "params": newParams
        ]
        return try? JSONSerialization.data(withJSONObject: json, options:[])
    }
    
    func request(method: Method, params: [Any]?, completionHandler: @escaping (Data?) -> Swift.Void) {
        guard let url = URL(string: "http://\(self.host):\(self.port)/jsonrpc"),
            let body = self.genHTTPBody(method: method, params: params) else {
                return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        let task = self.session.dataTask(with: request) { (data, response, error) in
            completionHandler(data)
        }

        task.resume()
    }
}


func handleData<T: Decodable>(_ data: Data?, completionHandler: ((T?)->Void)?) {
    guard let callback = completionHandler else {
        return
    }
    
    guard let result = data,
        let response = try? JSONDecoder().decode(Aria2Response<T>.self, from: result)
        else {
            callback(nil)
            return
    }
    
    callback(response.result)
}

extension Aria2 {
    func addUri(_ uris: [String], options:[String: String]?, position: Int?, completionHandler: ((String?)->Void)? = nil) {
        var params:[Any] = [uris]
        if let opt = options {
            params.append(opt)
        }
        if let pos = position {
            params.append(pos)
        }
        
        self.request(method: .addUri, params: params) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func pause(_ gid: String, completionHandler: ((String?)->Void)? = nil) {
        self.request(method: .pause, params: [gid]) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func unpause(_ gid: String, completionHandler: ((String?)->Void)? = nil) {
        self.request(method: .unpause, params: [gid]) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func remove(_ gid: String, completionHandler: ((String?)->Void)? = nil) {
        self.request(method: .remove, params: [gid]) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func removeDownloadResult(_ gid: String, completionHandler: ((String?)->Void)? = nil) {
        self.request(method: .removeDownloadResult, params: [gid]) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func purgeDownloadResult(completionHandler: ((Bool?)->Void)? = nil) {
        self.request(method: .purgeDownloadResult, params: nil) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func tellStatus(_ gid: String, keys: [String]?, completionHandler: (([Aria2Task]?)->Void)? = nil) {
        var params:[Any] = [gid]
        if keys != nil {
            params += (keys! as [Any])
        }
        
        self.request(method: .tellStatus, params: params) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func tellActive(keys: [String]? = nil, completionHandler: (([Aria2Task]?)->Void)? = nil) {
        self.request(method: .tellActive, params: keys) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func tellWaiting(offset: Int, num: Int, keys: [String]? = nil, completionHandler: (([Aria2Task]?)->Void)? = nil) {
        var params: [Any] = [offset, num]
        if keys != nil {
            params += (keys! as [Any])
        }
        self.request(method: .tellWaiting, params: params) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func tellStopped(offset: Int, num: Int, keys: [String]? = nil, completionHandler: (([Aria2Task]?)->Void)? = nil) {
        var params: [Any] = [offset, num]
        if keys != nil {
            params += (keys! as [Any])
        }
        self.request(method: .tellStopped, params: params) { (data) in
            handleData(data, completionHandler: completionHandler)
        }
    }
    
    func getVersion(completionHandler: (([String: Any]?)->Void)?) {
        self.request(method: .getVersion, params: nil) { (result) in
            //
        }
    }
}

// Convenience
extension Aria2 {
    func tellAll(keys: [String]? = nil, completionHandler: @escaping (([Aria2Task]?)->Void)) {
        weak var weakSelf = self
        var allTasks: [Aria2Task] = []
        
        let handleData: (([Aria2Task]?)->Void) = { (tasks) in
            if tasks != nil {
                allTasks.append(contentsOf: tasks!)
            }
        }
        
        self.tellActive { (tasks) in
            handleData(tasks)
            weakSelf?.tellWaiting(offset: 0, num: Int.max, completionHandler: { (tasks) in
                handleData(tasks)
                weakSelf?.tellStopped(offset: 0, num: Int.max, completionHandler: { (tasks) in
                    handleData(tasks)
                    completionHandler(allTasks)
                })
            })
        }
    }
    
    func download(_ url: String, to dir: String) {
        self.addUri([url], options: ["dir": dir], position: 0, completionHandler: nil)
    }
}

extension Aria2 {
    static var global: Aria2?
}
