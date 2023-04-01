//
//  UserViewControllerFactory.swift
//  usersApp
//
//  Created by santiago calvo on 31/03/23.
//

import Foundation

final class UserViewControllerFactory {
    static func getUsersViewController(selectedUser: @escaping (User) -> Void) -> UsersViewController {
        let usersURL = URL(string: "https://jsonplaceholder.typicode.com/users")!
        
        let cache = URLCache(memoryCapacity: 10*1024*1024, diskCapacity: 10*1024*1024)
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let sessionCache = URLSession(configuration: configuration)
        
        let urlSessionHTTPClientWithCache = URLSessionHTTPClient(session: sessionCache)
        
        let userLoader = MainQueueDispatchDecorator(decoratee: RemoteUserLoader(url: usersURL, client: urlSessionHTTPClientWithCache))
        
        let usersViewController = UsersViewController(loader: userLoader, selectedUser: selectedUser)
        
        return usersViewController
    }
}
