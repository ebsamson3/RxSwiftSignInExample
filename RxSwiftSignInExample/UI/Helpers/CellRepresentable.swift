//
//  CellRepresentable.swift
//  Doodler
//
//  Created by Edward Samson on 12/16/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

/// UITableViewCell factory protocol
protocol CellRepresentable {
	static func registerCell(tableView: UITableView)
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell
}
