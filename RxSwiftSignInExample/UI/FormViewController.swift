//
//  SignUpViewController.swift
//  Doodler
//
//  Created by Edward Samson on 12/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift
import RxKeyboard

/// Configures a FormView with observables from a ViewModel
class FormViewController: UIViewController {
	
	let disposeBag = DisposeBag()
	
	private var formView: FormView {
		return view as! FormView
	}
	
	// View model must be capable of updating UITableView contents and loading status
	let viewModel: TableViewRepresentable & LoadingRepresentable
	
	init(viewModel: TableViewRepresentable & LoadingRepresentable) {
		self.viewModel = viewModel
		super.init(nibName: nil, bundle: nil)
		configure()
	}
	
	override func loadView() {
		view = FormView()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func configure() {
		let tableView = formView.tableView
		let spinner = formView.spinner
		
		viewModel.registerCells(to: tableView)
		
		// Binds an array of cell view models to the TableView. The cell view models contain all of the code for cell instantiation. This cleanly enables the use different combinations of multiple cell types.
		viewModel.cellViewModels.bind(to: tableView.rx.items) { tableView, row, cellViewModel in
			let indexPath = IndexPath(row: row, section: 0)
			
			let cell = cellViewModel.cellInstance(
				tableView: tableView,
				indexPath: indexPath)
			
			return cell
		}.disposed(by: disposeBag)
		
		// Updates the loading status of the FormView
		viewModel.isLoading.asDriver(onErrorJustReturn: false)
			.do(onNext: { [weak self] isLoading in
				self?.view.endEditing(true)
			})
			.drive(spinner.rx.isAnimating)
			.disposed(by: disposeBag)
		
		// RxSwift extension that enables the observation of keyboard height. Removes notification center boilerplate.
		RxKeyboard.instance.visibleHeight
			.drive(onNext: { [weak tableView] keyboardVisibleHeight in
				tableView?.contentInset.bottom = keyboardVisibleHeight
				tableView?.scrollIndicatorInsets.bottom = keyboardVisibleHeight
			})
			.disposed(by: disposeBag)
	}
}
