//
//  BaseCoordinator.swift
//  Doodler
//
//  Created by Edward Samson on 12/14/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

/// Base coordinator class with methods for handling child coordinators
class BaseCoordinator: CoordinatorProtocol {
	
	let disposeBag = DisposeBag()
	
	// Strong reference to any child coordinators to prevent deallocation
	var childCoordinators = [CoordinatorProtocol]()
	
	/// Stores child coordinators in memory
	func store(_ childCoordinator: CoordinatorProtocol) {
		for coordinator in childCoordinators {
			if coordinator === childCoordinator { return }
		}
		childCoordinators.append(childCoordinator)
	}
	
	/// Frees child coordinator from memory
	func free(_ childCoordinator: CoordinatorProtocol?) {
        guard
			childCoordinators.isEmpty == false,
			let childCoordinator = childCoordinator
		else {
			return
		}
        
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === childCoordinator {
                childCoordinators.remove(at: index)
                break
            }
        }
    }
	
	/// Start child coordinator and return an observable that deallocates the child on completion
	func coordinate(to coordinator: CoordinatorProtocol) -> Observable<Void> {
		store(coordinator)
		return coordinator.start()
			.do(onCompleted: { [weak self] in
				self?.free(coordinator)
			})
	}
	
	/// Starts the coordinator. Subclasses must override this method.
	func start() -> Observable<Void> {
		fatalError("Must override start function")
	}
}
