//
//  FormInputCellViewModel.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/16/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

/// Instantiates and configures FormInputCells
class FormInputCellViewModel {

	struct Input {
		let text: AnyObserver<String>
		let didEndEditing: AnyObserver<Void>
		let shouldBecomeFirstResponder: AnyObserver<Void>
	}
	
	struct Output {
		let text: Observable<String>
		let isValid: Observable<Bool>
		let didEndEditing: Observable<Void>
		let shouldBecomeFirstResponder: Observable<Void>
	}
	
	let disposeBag = DisposeBag()
	
	let input: Input
	let output: Output
	
	private let textSubject = BehaviorSubject<String>(value: "")
	private let isValidSubject = BehaviorSubject<Bool>(value: false)
	private let didEndEditingSubject = PublishSubject<Void>()
	private let shouldBecomeFirstResponderSubject = PublishSubject<Void>()
	
	let title: String?
	let placeholder: String
	let errorMessage: String
	let isSecureTextEntry: Bool
	let textContentType: UITextContentType?
	let keyboardType: UIKeyboardType
	let textValidator: TextValidator
	
	init(
		title: String?,
		placeholder: String,
		errorMessage: String,
		isSecureTextEntry: Bool,
		textContentType: UITextContentType? = nil,
		keyboardType: UIKeyboardType = .default,
		textValidator: TextValidator)
	{
		self.title = title
		self.placeholder = placeholder
		self.errorMessage = errorMessage
		self.isSecureTextEntry = isSecureTextEntry
		self.textContentType = textContentType
		self.keyboardType = keyboardType
		self.textValidator = textValidator
		
		input = Input(
			text: textSubject.asObserver(),
			didEndEditing: didEndEditingSubject.asObserver(),
			shouldBecomeFirstResponder: shouldBecomeFirstResponderSubject.asObserver())
		
		output = Output(
			text: textSubject.asObservable(),
			isValid: isValidSubject.asObservable(),
			didEndEditing: didEndEditingSubject.asObservable(),
			shouldBecomeFirstResponder: shouldBecomeFirstResponderSubject.asObservable())
		
		// Use injected text validator to validate the bound cell's textfield text and pass the result to an output observable so that downstream UI changes can be made.
		textValidator.validate(output.text)
			.subscribe(onNext: { [weak self] in
				self?.isValidSubject.onNext($0)
			})
			.disposed(by: disposeBag)
	}
}

extension FormInputCellViewModel: CellRepresentable {
	static func registerCell(tableView: UITableView) {
		tableView.register(FormInputCell.self, forCellReuseIdentifier: FormInputCell.reuseIdentifier)
	}
	
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: FormInputCell.reuseIdentifier,
			for: indexPath)
		
		if let formInputCell = cell as? FormInputCell {
			formInputCell.configureWithViewModel(self)
		}
		
		return cell
	}
}
