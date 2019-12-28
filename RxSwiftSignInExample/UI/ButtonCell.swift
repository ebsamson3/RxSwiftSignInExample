//
//  ButtonCell.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift

/// A Cell with a single rounded rectangle button
class ButtonCell: UITableViewCell, Configurable {
	typealias T = ButtonCellViewModel
	
	var disposeBag = DisposeBag()
	
	static let reuseIdentifier = "ButtonCell"
	
	var title: String? {
		didSet {
			button.setTitle(title, for: .normal)
		}
	}
	
	let button: UIButton = {
		let button = UIButton(type: .roundedRect)
		button.backgroundColor = .clear
		button.layer.cornerRadius = 8
		button.layer.borderWidth = 1
		button.layer.borderColor = UIColor.black.cgColor
		return button
	}()
	
	override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		configureLayout()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForReuse() {
		disposeBag = DisposeBag()
	}
	
	func configureLayout() {
		contentView.addSubview(button)
		button.translatesAutoresizingMaskIntoConstraints = false
		
		let margins = contentView.layoutMarginsGuide
		
		NSLayoutConstraint.activate([
			button.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
			button.trailingAnchor.constraint(equalTo: margins.trailingAnchor).withPriority(.defaultHigh),
			button.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
			button.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).withPriority(.defaultHigh),
			button.heightAnchor.constraint(equalToConstant: 44.0)
		])
	}
	
	func configureWithViewModel(_ viewModel: ButtonCellViewModel) {
		title = viewModel.title
		
		viewModel.output.isValid
			.asDriver(onErrorJustReturn: false)
			.drive(button.rx.isEnabled)
			.disposed(by: disposeBag)
		
		button.rx.tap
			.subscribe(viewModel.input.didTap)
			.disposed(by: disposeBag)
	}
}
