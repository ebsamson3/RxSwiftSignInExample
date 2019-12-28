//
//  ButtonCellViewModel.swift
//  Doodler
//
//  Created by Edward Samson on 12/17/19.
//  Copyright © 2019 Edward Samson. All rights reserved.
//

import UIKit
import RxSwift

/// Instantiates and configues ButtonCells
class ButtonCellViewModel {
	
	struct Input {
		let didTap: AnyObserver<Void>
	}
	
	struct Output {
		let isValid: Observable<Bool>
		let didTap: Observable<Void>
	}
	
	let disposeBag = DisposeBag()
	
	let title: String
	
	let input: Input
	let output: Output
	
	private let didTapSubject = PublishSubject<Void>()
	
	init(title: String, isValid: Observable<Bool> = Observable.just(true)) {
		self.title = title
		
		input = Input(didTap: didTapSubject.asObserver())
		
		output = Output(
			isValid: isValid,
			didTap: didTapSubject.asObservable())
	}
}

extension ButtonCellViewModel: CellRepresentable {
	static func registerCell(tableView: UITableView) {
		tableView.register(
			ButtonCell.self,
			forCellReuseIdentifier: ButtonCell.reuseIdentifier)
	}
	
	func cellInstance(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(
			withIdentifier: ButtonCell.reuseIdentifier,
			for: indexPath)
		
		if let buttonCell = cell as? ButtonCell {
			buttonCell.configureWithViewModel(self)
		}
		
		return cell
	}
}
