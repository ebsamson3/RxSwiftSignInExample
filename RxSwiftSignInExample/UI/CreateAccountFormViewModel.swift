//
//  SignUpControllerViewModel.swift
//  Doodler
//
//  Created by Edward Samson on 12/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// Configures a table view controller to become a create account form
class CreateAccountFormViewModel: TableViewRepresentable, LoadingRepresentable {
	
	let disposeBag = DisposeBag()
	
	private lazy var headerCellViewModel = TextCellViewModel(
		text: "Welcome!",
		fontSize: 40,
		cellHeight: 170)
	
	private lazy var emailCellViewModel: FormInputCellViewModel = {
		let textValidator = RegexTextValidator(
			regex: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}")
		
		return FormInputCellViewModel(
			title: "Email:",
			placeholder: "me@example.com",
			errorMessage: "Invalid email format",
			isSecureTextEntry: false,
			textContentType: .oneTimeCode, // One time code used to stop strong password suggestions
			keyboardType: .emailAddress,
			textValidator: textValidator)
	}()
	
	private lazy var passwordCellViewModel: FormInputCellViewModel = {
		let textValidator = RegexTextValidator(
			regex: "[A-Z0-9a-z._%+-?]{6,18}")
		
		return FormInputCellViewModel(
			title: "Password:",
			placeholder: "",
			errorMessage: "Password must be between 6-18 characters",
			isSecureTextEntry: true,
			textContentType: .oneTimeCode, // One time code used to stop strong password suggestions
			textValidator: textValidator)
	}()
	
	private lazy var confirmPasswordCellViewModel: FormInputCellViewModel = {
		
		// Use a text validator that checks whether or not the confirm passowrd text is equal to the password text
		let textValidator = IsEqualTextValidator(
			template: passwordCellViewModel.output.text)
		
		return FormInputCellViewModel(
			title: "Confirm Password:",
			placeholder: "",
			errorMessage: "Passwords must be equal",
			isSecureTextEntry: true,
			textContentType: .oneTimeCode, // One time code used to stop strong password suggestions
			textValidator: textValidator)
	}()
	
	private lazy var createAccountButtonCellViewModel: ButtonCellViewModel = {
		let isValid = Observable.combineLatest([
			emailCellViewModel.output.isValid,
			passwordCellViewModel.output.isValid,
			confirmPasswordCellViewModel.output.isValid
			])
			.map { !$0.contains(false) }
		
		return ButtonCellViewModel(title: "Create Account", isValid: isValid)
	}()
	
	private lazy var alreadyHaveAccountCellViewModel = TextCellViewModel(
		text: "Already have an account?",
		fontSize: 16,
		cellHeight: 44)
	
	private lazy var switchToSignInCellViewModel = ButtonCellViewModel(title: "Switch to Sign-In")
	
	lazy var cellViewModels: Observable<[CellRepresentable]> = Observable.just([
		headerCellViewModel,
		emailCellViewModel,
		passwordCellViewModel,
		confirmPasswordCellViewModel,
		createAccountButtonCellViewModel,
		alreadyHaveAccountCellViewModel,
		switchToSignInCellViewModel
	])
	
	private var cellViewModelTypes: [CellRepresentable.Type] = [
		TextCellViewModel.self,
		FormInputCellViewModel.self,
		ButtonCellViewModel.self
	]
	
	let isLoading: Observable<Bool>
	let switchToSignIn: Observable<Void>
	let didSignIn: Observable<Void>
	let errorMessage: Observable<String>
	
	private let switchToSignInSubject = PublishSubject<Void>()
	private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
	private let didSignInSubject = PublishSubject<Void>()
	private let errorMessageSubject = PublishSubject<String>()
	
	init(authService: AuthServiceProtocol) {
		
		isLoading = isLoadingSubject.asObservable()
		switchToSignIn = switchToSignInSubject.asObservable()
		didSignIn = didSignInSubject.asObservable()
		errorMessage = errorMessageSubject.asObservable()
		
		// Converts text field inputs into an email + password observable
		let credentialsObservable = Observable.combineLatest(
			emailCellViewModel.output.text,
			passwordCellViewModel.output.text)
			.map { Credentials(email: $0, password: $1) }
		
		// Observable for account creation status that doesn't stop emitting when an error is thrown
		let createAccount = createAccountButtonCellViewModel.output.didTap
			.withLatestFrom(credentialsObservable)
			.do(onNext: { [weak self] _ in
				self?.isLoadingSubject.onNext(true)
			})
			.flatMapLatest {
				return authService.createUser(withCredentials: $0)
					.materialize()
			}
			.share()
		
		// If create account result does not throw an error proceed to sign in
		let signIn = createAccount
			.compactMap { $0.element }
			.flatMapLatest {
				return authService.signIn(withCredentials: $0)
					.materialize()
			}
			.share()
		
		// If sign in does not throw an error, complete the didSignIn observable
		signIn
			.subscribe(onNext: { [weak self] event in
				guard event.error == nil else {
					return
				}
				self?.didSignInSubject.onCompleted()
				self?.isLoadingSubject.onNext(false)
			})
			.disposed(by: disposeBag)
		
		// If an account creation error occurs, display it but do not stop future observations
		createAccount
			.compactMap { $0.error}
			.subscribe(onNext: { [weak self] _ in
				self?.isLoadingSubject.onNext(false)
				self?.passwordCellViewModel.input.text.onNext("")
				self?.confirmPasswordCellViewModel.input.text.onNext("")
				self?.errorMessageSubject
					.onNext("Unable to create account")
			})
			.disposed(by: disposeBag)
		
		// If a sign in error occurs, display it but do not stop future observations
		signIn
			.compactMap { $0.error}
			.subscribe(onNext: { [weak self] _ in
				self?.isLoadingSubject.onNext(false)
				self?.passwordCellViewModel.input.text.onNext("")
				self?.confirmPasswordCellViewModel.input.text.onNext("")
				self?.errorMessageSubject
					.onNext("Unable to sign in")
			})
			.disposed(by: disposeBag)
		
		// If the email textfield did end editing make the password textfield first responder
		emailCellViewModel.output.didEndEditing
			.subscribe(passwordCellViewModel.input.shouldBecomeFirstResponder)
			.disposed(by: disposeBag)
		
		// If the password textfield did end editing make the confirm password textfield first responder
		passwordCellViewModel.output.didEndEditing
			.subscribe(confirmPasswordCellViewModel.input.shouldBecomeFirstResponder)
			.disposed(by: disposeBag)
		
		// Switch to sign in
		switchToSignInCellViewModel.output.didTap
			.subscribe(switchToSignInSubject.asObserver())
			.disposed(by: disposeBag)
	}
	
	func registerCells(to tableView: UITableView) {
		for cellViewModelType in cellViewModelTypes {
			cellViewModelType.registerCell(tableView: tableView)
		}
	}
}

