//
//  UsersViewControllerTests.swift
//  usersAppTests
//
//  Created by santiago calvo on 29/03/23.
//

import XCTest
import usersApp
import UIKit

final class UserCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func configure(with user: User) {
        phoneLabel.text = user.phone
        nameLabel.text = user.name
        emailLabel.text = user.email
    }
}

final class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    private var users = [User]()
    
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let mainTableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let loader: UsersLoader
    
    init(loader: UsersLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        mainTableView.addSubview(refreshControl)
        
        load()
    }
    
    @objc private func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            guard let self = self else { return }
            self.users = (try? result.get()) ?? []
            self.mainTableView.reloadData()
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = users[indexPath.row]
        let cell = UserCell()
        cell.configure(with: cellModel)
        return cell
    }

}

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
        
        loader.completeUserLoading(at: 1)
        
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
    
    
        
    //MARK: - helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: UsersViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = UsersViewController(loader: loader)
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
