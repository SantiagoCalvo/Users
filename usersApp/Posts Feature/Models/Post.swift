//
//  Post.swift
//  usersApp
//
//  Created by santiago calvo on 30/03/23.
//

import Foundation

public struct Post: Decodable, Equatable {
    public let userId: Int
    public let id: Int
    public let title: String
    public let body: String
    
    public init(userId: Int, id: Int, title: String, body: String) {
        self.userId = userId
        self.id = id
        self.title = title
        self.body = body
    }
}
