//
//  UsersViewController.swift
//  usersApp
//
//  Created by santiago calvo on 30/03/23.
//

import UIKit

final class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    private var users = [User]()
    
    let refreshControl: UIRefreshControl = {
        let control = UIRefreshControl(frame: .zero)
        control.translatesAutoresizingMaskIntoConstraints = false
        return control
    }()
    
    let mainTableView: UITableView = {
        let table = UITableView(frame: .zero)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        table.register(UserCell.self, forCellReuseIdentifier: UserCell.identifier)
        return table
    }()
    
    let loader: UsersLoader
    
    init(loader: UsersLoader) {
        self.loader = loader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        mainTableView.addSubview(refreshControl)
        
        load()
    }
    
    @objc private func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            guard let self = self else { return }
            
            if let users = try? result.get() {
                self.users = users
                self.mainTableView.reloadData()
            } else {
                self.presentErrorMessage()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    private func presentErrorMessage() {
        let alert = UIAlertController(title: "Error", message: "Error fetching users, please try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = users[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        
        cell.configure(with: cellModel)
        return cell
    }

}

extension UsersViewController {
    private func setupView() {
        view.backgroundColor = .white
        addsubviews()
        setupConstraints()
    }
    
    private func addsubviews() {
        view.addSubview(mainTableView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            mainTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
