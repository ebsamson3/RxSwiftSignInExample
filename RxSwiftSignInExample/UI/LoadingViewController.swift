//
//  LoadingViewController.swift
//  Doodler
//
//  Created by Edward Samson on 12/27/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

/// A controller for a simple view with an activity indicator
class LoadingViewController: UIViewController {

	override func loadView() {
		view = LoadingView()
	}
}
