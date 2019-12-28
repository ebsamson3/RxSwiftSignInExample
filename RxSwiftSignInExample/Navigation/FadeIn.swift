//
//  FadeIn.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/27/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

/// Animation controller switches a navigation controller's animation to a fade in
class FadeIn: NSObject, UIViewControllerAnimatedTransitioning {
	
	var hideBar: Bool
	weak var navigationController: UINavigationController?
	
	init(
		_ navigationController: UINavigationController,
		hideBar: Bool)
	{
		self.navigationController = navigationController
		self.hideBar = hideBar
	}
	
	func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
		return Double(UINavigationController.hideShowBarDuration)
	}
	
	func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
		guard let toViewController = transitionContext.viewController(forKey: .to) else {
			return
		}
		
		let containerView = transitionContext.containerView
		
		toViewController.view.alpha = 0.0
		containerView.addSubview(toViewController.view)
		
		let duration = transitionDuration(using: transitionContext)
		
		UIView.animate(
			withDuration: duration,
			delay: 0,
			options: .curveEaseInOut,
			animations: { [weak self] in
				
				// If isNavigationBarHidden state should change
				if
					let hideBar = self?.hideBar,
					hideBar != self?.navigationController?.isNavigationBarHidden
				{
					// Animate navigation bar show/hide
					self?.navigationController?.isNavigationBarHidden = hideBar
				}
				// Fade in presented view controller
				toViewController.view.alpha = 1.0
		}) { finished in
			transitionContext.completeTransition(finished)
		}
	}
}
