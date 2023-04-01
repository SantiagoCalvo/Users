//
//  PostsViewController.swift
//  usersApp
//
//  Created by santiago calvo on 31/03/23.
//

import UIKit

final class PostsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let loader: PostsLoader
    
    let user: User
    
    private var posts = [Post]()
    
    let nameLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let phoneLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let headerView: UIView = {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        table.register(PostCell.self, forCellReuseIdentifier: PostCell.identifier)
        return table
    }()
    
    lazy var searchController: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchBar.translatesAutoresizingMaskIntoConstraints = false
        search.obscuresBackgroundDuringPresentation = false
        return search
    }()
    
    init(loader: PostsLoader, user: User) {
        self.loader = loader
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        
        setupView()
        
        setupHeaderLabels(with: user)
        
        mainTableView.delegate = self
        mainTableView.dataSource = self
        
        refreshControl.addTarget(self, action: #selector(load), for: .valueChanged)
        mainTableView.addSubview(refreshControl)
        
        load()
    }
    
    private func setupHeaderLabels(with user: User) {
        nameLabel.text = user.name
        emailLabel.text = user.email
        phoneLabel.text = user.phone
    }
    
    @objc private func load() {
        refreshControl.beginRefreshing()
        loader.load { [weak self] result in
            guard let self = self else { return }
            
            if let posts = try? result.get() {
                self.posts = posts
                self.mainTableView.reloadData()
            } else {
                self.presentErrorMessage()
            }
            self.refreshControl.endRefreshing()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellModel = posts[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: PostCell.identifier, for: indexPath) as! PostCell
        
        cell.configure(with: cellModel)
        return cell
    }
    
    private func presentErrorMessage() {
        let alert = UIAlertController(title: "Error", message: "Error fetching posts, please try again!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        present(alert, animated: false)
    }
}


private extension PostsViewController {
    private func setupView() {
        view.backgroundColor = .white
        addsubviews()
        setupConstraints()
    }
    
    private func addsubviews() {
        view.addSubview(mainTableView)
        view.addSubview(headerView)
        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)
        headerView.addSubview(phoneLabel)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 25),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 14),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -14),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 14),
            emailLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            emailLabel.trailingAnchor.constraint(equalTo: emailLabel.trailingAnchor),
            
            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 14),
            phoneLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            phoneLabel.trailingAnchor.constraint(equalTo: nameLabel.trailingAnchor),
            phoneLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -25),
            
            mainTableView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainTableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            mainTableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            mainTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
}
