//
//  RouterProtocol.swift
//  Doodler
//
//  Created by Edward Samson on 12/18/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import RxSwift

/// Protocol for router that handles navigation implementation
protocol RouterProtocol: class {
    func push(
		_ drawable: Drawable,
		isAnimated: Bool,
		onNavigateBack: (() -> Void)?)
	
	func pop(_ isAnimated: Bool)
	
	func present(
		_ drawable: Drawable,
		transitioningDelegate: UIViewControllerTransitioningDelegate?,
		isAnimated: Bool)
	
	func dismiss(animated: Bool, completion: (() -> Void)?)
	
	func setRoot(_ drawable: Drawable, hideBar: Bool, animated: Bool)
}




