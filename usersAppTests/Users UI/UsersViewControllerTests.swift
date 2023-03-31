//
//  UsersViewControllerTests.swift
//  usersAppTests
//
//  Created by santiago calvo on 29/03/23.
//

import XCTest
@testable import usersApp
import UIKit

class UsersViewControllerTests: XCTestCase {
    
    func test_loadUserActions_requestUsersFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 2)
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingUserIndicator_isVisibleWhileLoadingUsers() {
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeUserLoading(at: 0)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFeedReload()
        
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeUserLoadingWithError(at: 1)
        
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    func test_LoadUserCompletion_rendersSuccessfullyLoadedUsers() {
        let user0 = User(id: 1, name: "a name", phone: "1234234", email: "any@email.com")
        let user1 = User(id: 2, name: "a name", phone: "1234234", email: "any@email.com")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeUserLoading(with: [user0], at: 0)

        XCTAssertEqual(sut.numberOfRenderedUsers(), 1)
        
        assertThat(sut, isRendering: [user0])
        
        sut.simulateUserInitiatedFeedReload()
        loader.completeUserLoading(with: [user0, user1], at: 1)
        XCTAssertEqual(sut.numberOfRenderedUsers(), 2)
        
        assertThat(sut, isRendering: [user0, user1])
    }
    
    func test_loaduserCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let user0 = User(id: 1, name: "a name", phone: "1234234", email: "any@email.com")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeUserLoading(with: [user0], at: 0)
        assertThat(sut, isRendering: [user0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeUserLoadingWithError(at: 1)
        assertThat(sut, isRendering: [user0])
    }
    
    func test_filterUsersByName_whenUsingSearchControl() {
        let user0 = User(id: 1, name: "user", phone: "1234234", email: "any@email.com")
        let user1 = User(id: 2, name: "ana", phone: "1234234", email: "any@email.com")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeUserLoading(with: [user0, user1], at: 0)

        XCTAssertEqual(sut.numberOfRenderedUsers(), 2)
        
        assertThat(sut, isRendering: [user0, user1])
        
        sut.searchUser(user0.name)
        
        assertThat(sut, isRendering: [user0])
        
        sut.searchUser("a")
        
        assertThat(sut, isRendering: [user1])
        
        sut.searchUser("")
        
        assertThat(sut, isRendering: [user0, user1])
    }
    
    func test_clickOnCell_callscallbackWithSelectedUser() {
        let user0 = User(id: 1, name: "user", phone: "1234234", email: "any@email.com")
        let user1 = User(id: 2, name: "ana", phone: "1234234", email: "any@email.com")
        var selectedUsers = [User]()
        let (sut, loader) = makeSUT(selectCell: { user in
            selectedUsers.append(user)
        })
        
        sut.loadViewIfNeeded()
        
        loader.completeUserLoading(with: [user0, user1], at: 0)
        assertThat(sut, isRendering: [user0, user1])
        
        sut.simulateUserSelectCell(at: 0)
        
        XCTAssertEqual(selectedUsers, [user0])
        
        sut.simulateUserSelectCell(at: 1)
        
        XCTAssertEqual(selectedUsers, [user0, user1])
    }
        
    //MARK: - helpers
    
    private func makeSUT(selectCell: @escaping (User) -> Void = {_ in}, file: StaticString = #filePath, line: UInt = #line) -> (sut: UsersViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = UsersViewController(loader: loader, selectedUser: selectCell)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func assertThat(_ sut: UsersViewController, isRendering users: [User], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedUsers() == users.count else {
            return XCTFail("Expected \(users.count) images, got \(sut.numberOfRenderedUsers()) instead.", file: file, line: line)
        }

        users.enumerated().forEach { index, user in
            assertThat(sut, hasViewConfiguredFor: user, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: UsersViewController, hasViewConfiguredFor user: User, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.usersView(at: index)
        
        guard let cell = view as? UserCell else {
            return XCTFail("expected to have correct cell instance", file: file, line: line)
        }
        
        XCTAssertEqual(cell.emailText, user.email, file: file, line: line)
        XCTAssertEqual(cell.phoneText, user.phone, file: file, line: line)
        XCTAssertEqual(cell.nameText, user.name, file: file, line: line)
    }
    
    private class LoaderSpy: UsersLoader {
        
        private var completions = [(LoadUsersResult) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (usersApp.LoadUsersResult) -> Void) {
            completions.append(completion)
        }
        
        func completeUserLoading(with users: [User] = [], at Index: Int = 0) {
            completions[Index](.success(users))
        }
        
        func completeUserLoadingWithError(at index: Int = 0) {
            completions[index](.failure(NSError(domain: "error", code: 0)))
        }
    }
}

private extension UsersViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl.isRefreshing == true
    }
    
    func numberOfRenderedUsers() -> Int {
        return mainTableView.numberOfRows(inSection: 0)
    }
    
    func usersView(at row: Int = 0) -> UITableViewCell? {
        let ds = mainTableView.dataSource
        let index = IndexPath(row: row, section: 0)
        return ds?.tableView(mainTableView, cellForRowAt: index)
    }
    
    var errorView: Bool {
        return (presentedViewController as? UIAlertController) != nil ? true : false
    }
    
    func searchUser(_ userName: String) {
        searchController.searchBar.text = userName
    }
    
    func simulateUserSelectCell(at row: Int = 0) {
        let delegate = mainTableView.delegate
        let index = IndexPath(row: row, section: 0)
        delegate?.tableView?(mainTableView, didSelectRowAt: index)
    }
}

private extension UserCell {
    var nameText: String? {
        return nameLabel.text
    }
    
    var emailText: String? {
        return emailLabel.text
    }
    
    var phoneText: String? {
        return phoneLabel.text
    }
}

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .valueChanged)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
