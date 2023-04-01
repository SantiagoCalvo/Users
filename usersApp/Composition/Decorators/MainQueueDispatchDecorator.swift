//
//  MainQueueDispatchDecorator.swift
//  usersApp
//
//  Created by santiago calvo on 31/03/23.
//

import Foundation

final class MainQueueDispatchDecorator: UsersLoader {
    private let decoratee: UsersLoader

    init(decoratee: UsersLoader) {
        self.decoratee = decoratee
    }

    func load(completion: @escaping (LoadUsersResult) -> Void) {
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
