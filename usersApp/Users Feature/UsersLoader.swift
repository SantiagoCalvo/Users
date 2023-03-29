//
//  UsersLoader.swift
//  usersApp
//
//  Created by santiago calvo on 28/03/23.
//

import Foundation

import Foundation

public typealias LoadUsersResult = Swift.Result<[User], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadUsersResult) -> Void)
}
