//
//  PostsViewControllerTests.swift
//  usersAppTests
//
//  Created by santiago calvo on 31/03/23.
//

import XCTest
@testable import usersApp
import UIKit

class PostsViewControllerTests: XCTestCase {
    
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
    
    func test_loadingPostIndicator_isVisibleWhileLoadingPosts() {
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
        let post0 = Post(userId: 1, id: 1, title: "title", body: "body")
        let post1 = Post(userId: 1, id: 1, title: "title", body: "body")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()

        loader.completeUserLoading(with: [post0], at: 0)

        XCTAssertEqual(sut.numberOfRenderedPosts(), 1)

        assertThat(sut, isRendering: [post0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeUserLoading(with: [post0, post1], at: 1)
        XCTAssertEqual(sut.numberOfRenderedPosts(), 2)

        assertThat(sut, isRendering: [post0, post1])
    }
    
    func test_loaduserCompletion_doesNotAlterCurrentRenderingStateOnError() {
        let post0 = Post(userId: 1, id: 1, title: "title", body: "body")
        let (sut, loader) = makeSUT()

        sut.loadViewIfNeeded()
        loader.completeUserLoading(with: [post0], at: 0)
        assertThat(sut, isRendering: [post0])

        sut.simulateUserInitiatedFeedReload()
        loader.completeUserLoadingWithError(at: 1)
        assertThat(sut, isRendering: [post0])
    }
    
    func test_viewdidLoad_showCurrentUserInformation() {
        let user = getUser()
        let (sut, _) = makeSUT(with: user)

        sut.viewDidLoad()

        XCTAssertEqual(sut.getUserName(), user.name)
        XCTAssertEqual(sut.getUserPhone(), user.phone)
        XCTAssertEqual(sut.getUserEmail(), user.email)
    }
        
    //MARK: - helpers
    
    private func makeSUT(with user: User = User(id: 1, name: "name", phone: "phone", email: "email"), file: StaticString = #filePath, line: UInt = #line) -> (sut: PostsViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = PostsViewController(loader: loader, user: user)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private func getUser() -> User {
        return User(id: 1, name: "name", phone: "phone", email: "email")
    }
    
    private func assertThat(_ sut: PostsViewController, isRendering posts: [Post], file: StaticString = #filePath, line: UInt = #line) {
        guard sut.numberOfRenderedPosts() == posts.count else {
            return XCTFail("Expected \(posts.count) images, got \(sut.numberOfRenderedPosts()) instead.", file: file, line: line)
        }

        posts.enumerated().forEach { index, user in
            assertThat(sut, hasViewConfiguredFor: user, at: index, file: file, line: line)
        }
    }
    
    private func assertThat(_ sut: PostsViewController, hasViewConfiguredFor post: Post, at index: Int, file: StaticString = #filePath, line: UInt = #line) {
        let view = sut.postView(at: index)
        
        guard let cell = view as? PostCell else {
            return XCTFail("expected to have correct cell instance", file: file, line: line)
        }
        
        XCTAssertEqual(cell.titleText, post.title, file: file, line: line)
        XCTAssertEqual(cell.bodyText, post.body, file: file, line: line)
    }
    
    private class LoaderSpy: PostsLoader {
        
        private var completions = [(LoadPostsResult) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (usersApp.LoadPostsResult) -> Void) {
            completions.append(completion)
        }
        
        func completeUserLoading(with users: [Post] = [], at Index: Int = 0) {
            completions[Index](.success(users))
        }
        
        func completeUserLoadingWithError(at index: Int = 0) {
            completions[index](.failure(NSError(domain: "error", code: 0)))
        }
    }
}

private extension PostsViewController {
    func simulateUserInitiatedFeedReload() {
        refreshControl.simulatePullToRefresh()
    }
    
    var isShowingLoadingIndicator: Bool {
        return refreshControl.isRefreshing == true
    }
    
    func numberOfRenderedPosts() -> Int {
        return mainTableView.numberOfRows(inSection: 0)
    }
    
    func postView(at row: Int = 0) -> UITableViewCell? {
        let ds = mainTableView.dataSource
        let index = IndexPath(row: row, section: 0)
        return ds?.tableView(mainTableView, cellForRowAt: index)
    }
    
    func searchUser(_ userName: String) {
        searchController.searchBar.text = userName
    }
    
    func simulateUserSelectCell(at row: Int = 0) {
        let delegate = mainTableView.delegate
        let index = IndexPath(row: row, section: 0)
        delegate?.tableView?(mainTableView, didSelectRowAt: index)
    }
    
    func getUserName() -> String? {
        return nameLabel.text
    }
    
    func getUserPhone() -> String? {
        return phoneLabel.text
    }
    
    func getUserEmail() -> String? {
        return emailLabel.text
    }
}

private extension PostCell {
    var titleText: String? {
        return titleLabel.text
    }
    
    var bodyText: String? {
        return bodyLabel.text
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

