//
//  LoadingRepresentable.swift
//  Doodler
//
//  Created by Edward Samson on 12/20/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import Foundation
import RxSwift

/// Capable of providing view loading status information
protocol LoadingRepresentable {
	var isLoading: Observable<Bool> { get }
}
