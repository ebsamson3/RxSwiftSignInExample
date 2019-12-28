//
//  TextCellViewModel.swift
//  Doodler
//
//  Created by Edward Samson on 12/18/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

/// Instantiates and configures TextCells
class TextCellViewModel {
	
	let text: String?
	let fontSize: CGFloat
	let cellHeight: CGFloat
	
	init(text: String?, fontSize: CGFloat, cellHeight: CGFloat) {
		self.text = text
		self.fontSize = fontSize
		self.cellHeight = cellHeight
	}
}

extension TextCellViewModel: CellRepresentable {
	static func registerCell(tableView: UITableView) {
		tableView.register(
			TextCell.self,
			forCellReuseIdentifier: TextCell.reuseIdentifier)
	}
	
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: TextCell.reuseIdentifier,
			for: indexPath)
		
		if let textCell = cell as? TextCell {
			textCell.configureWithViewModel(self)
		}
		
		return cell
	}
}
