//
//  Router.swift
//  Doodler
//
//  Created by Edward Samson on 12/18/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift

/// Implements navigation controller methods and manages back-button-triggered events
class Router : NSObject, RouterProtocol {

    let navigationController: UINavigationController
	private var animationController: UIViewControllerAnimatedTransitioning?
	
	// Back-button-triggered closures for all view controllers in the nav stack
    private var closures: [String: () -> Void] = [:]

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
        self.navigationController.delegate = self
    }

    func push(
		_ drawable: Drawable,
		isAnimated: Bool,
		onNavigateBack closure: (() -> Void)?)
	{
        guard let viewController = drawable.viewController else {
            return
        }

        if let closure = closure {
            closures.updateValue(
				closure,
				forKey: viewController.description)
        }
		
        navigationController.pushViewController(
			viewController,
			animated: isAnimated)
    }
	
	func pop(_ isAnimated: Bool) {
		guard
			let viewController = navigationController.popViewController(animated: isAnimated)
		else {
			return
		}
		executeClosure(viewController)
	}
	
	func present(
		_ drawable: Drawable,
		transitioningDelegate: UIViewControllerTransitioningDelegate?,
		isAnimated: Bool)
	{
		
		guard let viewController = drawable.viewController else {
            return
        }
		
		viewController.transitioningDelegate = transitioningDelegate
		viewController.modalPresentationStyle = .custom
		
		navigationController.present(
			viewController,
			animated: isAnimated)
	}
	
	func dismiss(
		animated: Bool,
		completion: (() -> Void)?)
	{
		navigationController.dismiss(animated: animated, completion: completion)
	}
	
	func setRoot(
		_ drawable: Drawable,
		hideBar: Bool,
		animated: Bool)
	{
        guard let viewController = drawable.viewController else {
            return
        }
		
		if animated {
			// Custom fade-in animation used in setting the navigation controller's root VC
			animationController = FadeIn(
				navigationController,
				hideBar: hideBar)
			
			navigationController.setViewControllers(
				[viewController],
				animated: true)
			
			// Remove the animation after the root is set
			animationController = nil
		} else {
			navigationController.setViewControllers(
				[viewController],
				animated: false)
			
			navigationController.isNavigationBarHidden = hideBar
		}
    }

	/// Execute the back-button-triggered closure for the given view controller
    private func executeClosure(_ viewController: UIViewController) {
        guard
			let closure = closures.removeValue(forKey: viewController.description)
		else {
			return
		}
        closure()
    }
}

/// MARK: UINavigationControllerDelegate
extension Router : UINavigationControllerDelegate {
    func navigationController(
		_ navigationController: UINavigationController,
		didShow viewController: UIViewController,
		animated: Bool)
	{
		// Get previous view controller for of the navigation controller's show operation
        guard
			let previousController = navigationController.transitionCoordinator?.viewController(forKey: .from),
            !navigationController.viewControllers.contains(previousController)
		else {
			return
        }
		
		// Execute the previous controller's onNavigateBack closure
        executeClosure(previousController)
    }
	
	func navigationController(
		_ navigationController: UINavigationController,
		animationControllerFor operation: UINavigationController.Operation,
		from fromVC: UIViewController,
		to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning?
	{
		// For every navigation controller operation, use the router's animation controller if it is set
		return animationController
	}
}
