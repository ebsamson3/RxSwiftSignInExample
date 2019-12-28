//
//  NSLayoutConstraint+Extensions.swift
//  Doodler
//
//  Created by Edward Samson on 12/16/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
	func withPriority(_ priority: UILayoutPriority ) -> NSLayoutConstraint {
		self.priority = priority
		return self
	}
}
