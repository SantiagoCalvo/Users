//
//  User.swift
//  usersApp
//
//  Created by santiago calvo on 28/03/23.
//

import Foundation

public struct User: Decodable, Equatable {
    let id: Int
    let name: String
    let phone: String
    let email: String
    
    public init(id: Int, name: String, phone: String, email: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
    }
}
