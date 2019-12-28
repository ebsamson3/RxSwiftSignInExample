//
//  TextCell.swift
//  Doodler
//
//  Created by Edward Samson on 12/18/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

/// Variable height cell with centered text
class TextCell: UITableViewCell, Configurable {
	typealias T = TextCellViewModel
	
	static let reuseIdentifier = "TextCell"
	
	var content: String? {
		didSet {
			contentLabel.text = content
		}
	}
	
	var fontSize: CGFloat = 16 {
		didSet {
			contentLabel.font = UIFont.systemFont(ofSize: fontSize)
		}
	}
	
	var height: CGFloat = 44 {
		didSet {
			heightConstraint.constant = height
		}
	}
	
	private lazy var heightConstraint: NSLayoutConstraint = {
		return contentView.heightAnchor.constraint(
			equalToConstant: height)
			.withPriority(.defaultHigh)
	}()
	
	private let contentLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		label.textAlignment = .center
		return label
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configureLayout() {
		contentView.addSubview(contentLabel)
		contentLabel.translatesAutoresizingMaskIntoConstraints = false
		
		let margins = contentView.layoutMarginsGuide
		
		NSLayoutConstraint.activate([
			contentLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
			contentLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
			contentLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor).withPriority(.defaultHigh),
			contentLabel.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
			heightConstraint
		])
	}
	
	func configureWithViewModel(_ viewModel: TextCellViewModel) {
		self.content = viewModel.text
		self.fontSize = viewModel.fontSize
		self.height = viewModel.cellHeight
	}
}
