//
//  SignInFormViewModel.swift
//  Doodler
//
//  Created by Edward Samson on 12/18/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

/// Configures a table view controller to become a sign-in form. 
class SignInFormViewModel: TableViewRepresentable, LoadingRepresentable {
	
	let disposeBag = DisposeBag()
	
	private lazy var headerCellViewModel = TextCellViewModel(
		text: "Welcome Back!",
		fontSize: 40,
		cellHeight: 170)
	
	
	private lazy var emailFieldCellViewModel: FormInputCellViewModel = {
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
	
	private lazy var passwordFieldCellViewModel: FormInputCellViewModel = {
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
	
	private lazy var signInButtonCellViewModel: ButtonCellViewModel = {
		// Enable button if all text field are valid and loading is false
		let isValid = Observable.combineLatest([
			emailFieldCellViewModel.output.isValid,
			passwordFieldCellViewModel.output.isValid,
			isLoading.map { !$0 }
			])
			.map { !$0.contains(false) }
		
		return ButtonCellViewModel(title: "Sign-In", isValid: isValid)
	}()
	
	private lazy var alreadyHaveAccountCellViewModel = TextCellViewModel(
		text: "Don't already have an account?",
		fontSize: 16,
		cellHeight: 44)
	
	private lazy var switchToSignInCellViewModel = ButtonCellViewModel(title: "Switch to Create Account")
	
	lazy var cellViewModels: Observable<[CellRepresentable]> = Observable.just([
		headerCellViewModel,
		emailFieldCellViewModel,
		passwordFieldCellViewModel,
		signInButtonCellViewModel,
		alreadyHaveAccountCellViewModel,
		switchToSignInCellViewModel
	])
	
	private var cellViewModelTypes: [CellRepresentable.Type] = [
		TextCellViewModel.self,
		FormInputCellViewModel.self,
		ButtonCellViewModel.self
	]
	
	let switchToCreateAccount: Observable<Void>
	let isLoading: Observable<Bool>
	let didSignIn: Observable<Void>
	let errorMessage: Observable<String>
	
	private let switchToCreateAccountSubject = PublishSubject<Void>()
	private let isLoadingSubject = BehaviorSubject<Bool>(value: false)
	private let didSignInSubject = PublishSubject<Void>()
	private let errorMessageSubject = PublishSubject<String>()
	
	init(authService: AuthServiceProtocol) {
		
		switchToCreateAccount = switchToCreateAccountSubject.asObservable()
		isLoading = isLoadingSubject.asObservable()
		didSignIn = didSignInSubject.asObservable()
		errorMessage = errorMessageSubject.asObservable()
		
		// Converts text field inputs into an email + password observable
		let credentialsObservable = Observable.combineLatest(
			emailFieldCellViewModel.output.text,
			passwordFieldCellViewModel.output.text)
			.map { Credentials(email: $0, password: $1) }
		
		// Observable for sign in status that doesn't stop emitting when an error is thrown
		let signIn = signInButtonCellViewModel.output.didTap
			.withLatestFrom( credentialsObservable )
			.do(onNext: { [weak self] _ in
				self?.isLoadingSubject.onNext(true)
			})
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
		
		// If a sign in error occurs, display it but do not stop future observations
		signIn
			.compactMap { $0.error}
			.subscribe(onNext: { [weak self] _ in
				self?.isLoadingSubject.onNext(false)
				self?.passwordFieldCellViewModel.input.text.onNext("")
				self?.errorMessageSubject
					.onNext("Unable to sign in")
			})
			.disposed(by: disposeBag)
		
		// If the email textfield did end editing make the password textfield first responder
		emailFieldCellViewModel.output.didEndEditing
			.subscribe(passwordFieldCellViewModel.input.shouldBecomeFirstResponder)
			.disposed(by: disposeBag)
		
		// Switch to create account 
		switchToSignInCellViewModel.output.didTap
			.subscribe(switchToCreateAccountSubject.asObserver())
			.disposed(by: disposeBag)
	}
	
	func registerCells(to tableView: UITableView) {
		for cellViewModelType in cellViewModelTypes {
			cellViewModelType.registerCell(tableView: tableView)
		}
	}
}

