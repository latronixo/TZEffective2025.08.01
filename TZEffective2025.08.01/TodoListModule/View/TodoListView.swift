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
    func addNewTodo()
}

final class TodoListView: UIViewController, TodoListViewInput {
    var output: TodoListViewOutput?
    
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    private let loadingIndicator = UIActivityIndicatorView(style: .large)
    
    private let bottomPanel: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.55294118, green: 0.55294118, blue: 0.55686275, alpha: 1.0)
        return view
    }()
    
    private let tasksCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red: 0.9543994069, green: 0.9543994069, blue: 0.9543994069, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.pencil"), for: .normal)
        button.tintColor = UIColor(red: 0.9941777587, green: 0.8433876634, blue: 0.01378514804, alpha: 1.0)
        return button
    }()
    
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
        let searchBarTintColor = UIColor(red: 0.55294118, green: 0.55294118, blue: 0.55686275, alpha: 1.0)
        let textField = searchBar.searchTextField
        textField.textColor = .white
        textField.backgroundColor = UIColor(red: 0.15294118, green: 0.15294118, blue: 0.16078431, alpha: 1.0)
        textField.attributedPlaceholder = NSAttributedString(
            string: "Search",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray]
        )
        if let searchImageView = textField.leftView as? UIImageView {
            searchImageView.tintColor = searchBarTintColor
        }
        
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
        view.addSubview(bottomPanel)
        bottomPanel.addSubview(tasksCountLabel)
        bottomPanel.addSubview(addButton)
        
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        tasksCountLabel.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomPanel.topAnchor),
           
            loadingIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            bottomPanel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomPanel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomPanel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomPanel.heightAnchor.constraint(equalToConstant: 60),
           
            tasksCountLabel.centerXAnchor.constraint(equalTo: bottomPanel.centerXAnchor),
            tasksCountLabel.centerYAnchor.constraint(equalTo: bottomPanel.centerYAnchor),

            addButton.trailingAnchor.constraint(equalTo: bottomPanel.trailingAnchor, constant: -16),
            addButton.topAnchor.constraint(equalTo: bottomPanel.topAnchor, constant: 16),
            addButton.widthAnchor.constraint(equalToConstant: 30),
            addButton.heightAnchor.constraint(equalToConstant: 30),
        ])
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    @objc private func addButtonTapped() {
        output?.addNewTodo()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let textField = searchBar.searchTextField
        let searchBarTintColor = UIColor(red: 0.55294118, green: 0.55294118, blue: 0.55686275, alpha: 1.0)
        
        let microphoneButton = UIButton(type: .system)
        let microphoneImage = UIImage(systemName: "mic.fill")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 14, weight: .medium) // Измените pointSize для размера
        )
        microphoneButton.setImage(microphoneImage, for: .normal)
        microphoneButton.tintColor = searchBarTintColor
        
        textField.rightView = microphoneButton
        textField.rightViewMode = .always
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
        updateTasksCount()
    }
    
    private func updateTasksCount() {
        let count = todos.count
        let taskWord = count == 1 ? "задача" : (count >= 2 && count <= 4 ? "задачи" : "задач")
        tasksCountLabel.text = "\(count) \(taskWord)"
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
