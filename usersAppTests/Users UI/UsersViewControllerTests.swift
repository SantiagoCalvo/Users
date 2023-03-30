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
        
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        refreshControl.beginRefreshing()
        load()
    }
    
    @objc private func load() {
        loader.load { _ in }
    }
}

class UsersViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadUsers() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_LoadsUsers() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    func test_pullToRefresh_loadsFeed() {
        let (sut, loader) = makeSUT()
        sut.loadViewIfNeeded()
        
        sut.refreshControl.simulatePullToRefresh()
        
        XCTAssertEqual(loader.loadCallCount, 2)
    }
    
    func test_viewDidLoad_showsLoadingIndicator() {
        let (sut, _) = makeSUT()

        sut.loadViewIfNeeded()

        XCTAssertEqual(sut.refreshControl.isRefreshing, true)
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
        
        var loadCallCount: Int = 0
        
        func load(completion: @escaping (usersApp.LoadUsersResult) -> Void) {
            loadCallCount += 1
        }
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
