//
//  ObservableType+Extensions.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/26/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

extension ObservableType {
	/// Create an observable that emits a tuple containing the 2 most recent observations
	func currentAndPrevious() -> Observable<(current: Element, previous: Element)> {
		return self.multicast({ () -> PublishSubject<Element> in PublishSubject() }) { (values: Observable) -> Observable<(current: Element, previous: Element)> in
			let pastValues = Observable.merge(values.take(1), values)
			
			return Observable.combineLatest(values.asObservable(), pastValues) { (current, previous) in
				return (current: current, previous: previous)
			}
		}
	}
}
