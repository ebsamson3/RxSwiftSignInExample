//
//  Configurable.swift
//  Doodler
//
//  Created by Edward Samson on 12/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation

/// Protocol for configuring views with their corresponding view model class
protocol Configurable {
	associatedtype T
	
    func configureWithViewModel(_ viewModel: T)
}
