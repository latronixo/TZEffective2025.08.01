//
//  ContextMenuViewController.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import UIKit

protocol ContextMenuViewControllerDelegate: AnyObject {
    func contextMenuDidSelectEdit()
    func contextMenuDidSelectShare()
    func contextMenuDidSelectDelete()
}

class ContextMenuViewController: UIViewController {
    
    weak var delegate: ContextMenuViewControllerDelegate?
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.95)
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
        stack.distribution = .fillEqually
        return stack
    }()
    
    private let editButton = createMenuButton(title: "Редактировать", iconName: "edit")
    private let shareButton = createMenuButton(title: "Поделиться", iconName: "share")
    private let deleteButton = createMenuButton(title: "Удалить", iconName: "trash", isDestructive: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupActions()
    }
    
    private static func createMenuButton(title: String, iconName: String, isDestructive: Bool = false) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setTitleColor(isDestructive ? UIColor.red : UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .clear
        button.contentHorizontalAlignment = .left
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        
        if let icon = UIImage(named: iconName) {
            button.setImage(icon, for: .normal)
            button.tintColor = isDestructive ? UIColor.red : UIColor.white
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
            button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        }
        
        return button
    }
    
    private func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(editButton)
        stackView.addArrangedSubview(shareButton)
        stackView.addArrangedSubview(deleteButton)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
        
        // Добавляем tap gesture для закрытия меню при тапе вне его
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editTapped), for: .touchUpInside)
        shareButton.addTarget(self, action: #selector(shareTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteTapped), for: .touchUpInside)
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
            
            // Вычисляем позицию меню
            let menuWidth: CGFloat = 200
            let menuHeight: CGFloat = 150 // Примерная высота для 3 кнопок
            
            var xPosition = sourceFrame.midX - menuWidth / 2
            var yPosition = sourceFrame.maxY + 8 // 8 пунктов отступ от ячейки
            
            // Проверяем, не выходит ли меню за границы экрана
            let screenBounds = UIScreen.main.bounds
            
            // Если меню выходит за правый край экрана
            if xPosition + menuWidth > screenBounds.width - 16 {
                xPosition = screenBounds.width - menuWidth - 16
            }
            
            // Если меню выходит за левый край экрана
            if xPosition < 16 {
                xPosition = 16
            }
            
            // Если меню выходит за нижний край экрана, показываем его выше ячейки
            if yPosition + menuHeight > screenBounds.height - 16 {
                yPosition = sourceFrame.minY - menuHeight - 8
            }
            
            // Устанавливаем позицию через frame
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
