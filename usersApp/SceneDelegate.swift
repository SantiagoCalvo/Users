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
        navigationController.pushViewController(PostsViewControllerFactory.getPostViewController(with: user), animated: true)
    }

}
