//
//  FormView.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

// A view with a UITableView that is configured for use in bulding modular forms
class FormView: UIView {
	
	let tableView: UITableView = {
		let tableView = UITableView()
		tableView.separatorStyle = .none
		tableView.allowsSelection = false
		tableView.alwaysBounceVertical = false
		tableView.keyboardDismissMode = .onDrag
		return tableView
	}()
	
	// Conveys the form's loading status
	let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.style = .whiteLarge
		spinner.color = .systemBlue
		spinner.hidesWhenStopped = true
		return spinner
	}()
	
	init() {
		super.init(frame: CGRect.zero)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configure() {
		addSubview(tableView)
		addSubview(spinner)
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		spinner.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: topAnchor),
			tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
			tableView.bottomAnchor.constraint(equalTo: bottomAnchor),
			tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
}
