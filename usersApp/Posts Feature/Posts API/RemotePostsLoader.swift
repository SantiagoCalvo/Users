//
//  RemotePostsLoader.swift
//  usersApp
//
//  Created by santiago calvo on 30/03/23.
//

import Foundation

public class RemotePostsLoader: PostsLoader {
    
    let url: URL
    let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case serverError
    }
    
    public func load(completion: @escaping (LoadPostsResult) -> Void) {
        client.get(from: url) { [weak self] response in
            guard let self = self else {return}
            switch response {
            case .failure:
                completion(.failure(Error.serverError))
            case let .success((data, httpResponse)):
                completion(self.map(data, httpResponse))
            }
        }
    }
    
    private func map(_ data: Data, _ httpResponse: HTTPURLResponse) -> LoadPostsResult {
        if httpResponse.statusCode == 200, let posts = try? JSONDecoder().decode([Post].self, from: data) {
            return .success(posts)
        }  else {
            return .failure(Error.serverError)
        }
    }
}
