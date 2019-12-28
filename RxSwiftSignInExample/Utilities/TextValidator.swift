//
//  TextValidator.swift
//  Doodler
//
//  Created by Edward Samson on 12/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

protocol TextValidator {
	func validate(_ text: Observable<String>) -> Observable<Bool>
}

// Validates text based on a supplied regular expression
struct RegexTextValidator: TextValidator {
	var regex: String
	
	init(regex: String) {
		self.regex = regex
	}
	
	func validate(_ text: Observable<String>) -> Observable<Bool> {
		return text.map {
			let test = NSPredicate(format: "SELF MATCHES %@", self.regex)
			return test.evaluate(with: $0)
		}
	}
}

// Validates text if it is equal to the observation of another text observable
struct IsEqualTextValidator: TextValidator {
	
	let template: Observable<String>
	
	init(template: Observable<String>) {
		self.template = template
	}
	
	func validate(_ text: Observable<String>) -> Observable<Bool> {
		return Observable.combineLatest(text, template) {
			return $0 == $1
		}
	}
}

