//
//  SignOutViewModel.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/26/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

/// Configures and responds to sign out view controller UI
class SignOutViewModel {
	
	let disposeBag = DisposeBag()
	
	struct Input {
		let didTapSignOutButton: AnyObserver<Void>
	}
	
	struct Output {
		let didSignOut: Observable<Void>
		let errorMessage: Observable<String>
	}
	
	let input: Input
	let output: Output
	
	private let didTapSignOutButtonSubject = PublishSubject<Void>()
	private let didSignOutSubject = PublishSubject<Void>()
	private let errorMessageSubject = PublishSubject<String>()
	
	init(authService: AuthServiceProtocol) {
		
		input = Input(
			didTapSignOutButton: didTapSignOutButtonSubject.asObserver())
		
		output = Output(
			didSignOut: didSignOutSubject.asObservable(),
			errorMessage: errorMessageSubject.asObservable())
		
		// Sign out obsrvable that enables error handling
		let signOut = didTapSignOutButtonSubject
			.flatMapLatest {
				return authService.signOut()
					.materialize()
			}
			.share()
		
		// If no error, sign out was successful
		signOut
			.subscribe(onNext: { [weak self] event in
				guard event.error == nil else {
					return
				}
				self?.didSignOutSubject.onCompleted()
			})
			.disposed(by: disposeBag)
		
		// If a log out error occurs, display it but do not stop future observations
		signOut
			.compactMap { $0.error }
		.subscribe(onNext: { [weak self] error in
			self?.errorMessageSubject.onNext(error.localizedDescription)
		})
		.disposed(by: disposeBag)
	}
}
