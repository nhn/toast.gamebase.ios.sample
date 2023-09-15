//
//  PushSettingsViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/25.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

final class PushSettingsViewController: UIViewController {
    static private let storyboardID = "PushSettings"
    static let segueID = "seg\(storyboardID)"

    @IBOutlet private weak var tableView: UITableView!
    private let inputEnterForeground = PublishRelay<Void>()
    private let inputPrepareItems = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    private let viewModel = PushSettingsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.bind()
        self.inputPrepareItems.accept(())
    }
    
    private func setupTableView() {
        self.registerTableViewCells()
        
        viewModel.pushSettingItemList
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
        let input = PushSettingsViewModel.Input(prepareItems: inputPrepareItems,
                                                enterForeground: inputEnterForeground)
        let output = viewModel.transform(input: input)
        
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification)
            .asDriver { _ in .never() }
            .drive(with: self) { owner, _ in
                owner.inputEnterForeground.accept(())
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
