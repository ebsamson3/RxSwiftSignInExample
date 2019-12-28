//
//  TableViewRepresentable.swift
//  Doodler
//
//  Created by Edward Samson on 12/18/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift

/// Capable of providing table view status information
protocol TableViewRepresentable {
	
	var cellViewModels: Observable<[CellRepresentable]> { get }
	
	func registerCells(to tableView: UITableView)
}
