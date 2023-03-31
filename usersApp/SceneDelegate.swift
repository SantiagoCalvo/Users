//
//  SceneDelegate.swift
//  usersApp
//
//  Created by santiago calvo on 28/03/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let usersURL = URL(string: "https://jsonplaceholder.typicode.com/users")!
        
        let cache = URLCache(memoryCapacity: 10*1024*1024, diskCapacity: 10*1024*1024)
        let configuration = URLSessionConfiguration.default
        configuration.urlCache = cache
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        let sessionCache = URLSession(configuration: configuration)
        
        let urlSessionHTTPClientWithCache = URLSessionHTTPClient(session: sessionCache)
        
        let userLoader = MainQueueDispatchDecorator(decoratee: RemoteUserLoader(url: usersURL, client: urlSessionHTTPClientWithCache))
        
        let usersViewController = UsersViewController(loader: userLoader) {_ in}
        
        let navigationController = UINavigationController(rootViewController: usersViewController)
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        self.window = window
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

