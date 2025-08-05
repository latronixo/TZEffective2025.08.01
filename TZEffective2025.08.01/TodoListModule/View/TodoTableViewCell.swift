//
//  TodoTableViewCell.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 02.08.2025.
//

import UIKit

protocol TodoTableViewCellDelegate: AnyObject {
    func todoCellDidToggle(_ cell: TodoTableViewCell)
    func todoCellDidTap(_ cell: TodoTableViewCell)
}

class TodoTableViewCell: UITableViewCell {
    weak var delegate: TodoTableViewCellDelegate?
    private lazy var containerView: UIView = {
        let element = UIView()
        element.backgroundColor = UIColor(red: 4/255, green: 4/255, blue: 4/255, alpha: 1.0)
        return element
    }()
    private lazy var titleLabel: UILabel = {
        let element = UILabel()
        element.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        element.textColor = .white
        element.numberOfLines = 1
        
        return element
    }()
    private lazy var descriptionLabel: UILabel = {
        let element = UILabel()
        element.font = UIFont.systemFont(ofSize: 14)
        element.textColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        element.numberOfLines = 2
        
        return element
    }()
    private lazy var dateLabel: UILabel = {
        let element = UILabel()
        element.font = UIFont.systemFont(ofSize: 12)
        element.textColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0)
        
        return element
    }()
    private lazy var checkmarkButton: UIButton = {
        let element = UIButton()
        element.layer.cornerRadius = 12
        element.layer.borderWidth = 2
        element.layer.borderColor = UIColor.yellow.cgColor
        
        return element
    }()
   
    private var todo: TodoItemViewModel?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
    
    private func setupViews() {
        backgroundColor = .clear
        selectionStyle = .none

        checkmarkButton.addTarget(self, action: #selector(checkmarkTapped), for: .touchUpInside)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(checkmarkButton)
        
        contentView.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        checkmarkButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            
            checkmarkButton.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            checkmarkButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 8),
            checkmarkButton.widthAnchor.constraint(equalToConstant: 24),
            checkmarkButton.heightAnchor.constraint(equalToConstant: 24),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: checkmarkButton.trailingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            //dateLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            
        ])
        
        setupTapGesture()
    }
    
    func configure(with todo: TodoItemViewModel) {
        self.todo = todo
        titleLabel.text = todo.title
        descriptionLabel.text = todo.describe
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        dateLabel.text = formatter.string(from: todo.createdAt)
        
        updateCheckmarkState()
    }
    
    private func updateCheckmarkState() {
        guard let todo = todo else { return }
        
        titleLabel.attributedText = nil
        titleLabel.text = todo.title
        
        if todo.isCompleted {
            checkmarkButton.backgroundColor = .yellow
            checkmarkButton.setImage(UIImage(systemName: "checkmark"), for: .normal)
            checkmarkButton.tintColor = .black
            titleLabel.alpha = 0.6
            descriptionLabel.alpha = 0.6
            
            let attributedString = NSAttributedString(
                string: todo.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                    .strikethroughColor: UIColor.white
                ]
            )
            titleLabel.attributedText = attributedString
        } else {
            checkmarkButton.backgroundColor = .clear
            checkmarkButton.setImage(nil, for: .normal)
            titleLabel.alpha = 1.0
            descriptionLabel.alpha = 1.0
            
            let attributedString = NSMutableAttributedString(string: todo.title)
            attributedString.removeAttribute(.strikethroughStyle, range: NSRange(location: 0, length: attributedString.length))
            titleLabel.text = todo.title
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // Сбрасываем все состояния ячейки
        todo = nil
        titleLabel.attributedText = nil
        titleLabel.text = nil
        titleLabel.alpha = 1.0
        descriptionLabel.alpha = 1.0
        checkmarkButton.backgroundColor = .clear
        checkmarkButton.setImage(nil, for: .normal)
        delegate = nil
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        delegate?.todoCellDidTap(self)
    }
    
    @objc private func checkmarkTapped() {
        delegate?.todoCellDidToggle(self)
    }
}
