//
//  UpdateTermsViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/06.
//

import Foundation
import RxCocoa
import RxSwift
import MBProgressHUD

final class UpdateTermsViewController: UIViewController {
    static private let storyboardID = "UpdateTerms"
    static let segueID = "seg\(storyboardID)"
    static let navigationBarTitle = "약관 동의 내역 저장"
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var updateTermsButton: UIButton!
    
    private let viewModel = UpdateTermsViewModel()
    private let inputPrepareData = PublishRelay<Void>()
    private let inputUpdateTerms = PublishRelay<Void>()
    private var disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = UpdateTermsViewController.navigationBarTitle
        self.setupTableView()
        self.bind()
        self.inputPrepareData.accept(())
    }
}

extension UpdateTermsViewController {
    private func setupTableView() {
        registerTableViewCells()
        
        self.viewModel.termsContentItemList
            .bind(to: tableView.rx.items(cellIdentifier: CustomTitleSwitchCell.cellID, cellType: CustomTitleSwitchCell.self)) { _, info, cell in
                cell.bind(info: info)
            }
            .disposed(by: disposeBag)
    }
    
    private func registerTableViewCells() {
        let tableViewCell = UINib(nibName: CustomTitleSwitchCell.nibName, bundle: nil)
        tableView.register(tableViewCell, forCellReuseIdentifier: CustomTitleSwitchCell.cellID)
    }
    
    private func bind() {
        let input = UpdateTermsViewModel.Input(prepareData: inputPrepareData,
                                               updateTerms: inputUpdateTerms)
        let output = self.viewModel.transform(input: input)
        
        self.updateTermsButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.inputUpdateTerms.accept(())
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .emit(with: self) { owner, isLoading in
                MBProgressHUD.showProgress(isLoading, to: owner.view, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}
