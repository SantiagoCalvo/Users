//
//  UsersViewControllerTests.swift
//  usersAppTests
//
//  Created by santiago calvo on 29/03/23.
//

import XCTest
import usersApp
import UIKit

class UsersViewController: UIViewController {
    
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
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        mainTableView.addSubview(refreshControl)
        
        load()
    }
    
    @objc private func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] _ in
            guard let self = self else { return }
            self.refreshControl.endRefreshing()
        }
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
        
    //MARK: - helpers
    
    private func makeSUT(file: StaticString = #filePath, line: UInt = #line) -> (sut: UsersViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = UsersViewController(loader: loader)
        trackForMemoryLeaks(loader, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return (sut, loader)
    }
    
    private class LoaderSpy: UsersLoader {
        
        private var completions = [(LoadUsersResult) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(completion: @escaping (usersApp.LoadUsersResult) -> Void) {
            completions.append(completion)
        }
        
        func completeUserLoading(at Index: Int = 0) {
            completions[Index](.success([]))
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
