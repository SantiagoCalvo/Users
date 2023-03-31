//
//  UserCell.swift
//  usersApp
//
//  Created by santiago calvo on 30/03/23.
//

import UIKit

final class UserCell: UITableViewCell {
    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func configure(with user: User) {
        phoneLabel.text = user.phone
        nameLabel.text = user.name
        emailLabel.text = user.email
    }
}

