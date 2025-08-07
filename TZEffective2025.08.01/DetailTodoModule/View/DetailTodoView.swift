//
//  DetailTodoView.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 03.08.2025.
//

import UIKit

protocol TodoUpdateListener: AnyObject {
    func update(model: TodoUpdateModel)
}

struct TodoUpdateModel {
    let id: Int
    let title: String
    let description: String
    let isNew: Bool
}

protocol DetailTodoViewInput {
    func displayTodo(_ todo: TodoItemViewModel)
    func showError(_ message: String)
    func closeView()
}

protocol DetailTodoViewOutput {
    func viewDidLoad()
    func backButtonTapped()
}

final class DetailTodoView: UIViewController {
    var output: DetailTodoViewOutput?
    
    private let titleTextField = UITextField()
    private let dateLabel = UILabel()
    private let descriptionTextView = UITextView()
    
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        output?.viewDidLoad()
    }
    
    private func setupNavigationBar() {
        title = ""
        let backButton = UIBarButtonItem(
            title: "Назад",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        backButton.tintColor = UIColor(red: 0.9941777587, green: 0.8433876634, blue: 0.01378514804, alpha: 1.0)
                
        navigationItem.leftBarButtonItem = backButton
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        
        titleTextField.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        titleTextField.textColor = .white
        titleTextField.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleTextField.placeholder = "Название задачи"
        titleTextField.layer.cornerRadius = 8
        
        dateLabel.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        dateLabel.textColor = .gray
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.layer.cornerRadius = 8
        
        descriptionTextView.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        descriptionTextView.textColor = .white
        descriptionTextView.font = UIFont.systemFont(ofSize: 16)
        descriptionTextView.layer.cornerRadius = 8
        
        view.addSubview(titleTextField)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
        
        titleTextField.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            titleTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),
            
            dateLabel.topAnchor.constraint(equalTo: titleTextField.bottomAnchor, constant: 20),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            dateLabel.heightAnchor.constraint(equalToConstant: 30),
            
            descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 20),
            descriptionTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
        ])
    }
    
    func configure(with todo: TodoItemViewModel) {
        titleTextField.text = todo.title
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        
        dateLabel.text = formatter.string(from: todo.createdAt)
        descriptionTextView.text = todo.describe
    }
    
    func getEditedData() -> (title: String, description: String) {
        return (title: titleTextField.text ?? "", description: descriptionTextView.text ?? "")
    }
    
    @objc private func backButtonTapped() {
        output?.backButtonTapped()
    }
 }

extension DetailTodoView: DetailTodoViewInput {
    func displayTodo(_ todo: TodoItemViewModel) {
        DispatchQueue.main.async { [weak self] in
            self?.configure(with: todo)
        }
    }
    
    func showError(_ message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }
    
    func closeView() {
        DispatchQueue.main.async { [weak self] in
            self?.dismiss(animated: true)
        }
    }
}

