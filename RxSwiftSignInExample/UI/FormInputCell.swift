//
//  FormInputCell.swift
//  Doodler
//
//  Created by Edward Samson on 12/16/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift

/// A cell with a validatable text field. Can be grouped to create UITableView forms.
class FormInputCell: UITableViewCell, Configurable {
	typealias T = FormInputCellViewModel
	
	static let reuseIdentifier = "FormInputCell"
	
	var title: String? {
		didSet {
			titleLabel.text = title
		}
	}
	
	var placeholder: String? = nil {
		didSet {
			textField.placeholder = placeholder
		}
	}
	
	var errorMessage: String? {
		didSet {
			errorLabel.text = errorMessage
		}
	}
	
	var isSecureTextEntry: Bool = false {
		didSet {
			textField.isSecureTextEntry = isSecureTextEntry
		}
	}
	
	var textContentType: UITextContentType? = nil {
		didSet {
			textField.textContentType = textContentType
		}
	}
	
	var keyboardType: UIKeyboardType = .default {
		didSet {
			textField.keyboardType = keyboardType
		}
	}
	
	var disposeBag = DisposeBag()
	
	let titleLabel = UILabel()
	
	let errorLabel: UILabel = {
		let label = UILabel()
		label.textColor = .red
		return label
	}()
	
	lazy var textField: UITextField = {
		let textField = UITextField()
		textField.layer.borderColor = UIColor.lightGray.cgColor
		textField.layer.borderWidth = 1
		textField.autocapitalizationType = .none
		textField.autocorrectionType = .no
		textField.borderStyle = .roundedRect
		return textField
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		disposeBag = DisposeBag()
	}
	
	private func configure() {
		contentView.addSubview(titleLabel)
		contentView.addSubview(textField)
		contentView.addSubview(errorLabel)

		titleLabel.translatesAutoresizingMaskIntoConstraints = false
		textField.translatesAutoresizingMaskIntoConstraints = false
		errorLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let margins = contentView.layoutMarginsGuide
		
		NSLayoutConstraint.activate([
			titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).withPriority(.defaultHigh),
			titleLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
			textField.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
			textField.trailingAnchor.constraint(equalTo: margins.trailingAnchor).withPriority(.defaultHigh),
			textField.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
			errorLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
			errorLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).withPriority(.defaultHigh),
			errorLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).withPriority(.defaultHigh),
			errorLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor)
		])
	}
	
	func configureWithViewModel(_ viewModel: FormInputCellViewModel) {
		
		// Binding textfield text to the view model's observable
		textField.rx.text
			.orEmpty
			.observeOn(MainScheduler.asyncInstance)
			.distinctUntilChanged()
			.throttle(.milliseconds(100), scheduler: MainScheduler.asyncInstance)
			.subscribe(viewModel.input.text)
			.disposed(by: disposeBag)
		
		// Binding the viewmodel's text output to the cell's textfield. Filtering out when the current and previous observations match to have two-way binding w/o an infinte loop.
		viewModel.output.text
			.currentAndPrevious()
			.filter { $0.current != $0.previous }
			.map { $0.current }
			.asDriver(onErrorJustReturn: "")
			.drive(textField.rx.text.orEmpty)
			.disposed(by: disposeBag)

		// The view model validates the textfield's text and the result determines whether or not the cell's error message is displayed.
		viewModel.output.isValid
			.asDriver(onErrorJustReturn: false)
			.drive(errorLabel.rx.isHidden)
			.disposed(by: disposeBag)
		
		// Notify the view model when the return button is pressed
		textField.rx.controlEvent(.editingDidEndOnExit)
			.subscribe(viewModel.input.didEndEditing)
			.disposed(by: disposeBag)
		
		// The view model can notify the cell when it should become the first responder. Used the .editingDidEndOnExit observable to pass first responder status from on cell's textfield to another.
		viewModel.output.shouldBecomeFirstResponder
			.subscribe(onNext: { [weak self] in
				self?.textField.becomeFirstResponder()
			})
			.disposed(by: disposeBag)
		
		title = viewModel.title
		placeholder = viewModel.placeholder
		errorMessage = viewModel.errorMessage
		textField.isSecureTextEntry = viewModel.isSecureTextEntry
		textContentType = viewModel.textContentType
	}
}
