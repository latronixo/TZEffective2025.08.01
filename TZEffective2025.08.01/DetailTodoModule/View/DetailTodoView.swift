//
//  DetailTodoView.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 03.08.2025.
//

import UIKit

protocol DetailTodoViewInput {
    var output: DetailTodoViewOutput? { get set }
}

protocol DetailTodoViewOutput {
    func viewDidLoad()
    func saveButtonTapped()
    func backButtonTapped()
}

final class DetailTodoView: UIViewController, DetailTodoViewInput {
    var output: DetailTodoViewOutput?
    
    private let titleTextField = UITextField()
    private let dateLabel = UILabel()
    private let descriptionTextView = UITextView()
    
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
        output?.viewDidLoad()
    }
    
    private func setupNavigationBar() {
        title = ""
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Назад",
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Сохранить",
            style: .plain,
            target: self,
            action: #selector(saveButtonTapped)
        )
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
    
    @objc private func saveButtonTapped() {
        output?.saveButtonTapped()
    }
}

extension DetailTodoView: DetailTodoPresenterOutput {
    func displayTodo(_ todo: TodoItemViewModel) {
        configure(with: todo)
    }
    
    func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func closeView() {
        dismiss(animated: true)
    }
    
    func updateTodoInList(id: Int, title: String, description: String) {
        // Вызываем обновление через NotificationCenter
        NotificationCenter.default.post(
            name: NSNotification.Name("TodoUpdated"),
            object: nil,
            userInfo: ["id": id, "title": title, "description": description]
        )
    }
}
