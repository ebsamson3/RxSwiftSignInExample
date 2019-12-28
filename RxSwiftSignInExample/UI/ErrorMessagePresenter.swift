//
//  ErrorMessagePresenter.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/22/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

/// Presents error alerts with a single "OK" action
struct ErrorMessagePresenter {
	
	let errorMessage: String
	let handler: () -> Void
	
	func present(in viewController: UIViewController) {
		let alert = UIAlertController(
			title: "Error",
			message: errorMessage,
			preferredStyle: .alert)
		
		let action = UIAlertAction(title: "OK", style: .default) { _ in
			self.handler()
		}
		
		alert.addAction(action)
		
		viewController.present(alert, animated: true)
	}
}
