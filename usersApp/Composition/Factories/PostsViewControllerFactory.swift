//
//  PostsViewControllerFactory.swift
//  usersApp
//
//  Created by santiago calvo on 31/03/23.
//

import Foundation

final class PostsViewControllerFactory {
    static func getPostViewController(with user: User) -> PostsViewController {
        let queryItems = [URLQueryItem(name: "userId", value: String(user.id))]
        var urlComps = URLComponents(string: "https://jsonplaceholder.typicode.com/posts")!
        urlComps.queryItems = queryItems
        let url = urlComps.url!
        let loader = MainQueueDispatchDecoratorPosts(decoratee: RemotePostsLoader(url: url, client: URLSessionHTTPClient(session: .shared)))
        
        return PostsViewController(loader: loader, user: user)
    }
}
