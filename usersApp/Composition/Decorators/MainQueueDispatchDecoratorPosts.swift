//
//  MainQueueDispatchDecoratorPosts.swift
//  usersApp
//
//  Created by santiago calvo on 31/03/23.
//

import Foundation

final class MainQueueDispatchDecoratorPosts: PostsLoader {
    
    private let decoratee: PostsLoader

    init(decoratee: PostsLoader) {
        self.decoratee = decoratee
    }
    
    func load(completion: @escaping (LoadPostsResult) -> Void) {
        decoratee.load { result in
            if Thread.isMainThread {
                completion(result)
            } else {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
    }
}
