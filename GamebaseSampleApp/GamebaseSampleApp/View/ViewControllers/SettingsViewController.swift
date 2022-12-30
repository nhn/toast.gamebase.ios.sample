//
//  SettingsViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/15.
//

import UIKit
import QuickTableViewController
import RxSwift
import RxCocoa

final class SettingsViewController: QuickTableViewController {
    private lazy var viewModel: SettingsViewModel = {
        SettingsViewModel(viewController: self)
    }()
    private let inputMapping = PublishRelay<Void>()
    private let inputLogout = PublishRelay<Void>()
    private let inputWithdraw = PublishRelay<Void>()
    private let inputPush = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if #available(iOS 13.0, *) {
            self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        } else {
            self.tableView = UITableView(frame: .zero, style: .grouped)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContents()
        self.bind()
    }
}

// MARK: - setup
extension SettingsViewController {
    private func setupContents() {
        tableContents = [
            Section(title: "버전 정보", rows: [
                NavigationRow(text: "Gamebase", detailText:.value1(viewModel.sdkVersion())),
            ]),
            Section(title: "계정 관리", rows: [
                NavigationRow(text: "IdP 계정 연동", detailText:.none, action: { [weak self] _ in
                    self?.inputMapping.accept(())
                }),
                TapActionRow<CustomTapActionCell>(text: "로그아웃", action: { [weak self] _ in
                    self?.inputLogout.accept(())
                }),
                TapActionRow<CustomTapActionCell>(text: "탈퇴하기", action: { [weak self] _ in
                    self?.inputWithdraw.accept(())
                }),
            ]),
            Section(title: "알림", rows: [
                NavigationRow(text: "알림 설정", detailText:.none, action: { [weak self] _ in
                    self?.inputPush.accept(())
                }),
            ]),
            Section(title: "기타", rows: [
                TapActionRow<CustomTapActionCell>(text: "고객센터", action: { [weak self] _ in
                    self?.viewModel.openContact()
                }),
                TapActionRow<CustomTapActionCell>(text: "오픈소스 라이선스", action: { [weak self] _ in
                    self?.viewModel.showOpenSourceLicense()
                }),
            ]),
        ]
    }
    
    private func bind() {
        let input = SettingsViewModel.Input(mapping: inputMapping,
                                            logout: inputLogout,
                                            withdraw: inputWithdraw,
                                            push: inputPush)
        let output = self.viewModel.transform(input: input)
        
        output.routeToRootView
            .emit(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        output.routeToChildView
            .emit(with: self) { owner, segID in
                owner.performSegue(withIdentifier: segID, sender: nil)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}
