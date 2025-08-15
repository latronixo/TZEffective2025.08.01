//
//  ContextMenuViewController.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import UIKit

protocol ContextMenuDelegate: AnyObject {
    func contextMenuDidSelectEdit()
    func contextMenuDidSelectShare()
    func contextMenuDidSelectDelete()
}

final class ContextMenu: UIViewController {
    
    weak var delegate: ContextMenuDelegate?
    private var todo: TodoItemViewModel?
    
    // Основной контейнер для всего меню
     private let containerView: UIView = {
         let view = UIView()
         return view
     }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 0
        return stack
    }()
    
    // Вьюха для отображения задачи
    private let todoInfoView = createTodoInfoView()
        
    private let editView = createMenuView(title: "Редактировать", iconName: "edit")
    private let shareView = createMenuView(title: "Поделиться", iconName: "share")
    private let deleteView = createMenuView(title: "Удалить", iconName: "trash", isDestructive: true)
    
    private let separator1 = createSeparator()
    private let separator2 = createSeparator()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
    }
    
    func configure(with todo: TodoItemViewModel) {
        self.todo = todo
        configureTodoInfoView()
    }
    
    private static func createTodoInfoView() -> UIView {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        view.layer.cornerRadius = 8
        
        let titleLabel = UILabel()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        titleLabel.numberOfLines = 1
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
        descriptionLabel.numberOfLines = 0
        
        let dateLabel = UILabel()
        dateLabel.font = UIFont.systemFont(ofSize: 14)
        dateLabel.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        view.addSubview(titleLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(dateLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
                
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            dateLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])
        
        //сохраняем ссылки на labels для последующего обновления
        view.tag = 100
        titleLabel.tag = 101
        descriptionLabel.tag = 102
        dateLabel.tag = 103
        
        return view
    }
    
    private func configureTodoInfoView() {
        guard let titleLabel = todoInfoView.viewWithTag(101) as? UILabel,
              let descriptionLabel = todoInfoView.viewWithTag(102) as? UILabel,
              let dateLabel = todoInfoView.viewWithTag(103) as? UILabel,
              let todo = todo else { return }
        
        titleLabel.text = todo.title
        descriptionLabel.text = todo.describe
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dateLabel.text = formatter.string(from: todo.createdAt)
    }
    
    private func setupViews() {
        //создаем размытость
        let blurEffect = UIBlurEffect(style: .dark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurView)
        view.addSubview(containerView)
        containerView.addSubview(todoInfoView)
        containerView.addSubview(stackView)
        
        stackView.layer.cornerRadius = 8
        stackView.backgroundColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
        
        stackView.addArrangedSubview(editView)
        stackView.addArrangedSubview(separator1)
        stackView.addArrangedSubview(shareView)
        stackView.addArrangedSubview(separator2)
        stackView.addArrangedSubview(deleteView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        todoInfoView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        separator1.translatesAutoresizingMaskIntoConstraints = false
        separator2.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            todoInfoView.topAnchor.constraint(equalTo: containerView.topAnchor),
            todoInfoView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            todoInfoView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            todoInfoView.heightAnchor.constraint(lessThanOrEqualToConstant: 100),
            
            stackView.topAnchor.constraint(equalTo: todoInfoView.bottomAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 36),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            separator1.heightAnchor.constraint(equalToConstant: 0.5),
            separator2.heightAnchor.constraint(equalToConstant: 0.5),
        ])
        
        // Добавляем tap gesture для закрытия меню при тапе вне его
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        let editTap = UITapGestureRecognizer(target: self, action: #selector(editTapped))
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(shareTapped))
        let deleteTap = UITapGestureRecognizer(target: self, action: #selector(deleteTapped))
        
        editView.addGestureRecognizer(editTap)
        shareView.addGestureRecognizer(shareTap)
        deleteView.addGestureRecognizer(deleteTap)
     }
    
    private static func createMenuView(title: String, iconName: String, isDestructive: Bool = false) -> UIView {
        let buttonView = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        titleLabel.textColor = isDestructive ? UIColor.red : UIColor(red: 0.28, green: 0.28, blue: 0.28, alpha: 1.0)
        
        let iconImageView = UIImageView()
        if let icon = UIImage(named: iconName) {
            iconImageView.image = icon
            iconImageView.contentMode = .scaleAspectFit
            iconImageView.tintColor = isDestructive ? UIColor.red : UIColor(red: 0.28, green: 0.28, blue: 0.28, alpha: 1.0)
        }
        
        let emptyView = UIView()
        
        buttonView.addSubview(titleLabel)
        buttonView.addSubview(emptyView)
        buttonView.addSubview(iconImageView)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: buttonView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: emptyView.leadingAnchor),

            emptyView.topAnchor.constraint(equalTo: buttonView.topAnchor),
            emptyView.widthAnchor.constraint(greaterThanOrEqualToConstant: 120),
            emptyView.heightAnchor.constraint(equalToConstant: 50),
            emptyView.bottomAnchor.constraint(equalTo: buttonView.bottomAnchor),
            
            iconImageView.leadingAnchor.constraint(equalTo: emptyView.trailingAnchor),
            iconImageView.trailingAnchor.constraint(equalTo: buttonView.trailingAnchor, constant: -16),
            iconImageView.centerYAnchor.constraint(equalTo: buttonView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),
            
        ])
        
        return buttonView
    }
    
    private static func createSeparator() -> UIView {
        let separator = UIView()
        separator.backgroundColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
        separator.translatesAutoresizingMaskIntoConstraints = false
        return separator
    }
    
    @objc private func backgroundTapped() {
        dismiss(animated: true)
    }
    
    @objc private func editTapped() {
        dismiss(animated: true) {
            self.delegate?.contextMenuDidSelectEdit()
        }
    }
    
    @objc private func shareTapped() {
        dismiss(animated: true) {
            self.delegate?.contextMenuDidSelectShare()
        }
    }
    
    @objc private func deleteTapped() {
        dismiss(animated: true) {
            self.delegate?.contextMenuDidSelectDelete()
        }
    }
    
    func presentFrom(viewController: UIViewController, sourceView: UIView) {
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        viewController.present(self, animated: false) {
            // Позиционируем меню рядом с ячейкой
            let sourceFrame = sourceView.convert(sourceView.bounds, to: self.view)
            let screenBounds = UIScreen.main.bounds
            
            //Фиксированная позиция и ширина
            let xPosition: CGFloat = 25
            var yPosition = sourceFrame.minY
            let menuWidth: CGFloat = sourceFrame.width - 50

            //Вычисляем высоту на основе содержимого
            var menuHeight: CGFloat = 300
            
            //если description многострочный, увеличиваем высоту
            if let todo = self.todo {
                let descriptionLines = Int(todo.describe.count / 40)
                if descriptionLines > 1 {
                    let additionalHeight = CGFloat(descriptionLines - 1) * 20 // 20 пунктов на дополнительную строку
                    menuHeight += additionalHeight
                }
            }
            
            //Проверяем, не выходит ли меню за нижний край экрана
            if yPosition + menuHeight > screenBounds.height - 16 {
                yPosition = screenBounds.height - menuHeight - 16
            }
            
            self.containerView.frame = CGRect(x: xPosition, y: yPosition, width: menuWidth, height: menuHeight)
            
            // Анимация появления
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
            
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = .identity
                self.containerView.alpha = 1
            }
        }
    }
} 
