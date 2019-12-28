//
//  Coordinator.swift
//  Doodler
//
//  Created by Edward Samson on 12/14/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

/// Protocol for class that handles app navigation and data flow
protocol CoordinatorProtocol: class {
	func start() -> Observable<Void>
}
