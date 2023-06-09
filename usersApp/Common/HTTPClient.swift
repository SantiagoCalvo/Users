//
//  HTTPClient.swift
//  usersApp
//
//  Created by santiago calvo on 28/03/23.
//

import Foundation

public typealias HTTPClientResult = Swift.Result<(Data, HTTPURLResponse), Error>

public protocol HTTPClient {
    func get(from url: URL, completion: @escaping (HTTPClientResult) -> Void)
}
