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

struct Aria2GlobalState: Codable {
    var downloadSpeed: String?
    var uploadSpeed: String?
    var numActive: String?
    var numWaiting: String?
    var numStopped: String?
    var numStoppedTotal: String?
}

struct Aria2URI: Codable {
    enum Status: String, Codable {
        case used
        case waiting
    }
    var uri: String?
    var status: Status?
}

struct Aria2File: Codable {
    var index: String?
    var path: String?
    var length: String?
    var completedLength: String?
    
    var selected: String?
    var uris:[Aria2URI]?
}

struct Aria2Task: Codable {
    enum Status: String, Codable {
        case active
        case waiting
        case paused
        case error
        case complete
        case removed
    }
    
    var gid: String
    var status: Status = .waiting
    var totalLength: String?
    var completedLength: String?
    var uploadLength: String?
    
    var downloadSpeed: String?
    var uploadSpeed: String?

    var errorCode: String?
    var errorMessage: String?
    
    var dir: String?
    var files: [Aria2File]?
    
//    var followedBy: [String]?
//    var following: [String]?
//    var belongsTo: String?
//
//    var verifiedLength: Int?
//    var verifyIntegrityPending: Bool?
    
    //Torrent not supported now
//    var bittorrent: [Any]?
//    var bitfield: Any?
//    var infoHash: String?
//    var numSeeders: Int?
//    var seeder: Bool?
//    var pieceLength: Int?
//    var numPieces: Int?
//    var connections: Int?
}

struct Aria2Response <T: Decodable> : Decodable {
    var id: String
    var jsonrpc: String
    var result: T?
}

typealias Aria2GIDResponse = Aria2Response<String>
typealias Aria2GIDsResponse = Aria2Response<[String]>
typealias Aria2URIResponse = Aria2Response<Aria2URI>
typealias Aria2URIsResponse = Aria2Response<[Aria2URI]>
typealias Aria2TaskResponse = Aria2Response<Aria2Task>
typealias Aria2TasksResponse = Aria2Response<[Aria2Task]>
