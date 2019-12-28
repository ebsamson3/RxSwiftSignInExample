//
//  Drawable.swift
//  Doodler
//
//  Created by Edward Samson on 12/18/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

protocol Drawable {
    var viewController: UIViewController? { get }
}

extension UIViewController: Drawable {
    var viewController: UIViewController? { return self }
}
