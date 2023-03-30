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
}

class UsersViewControllerTests: XCTestCase {
    
    func test_init_doesNotLoadUsers() {
        let loader = LoaderSpy()
        
        _ = UsersViewController(loader: loader)
        
        XCTAssertEqual(loader.loadCallCount, 0)
    }
    
    //MARK: - helpers
    
    private class LoaderSpy: UsersLoader {
        
        var loadCallCount: Int = 0
        
        func load(completion: @escaping (usersApp.LoadUsersResult) -> Void) {
            loadCallCount += 1
        }
    }
}
