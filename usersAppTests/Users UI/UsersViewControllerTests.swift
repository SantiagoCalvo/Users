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
        
        load()
    }
    
    private func load() {
        loader.load { _ in }
    }
}

class UsersViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadUsers() {
        let loader = LoaderSpy()
        
        _ = UsersViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    func test_viewDidLoad_LoadsUsers() {
        let loader = LoaderSpy()
        
        let sut = UsersViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCallCount, 1)
    }
    
    //MARK: - helpers
    
    private class LoaderSpy: UsersLoader {
        
        var loadCallCount: Int = 0
        
        func load(completion: @escaping (usersApp.LoadUsersResult) -> Void) {
            loadCallCount += 1
        }
    }
}
