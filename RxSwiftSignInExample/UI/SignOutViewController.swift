//
//  SignOutViewController.swift
//  Doodler
//
//  Created by Edward Samson on 12/26/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift

/// Dummy view controller with a sign out navigtion item
class SignOutViewController: UIViewController {
	
	let disposeBag = DisposeBag()
	
	private lazy var signOutButton = UIBarButtonItem(
		title: "Sign Out",
		style: .plain,
		target: nil,
		action: nil)
	
	let viewModel: SignOutViewModel
	
	init(viewModel: SignOutViewModel) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		configure()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .white
		navigationItem.rightBarButtonItem = signOutButton
	}
	
	private func configure() {
		signOutButton.rx.tap
			.subscribe(viewModel.input.didTapSignOutButton)
			.disposed(by: disposeBag)
	}
	
}
