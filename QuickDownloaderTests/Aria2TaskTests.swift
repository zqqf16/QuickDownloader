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

import XCTest
@testable import QuickDownloader

class Aria2TaskTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func response<T>(_ type: T.Type, from json: String) -> T where T: Decodable {
        return try! JSONDecoder().decode(type, from: json.data(using: .utf8)!)
    }
    
    func testGIDParser() {
        let json = "{\"id\":\"qwer\",\"jsonrpc\":\"2.0\",\"result\":\"2089b05ecca3d829\"}"
        let response = self.response(Aria2GIDResponse.self, from: json)
        XCTAssertNotNil(response)
        
        XCTAssertEqual(response.result, "2089b05ecca3d829")
    }
    
    func testURIParser() {
        let json = "{\"id\": \"qwer\", \"jsonrpc\": \"2.0\", \"result\": {\"status\": \"used\", \"uri\": \"http://example.org/file\"}}"
        let response = self.response(Aria2URIResponse.self, from: json)
        XCTAssertNotNil(response)
        
        let uri = response.result
        XCTAssertEqual(uri?.status, .used)
        XCTAssertEqual(uri?.uri, "http://example.org/file")
    }

    func testURIsParser() {
        let json = "{\"id\": \"qwer\", \"jsonrpc\": \"2.0\", \"result\": [{\"status\": \"used\", \"uri\": \"http://example.org/file\"}]}"
        let response = self.response(Aria2URIsResponse.self, from: json)
        XCTAssertNotNil(response)
        
        let uris = response.result
        XCTAssertEqual(uris?.count, 1)
        
        let first = uris?.first
        XCTAssertEqual(first?.status, .used)
        XCTAssertEqual(first?.uri, "http://example.org/file")
    }
    /*
    func response(_ json: String) -> Aria2Response? {
        return try? JSONDecoder().decode(Aria2Response.self, from: json.data(using: .utf8)!)
    }
    */

    func testJSONParser() {
        let json = "{\"bitfield\": \"0000000000\", \"completedLength\": \"901120\", \"connections\": \"1\", \"dir\": \"/downloads\", \"downloadSpeed\": \"15158\", \"files\": [{\"index\": \"1\", \"length\": \"34896138\", \"completedLength\": \"34896138\", \"path\": \"/downloads/file\", \"selected\": \"true\", \"uris\": [{\"status\": \"used\", \"uri\": \"http://example.org/file\"}]}], \"gid\": \"2089b05ecca3d829\", \"numPieces\": \"34\", \"pieceLength\": \"1048576\", \"status\": \"active\", \"totalLength\": \"34896138\", \"uploadLength\": \"0\", \"uploadSpeed\": \"0\"}"
        
        let task = try? JSONDecoder().decode(Aria2Task.self, from: json.data(using: .utf8)!)
        XCTAssertNotNil(task)
        
        XCTAssertEqual(task?.completedLength, "901120")
        XCTAssertEqual(task?.dir, "/downloads")
        XCTAssertEqual(task?.downloadSpeed, "15158")
        XCTAssertEqual(task?.gid, "2089b05ecca3d829")
        XCTAssertEqual(task?.status, Aria2Task.Status.active)
        XCTAssertEqual(task?.totalLength, "34896138")
        XCTAssertEqual(task?.uploadLength, "0")
        XCTAssertEqual(task?.uploadSpeed, "0")

        XCTAssertNotNil(task?.files)
        let file = task!.files![0]
        XCTAssertEqual(file.index, "1")
        XCTAssertEqual(file.length, "34896138")
        XCTAssertEqual(file.completedLength, "34896138")
        XCTAssertEqual(file.path, "/downloads/file")
        XCTAssertEqual(file.selected, "true")
        
        XCTAssertNotNil(file.uris)
        let uri = file.uris![0]
        XCTAssertEqual(uri.status, Aria2URI.Status.used)
        XCTAssertEqual(uri.uri, "http://example.org/file")
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
