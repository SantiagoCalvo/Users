//
//  SceneDelegate.swift
//  usersApp
//
//  Created by santiago calvo on 28/03/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    private lazy var navigationController = UINavigationController(rootViewController: UserViewControllerFactory.getUsersViewController(selectedUser: showPosts))

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
    }

    private func showPosts(for user: User) {
        let queryItems = [URLQueryItem(name: "userId", value: String(user.id))]
        var urlComps = URLComponents(string: "https://jsonplaceholder.typicode.com/posts")!
        urlComps.queryItems = queryItems
        let url = urlComps.url!
        let loader = MainQueueDispatchDecoratorPosts(decoratee: RemotePostsLoader(url: url, client: URLSessionHTTPClient(session: .shared)))
        
        let postController = PostsViewController(loader: loader, user: user)
        
        navigationController.pushViewController(postController, animated: true)
    }

}

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

private final class MainQueueDispatchDecorator: UsersLoader {
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

private final class MainQueueDispatchDecoratorPosts: PostsLoader {
    
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

