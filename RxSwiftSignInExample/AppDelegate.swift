//
//  AppDelegate.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/28/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import Firebase
import RxSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	let disposeBag = DisposeBag()
	
	var window: UIWindow?
	var coordinator: CoordinatorProtocol?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		FirebaseApp.configure()
		window = UIWindow(frame: UIScreen.main.bounds)
		coordinator = AppCoordinator(window: window!)
		
		coordinator?.start()
			.subscribe()
			.disposed(by: disposeBag)
		
		return true
	}
}
