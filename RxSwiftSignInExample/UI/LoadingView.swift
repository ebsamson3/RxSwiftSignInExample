//
//  LoadingView.swift
//  RxSwiftSignInExample
//
//  Created by Edward Samson on 12/27/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit

// A simple view with a centered activity indicator
class LoadingView: UIView {
	let spinner: UIActivityIndicatorView = {
		let spinner = UIActivityIndicatorView()
		spinner.style = .whiteLarge
		spinner.color = .systemBlue
		return spinner
	}()
	
	init() {
		super.init(frame: .zero)
		configure()
		spinner.startAnimating()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configure() {
		backgroundColor = .white
		
		addSubview(spinner)
		spinner.translatesAutoresizingMaskIntoConstraints = false
		
		NSLayoutConstraint.activate([
			spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
			spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
}
