//
//  MainCoordinator.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/26/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

class MainCoordinator: BaseCoordinator {
	
	let router: RouterProtocol
	let authService: AuthServiceProtocol
	private let finishFlow: Observable<Void>
	private let finishFlowSubject = PublishSubject<Void>()
	
	init(router: RouterProtocol, authService: AuthServiceProtocol) {
		self.router = router
		self.authService = authService
		self.finishFlow = finishFlowSubject.asObservable()
	}
	
	override func start() -> Observable<Void> {

		let viewModel = SignOutViewModel(authService: authService)
		let viewController = SignOutViewController(viewModel: viewModel)

		// Display alert on sign out error
		viewModel.output.errorMessage
			.subscribe(onNext: { errorMessage in

				let presenter = ErrorMessagePresenter(
					errorMessage: errorMessage,
					handler: { })

				presenter.present(in: viewController)
			})
			.disposed(by: disposeBag)

		router.setRoot(viewController, hideBar: false, animated: true)

		return viewModel.output.didSignOut
	}
}
