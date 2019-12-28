//
//  AppCoordinator.swift
//  Doodler
//
//  Created by Edward Samson on 12/14/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift
import FirebaseAuth

/// Coordinator that encompasses all app flows
class AppCoordinator: BaseCoordinator {
	
	let router: RouterProtocol
	let authService = FirebaseAuthService()
	
	init(window: UIWindow) {
		
		// Instantiate app navigation controller
		let navigationController = UINavigationController()
		self.router = Router(navigationController: navigationController)
		super.init()
		
		// Set window's root view controller to navigation controller
		window.rootViewController = navigationController
		window.makeKeyAndVisible()
	}
	
	override func start() -> Observable<Void> {
		
		let viewController = LoadingViewController()

		// Display loading view while waiting for initial auth state
		router.setRoot(
			viewController,
			hideBar: !authService.isSignedIn,
			animated: false)
		
		// Create an observable that emits the autorization status
		authService.createAuthStateListener()
			.subscribe(onNext: { [weak self] user in
				
				guard let strongSelf = self else {
					return
				}
				
				guard user != nil else {
					// If auth status is nil display auth flow
					let authCoordinator = AuthCoordinator(
						router: strongSelf.router,
						authService: strongSelf.authService)
					
					strongSelf.coordinate(to: authCoordinator)
						.subscribe()
						.disposed(by: strongSelf.disposeBag)
					return
				}
				
				// If auth status is signed-in start the main flow
				let mainCoordinator = MainCoordinator(
					router: strongSelf.router,
					authService: strongSelf.authService)
				
				strongSelf.coordinate(to: mainCoordinator)
					.subscribe()
					.disposed(by: strongSelf.disposeBag)
			})
			.disposed(by: disposeBag)
		
		// Never deallocate app flow while app is running
		return Observable.never()
	}
}
