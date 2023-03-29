//
//  RemoteUsersLoaderTests.swift
//  usersAppTests
//
//  Created by santiago calvo on 28/03/23.
//

import XCTest
import usersApp

typealias HTTPClientResult = Swift.Result<(Data, HTTPURLResponse), Error>

protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}

class RemoteUserLoader {
    let url: URL
    let client: HTTPClient
    
    init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public typealias Result = LoadUsersResult
    
    public func load(completion: @escaping (Result) -> Void)  {
        client.get(from: url) { _ in }
    }
}

class RemoteUsersLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://any-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        
        XCTAssertEqual([url], client.requestedURLs)
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteUserLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteUserLoader(url: url, client: client)
        return (sut, client)
    }
    
    class HTTPClientSpy: HTTPClient {
        
        var requestedURLs = [URL]()
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            requestedURLs.append(url)
        }
    }
}
