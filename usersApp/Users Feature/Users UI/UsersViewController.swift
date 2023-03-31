//
//  UsersViewController.swift
//  usersApp
//
//  Created by santiago calvo on 30/03/23.
//

import UIKit

final class UsersViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
        
    private var users = [User]() {
        didSet {
            usersFiltered = users
        }
    }
    private var usersFiltered = [User]()
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.translatesAutoresizingMaskIntoConstraints = false
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    
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
    
    let selectedUser: (User) -> Void
    
    init(loader: UsersLoader, selectedUser: @escaping (User) -> Void) {
        self.loader = loader
        self.selectedUser = selectedUser
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
        
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController

        
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
        return usersFiltered.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = usersFiltered[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: UserCell.identifier, for: indexPath) as! UserCell
        
        cell.configure(with: cellModel)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedUser(usersFiltered[indexPath.row])
    }

}

extension UsersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        if text.count == 0 {
            usersFiltered = users
        }else{
            usersFiltered = users.filter { $0.name.contains(text) }
        }
        mainTableView.reloadData()
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
