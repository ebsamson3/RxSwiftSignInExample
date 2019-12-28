//
//  FirebaseSignInService.swift
//  Doodler
//
//  Created by Edward Samson on 12/20/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift
import FirebaseAuth

/// Generic reactive wrapper for firebase authorization
class FirebaseAuthService: AuthServiceProtocol {
	
	var isSignedIn: Bool {
		return Auth.auth().currentUser != nil
	}
	
	func createAuthStateListener() -> Observable<User?> {
		Observable.create { observer in
			
			Auth.auth().addStateDidChangeListener { (auth, firebaseUser) in
				guard let firebaseUser = firebaseUser else {
					observer.onNext(nil)
					return
				}
				
				let user = User(
					displayName: firebaseUser.displayName,
					uid: firebaseUser.uid)
				
				observer.onNext(user)
			}
			
			return Disposables.create { }
		}
	}
	
	func signIn(withCredentials credentials: Credentials) -> Observable<Void> {
		return Observable.create { observer in
			
			let email = credentials.email
			let password = credentials.password
			
			Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
				
				if let error = error {
					observer.onError(error)
					return
				}
				
				guard result != nil else {
					observer.onError(AuthServiceError.missingResult)
					return
				}
				
				observer.onCompleted()
			}
			
			return Disposables.create { }
		}
	}
	
	func createUser(withCredentials credentials: Credentials) -> Observable<Credentials> {
		return Observable.create { observer in
			
			let email = credentials.email
			let password = credentials.password
			
			Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
				
				if let error = error {
					observer.onError(error)
					return
				}
				
				guard result != nil else {
					observer.onError(AuthServiceError.missingResult)
					return
				}
				
				observer.onNext(credentials)
				observer.onCompleted()
			}
			
			return Disposables.create { }
		}
	}
	
	func signOut() -> Observable<Void> {
		
		Observable.create { observer in
			do {
				try Auth.auth().signOut()
				observer.onCompleted()
			} catch let error {
				observer.onError(error)
			}
			
			return Disposables.create { }
		}
		
	}
}
