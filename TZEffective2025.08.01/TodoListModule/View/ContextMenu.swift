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

class ContextMenu: UIViewController {
    
    weak var delegate: ContextMenuDelegate?
    private var todo: TodoItemViewModel?
    
    // Основной контейнер для всего меню
     private let containerView: UIView = {
         let view = UIView()
         view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1.0)
         view.layer.cornerRadius = 12
         view.layer.shadowColor = UIColor.black.cgColor
         view.layer.shadowOffset = CGSize(width: 0, height: 4)
         view.layer.shadowRadius = 8
         view.layer.shadowOpacity = 0.3
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
    private let separator3 = createSeparator()

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
        titleLabel.textColor = UIColor(red: 0.28, green: 0.28, blue: 0.28, alpha: 1.0)
        titleLabel.numberOfLines = 1
        
        let descriptionLabel = UILabel()
        descriptionLabel.font = UIFont.systemFont(ofSize: 14)
        descriptionLabel.textColor = UIColor(red: 0.45, green: 0.45, blue: 0.45, alpha: 1.0)
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
        let blurEffect = UIBlurEffect(style: .systemChromeMaterialDark)
        let blurView = UIVisualEffectView(effect: blurEffect)
        blurView.frame = view.bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        view.addSubview(blurView)
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(todoInfoView)
        stackView.addArrangedSubview(separator1)
        stackView.addArrangedSubview(editView)
        stackView.addArrangedSubview(separator2)
        stackView.addArrangedSubview(shareView)
        stackView.addArrangedSubview(separator3)
        stackView.addArrangedSubview(deleteView)
        
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        //todoInfoView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
//            todoInfoView.widthAnchor.constraint(equalToConstant: 300),
//            todoInfoView.heightAnchor.constraint(equalToConstant: 80),
            
//            containerView.topAnchor.constraint(equalTo: todoDisplayView.bottomAnchor, constant: 8),
//            containerView.leadingAnchor.constraint(equalTo: todoDisplayView.leadingAnchor),
//            containerView.trailingAnchor.constraint(equalTo: todoDisplayView.trailingAnchor),
            
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
//            todoInfoView.topAnchor.constraint(equalTo: todoDisplayView.topAnchor),
//            todoInfoView.leadingAnchor.constraint(equalTo: todoDisplayView.leadingAnchor),
//            todoInfoView.trailingAnchor.constraint(equalTo: todoDisplayView.trailingAnchor),
//            todoInfoView.bottomAnchor.constraint(equalTo: todoDisplayView.bottomAnchor),
//            
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
        buttonView.backgroundColor = .clear
        
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
            // Вычисляем позицию меню после показа
            let sourceFrame = sourceView.convert(sourceView.bounds, to: self.view)
            
            //вычисляем позицию меню
            let menuWidth: CGFloat = 300
            let menuHeight: CGFloat = 200
            
            var xPosition = sourceFrame.midX - menuWidth / 2
            var yPosition = sourceFrame.maxY + 8
            
            //Проверяем, не вызодит ли меню за границы экрана
            let screenBounds = UIScreen.main.bounds
            if xPosition + menuWidth > screenBounds.width - 16 {
                xPosition = screenBounds.width - menuWidth - 16
            }
            if xPosition < 16 {
                xPosition = 16
            }
            if yPosition + menuHeight > screenBounds.height - 16 {
                yPosition = sourceFrame.minY - menuHeight - 8
            }
            
            self.containerView.frame = CGRect(x: xPosition, y: yPosition, width: menuWidth, height: menuHeight)
            
            // Анимация появления
            self.containerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            self.containerView.alpha = 0
//            self.menuContainerView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
//            self.menuContainerView.alpha = 0
            
            UIView.animate(withDuration: 0.2) {
                self.containerView.transform = .identity
                self.containerView.alpha = 1
//                self.menuContainerView.transform = .identity
//                self.menuContainerView.alpha = 1
            }
        }
    }
} 
