//
//  SignInServiceProtocol.swift
//  Doodler
//
//  Created by Edward Samson on 12/20/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

enum AuthServiceError: LocalizedError {
	case missingResult
}

/// Generic user authorization manager protocol
protocol AuthServiceProtocol {
	var isSignedIn: Bool { get }
	
	func createAuthStateListener() -> Observable<User?>
	func signIn(withCredentials credentials: Credentials) -> Observable<Void>
	func createUser(withCredentials credentials: Credentials) -> Observable<Credentials>
	func signOut() -> Observable<Void>
}
