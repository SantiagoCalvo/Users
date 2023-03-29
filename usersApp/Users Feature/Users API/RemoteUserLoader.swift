//
//  RemoteUserLoader.swift
//  usersApp
//
//  Created by santiago calvo on 28/03/23.
//

import Foundation

public class RemoteUserLoader {
    let url: URL
    let client: HTTPClient
    
    public init(url: URL, client: HTTPClient) {
        self.url = url
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case serverError
    }
    
    public typealias Result = LoadUsersResult
    
    public func load(completion: @escaping (Result) -> Void)  {
        client.get(from: url) { response in
            switch response {
            case .failure:
                completion(.failure(Error.serverError))
            case let .success((data, httpResponse)):
                if httpResponse.statusCode == 200, let users = try? JSONDecoder().decode([User].self, from: data) {
                    completion(.success(users))
                }  else {
                    completion(.failure(Error.serverError))
                }
            }
        }
    }
}
