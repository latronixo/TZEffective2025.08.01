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
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.7490196824, green: 0.7490196824, blue: 0.7490196824, alpha: 1)
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
    
    private func setupViews() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        
        view.addSubview(containerView)
        containerView.addSubview(stackView)
        
        stackView.addArrangedSubview(editView)
        stackView.addArrangedSubview(separator1)
        stackView.addArrangedSubview(shareView)
        stackView.addArrangedSubview(separator2)
        stackView.addArrangedSubview(deleteView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
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
            
            // Вычисляем позицию меню
            let menuWidth: CGFloat = 300
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
