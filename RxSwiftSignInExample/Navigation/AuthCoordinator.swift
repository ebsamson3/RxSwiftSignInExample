//
//  AuthCoordinator.swift
//  Doodler
//
//  Created by Edward Samson on 12/14/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift

class AuthCoordinator: BaseCoordinator {
	
	private let router: RouterProtocol
	private let authService: AuthServiceProtocol
	private let finishFlow: Observable<Void>
	private let finishFlowSubject = PublishSubject<Void>()
	
	init(router: RouterProtocol, authService: AuthServiceProtocol) {
		self.router = router
		self.authService = authService
		self.finishFlow = finishFlowSubject.asObservable()
	}
	
	override func start() -> Observable<Void> {
		switchToSignIn()
		return finishFlow
	}
	
	/// Display sign in
	private func switchToSignIn() {
		let viewModel = SignInFormViewModel(authService: authService)
		
		viewModel.switchToCreateAccount
			.subscribe(onNext: { [weak self] in
				self?.switchToCreateAccount()
			})
			.disposed(by: disposeBag)
		
		// On sign-in, complete the auth flow to deallocate the auth coordinator
		viewModel.didSignIn
			.subscribe(onCompleted: { [weak self] in
				self?.finishFlowSubject.onCompleted()
			})
			.disposed(by: disposeBag)
		
		let viewController = FormViewController(viewModel: viewModel)
		
		// Display alert on sign-in error display
		viewModel.errorMessage
			.subscribe(onNext: { errorMessage in
				
				let presenter = ErrorMessagePresenter(
					errorMessage: errorMessage,
					handler: { })
				
				presenter.present(in: viewController)
			})
			.disposed(by: disposeBag)
		
		router.setRoot(viewController, hideBar: true, animated: true)
	}
	
	/// Display create account
	private func switchToCreateAccount() {
		let viewModel = CreateAccountFormViewModel(authService: authService)
		
		viewModel.switchToSignIn
			.subscribe(onNext: { [weak self] in
				self?.switchToSignIn()
			})
			.disposed(by: disposeBag)
		
		// On sign-in, complete the auth flow to deallocate the auth coordinator
		viewModel.didSignIn
			.subscribe(onCompleted: { [weak self] in
				self?.finishFlowSubject.onCompleted()
			})
			.disposed(by: disposeBag)
		
		let viewController = FormViewController(viewModel: viewModel)
		
		// Display alert on sign-in or create-account error
		viewModel.errorMessage
			.subscribe(onNext: { errorMessage in
				
				let presenter = ErrorMessagePresenter(
					errorMessage: errorMessage,
					handler: { })
				
				presenter.present(in: viewController)
			})
			.disposed(by: disposeBag)
		
		router.setRoot(viewController, hideBar: true, animated: true)
	}
}
