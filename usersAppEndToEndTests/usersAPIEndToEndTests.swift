//
//  usersAppEndToEndTests.swift
//  usersAppEndToEndTests
//
//  Created by santiago calvo on 28/03/23.
//

import XCTest
import usersApp

final class usersAPIEndToEndTests: XCTestCase {

    func test_endToEndTestServerGETUserResult_matchesFixedTestAccountData() {
        switch getFeedResult() {
        case let .success(users)?:
            XCTAssertEqual(users.count, 10, "Expected 12 items in the test account feed")
            XCTAssertEqual(users[0], expectedItem(at: 0))
            XCTAssertEqual(users[1], expectedItem(at: 1))
        case let .failure(error)?:
            XCTFail("Expected successful feed result, got \(error) instead")
            
        default:
            XCTFail("Expected successful feed result, got no result instead")
        }
    }
    
    //MARK: - Helpers
    private func getFeedResult(file: StaticString = #file, line: UInt = #line) -> LoadUsersResult? {
        let testServerURL = URL(string: "https://jsonplaceholder.typicode.com/users")!
        let client = URLSessionHTTPClient()
        let loader = RemoteUserLoader(url: testServerURL, client: client)
        trackForMemoryLeaks(client, file: file, line: line)
        trackForMemoryLeaks(loader, file: file, line: line)
        
        let exp = expectation(description: "Wait for load completion")
        
        var receivedResult: LoadUsersResult?
        loader.load { result in
            receivedResult = result
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5.0)
        
        return receivedResult
    }
    
    private func expectedItem(at index: Int) -> User {
        return User(
            id: id(at: index),
            name: name(at: index),
            phone: phone(at: index)
        )
    }
    
    private func id(at index: Int) -> Int {
        return [1, 2][index]
    }
    
    private func name(at index: Int) -> String {
        [
            "Leanne Graham",
            "Ervin Howell"
        ][index]
    }
    
    private func phone(at index: Int) -> String {
        [
            "1-770-736-8031 x56442",
            "010-692-6593 x09125"
        ][index]
    }
}
