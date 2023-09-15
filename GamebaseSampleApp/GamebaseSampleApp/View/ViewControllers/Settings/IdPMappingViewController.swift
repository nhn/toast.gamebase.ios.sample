//
//  IdPMappingViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/22.
//

import UIKit
import RxSwift
import RxCocoa

final class IdPMappingViewController: UIViewController {
    static private let storyboardID = "IdPMapping"
    static let segueID = "seg\(storyboardID)"
    
    @IBOutlet private weak var tableView: UITableView!
    private var disposeBag = DisposeBag()
    private lazy var viewModel: IdPMappingViewModel = {
        IdPMappingViewModel(viewController: self)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.bind()
    }
}

// MARK: - setup
extension IdPMappingViewController {
    private func setupTableView() {
        registerTableViewCells()
        
        viewModel.mappingItemList.asObservable()
            .bind(to: tableView.rx.items(cellIdentifier: IdPMappingTableViewCell.cellID, cellType: IdPMappingTableViewCell.self)) { _, mappingInfo, cell in
                cell.bind(mappingInfo: mappingInfo)
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        let input = IdPMappingViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
        
        output.routeToRootView
            .emit(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
    }
    
    private func registerTableViewCells() {
        let tableViewCell = UINib(nibName: IdPMappingTableViewCell.nibName, bundle: nil)
        tableView.register(tableViewCell, forCellReuseIdentifier: IdPMappingTableViewCell.cellID)
    }

}
