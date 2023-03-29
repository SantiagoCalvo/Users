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
    
    public enum Error: Swift.Error {
        case serverError
    }
    
    public typealias Result = LoadUsersResult
    
    public func load(completion: @escaping (Result) -> Void)  {
        client.get(from: url) { response in
            switch response {
            case let .failure(error):
                completion(.failure(error))
            case .success:
                break
            }
        }
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
    
    func test_loadTwice_requestsDataFromURLTwice() {
        let url = URL(string: "https://a-given-url.com")!
        let (sut, client) = makeSUT(url: url)
        
        sut.load { _ in }
        sut.load { _ in }
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = makeSUT()
        let clientError = NSError(domain: "Test", code: 0)
        
        let exp = expectation(description: "wait for completion")
        sut.load { response in
            switch response {
            case let .failure(receivedError as NSError):
                XCTAssertEqual(receivedError, clientError)
            case .success:
                XCTFail("expected failure got \(response) innstead")
            }
            exp.fulfill()
        }
        
        client.complete(with: clientError)
        
        wait(for: [exp], timeout: 1)
    }
    
    //MARK: - Helpers
    private func makeSUT(url: URL = URL(string: "https://a-url.com")!, file: StaticString = #file, line: UInt = #line) -> (sut: RemoteUserLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteUserLoader(url: url, client: client)
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        
        var messages = [(url: URL, completion: (HTTPClientResult) -> Void)]()
        
        var requestedURLs: [URL] {
            return messages.map { $0.url }
        }
        
        func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(with error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
