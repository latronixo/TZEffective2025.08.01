//
//  TodoListView.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import UIKit

protocol TodoListViewInput {
    var output: TodoListViewOutput? { get set }
}

protocol TodoListViewOutput: AnyObject {
    func viewDidLoad()
    func searchTextChanged(_ text: String)
    func todoToggled(id: Int)
    func editTodo(_ todo: TodoItemViewModel)
    func shareTodo(_ todo: TodoItemViewModel)
    func deleteTodo(_ id: Int)
}

final class TodoListView: UIViewController, TodoListViewInput {
    var output: TodoListViewOutput?
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private var todos: [TodoItemViewModel] = []
    private var currentContextTodo: TodoItemViewModel?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        setupTableView()
        output?.viewDidLoad()
    }
    
    private func setupNavigationBar() {
        title = "Задачи"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    private func setupViews() {
        view.backgroundColor = .black
        
        searchBar.placeholder = "Search"
        let textField = searchBar.searchTextField
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.barTintColor = .clear
        searchBar.backgroundColor = .black
        searchBar.tintColor = .white
        
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(TodoTableViewCell.self, forCellReuseIdentifier: "TodoCell")
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = UIColor(red: 78/255, green: 85/255, blue: 93/255, alpha: 1.0)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        loadingIndicator.color = .white
        loadingIndicator.hidesWhenStopped = true
        
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
           
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
}

extension TodoListView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return todos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TodoCell", for: indexPath) as! TodoTableViewCell
        let todo = todos[indexPath.row]
        cell.configure(with: todo)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("todos[indexPath.row].describe.count = \(todos[indexPath.row].describe.count)")
        if todos[indexPath.row].describe.count < 45 {
            return 90
        } else {
            return 110
        }
    }
}

extension TodoListView: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        output?.searchTextChanged(searchText)
    }
}

extension TodoListView: TodoTableViewCellDelegate {
    
    func todoCellDidToggle(_ cell: TodoTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let todo = todos[indexPath.row]
        output?.todoToggled(id: todo.id)
    }
    
    func todoCellDidTap(_ cell: TodoTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let todo = todos[indexPath.row]
        showContextMenu(for: todo, at: indexPath)
    }
    
    func showContextMenu(for todo: TodoItemViewModel, at indexPath: IndexPath) {
        currentContextTodo = todo
        
        let contextMenu = ContextMenu()
        contextMenu.delegate = self
        contextMenu.configure(with: todo)
        
        let cell = tableView.cellForRow(at: indexPath)
        
        contextMenu.presentFrom(viewController: self, sourceView: cell ?? view)
    }
}

extension TodoListView: ContextMenuDelegate {
    func contextMenuDidSelectEdit() {
        guard let todo = currentContextTodo else { return }
        output?.editTodo(todo)
    }
    
    func contextMenuDidSelectShare() {
        guard let todo = currentContextTodo else { return }
        output?.shareTodo(todo)
    }
    
    func contextMenuDidSelectDelete() {
        guard let todo = currentContextTodo else { return }
        output?.deleteTodo(todo.id)
    }
}

// MARK: TodoListPresenterOutput
extension TodoListView: TodoListPresenterOutput {
    func displayTodos(_ todos: [TodoItemViewModel]) {
        self.todos = todos
        tableView.reloadData()
    }
    
    func displayError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading() {
        loadingIndicator.startAnimating()
    }
    
    func hideLoading() {
        loadingIndicator.stopAnimating()
    }
}
