//
//  PostsLoader.swift
//  usersApp
//
//  Created by santiago calvo on 30/03/23.
//

public typealias LoadPostsResult = Swift.Result<[Post], Error>

public protocol PostsLoader {
    func load(completion: @escaping (LoadPostsResult) -> Void)
}
