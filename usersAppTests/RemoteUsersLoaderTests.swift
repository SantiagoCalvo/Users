//
//  RemoteUsersLoaderTests.swift
//  usersAppTests
//
//  Created by santiago calvo on 28/03/23.
//

import XCTest

//public enum HTTPClientResult {
//    case success(Data, HTTPURLResponse)
//    case failure(Error)
//}

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
}

class RemoteUsersLoaderTests: XCTestCase {
    
    func test_init_doesNotRequestDataFromURL() {
        let (_, client) = makeSUT()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
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
