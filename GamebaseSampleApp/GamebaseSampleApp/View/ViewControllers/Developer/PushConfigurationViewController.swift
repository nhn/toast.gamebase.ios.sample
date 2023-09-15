//
//  PushConfigurationViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/08.
//

import Foundation
import QuickTableViewController
import RxCocoa
import RxSwift

final class PushConfigurationViewController: QuickTableViewController {
    static private let storyboardID = "PushConfiguration"
    static let segueID = "seg\(storyboardID)"
    static let navigationBarTitle = "푸시 상세 설정"
    
    @IBOutlet private weak var registerPushButton: UIButton!
    
    private let viewModel = PushConfigurationViewModel()
    private let inputRegisterPush = PublishRelay<Void>()
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
        self.title = PushConfigurationViewController.navigationBarTitle
        self.setupConstraint()
        self.setupContents()
        self.bind()
    }
}

extension PushConfigurationViewController {
    private func setupConstraint() {
        self.tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.registerPushButton.snp.top)
        }
    }
    
    private func setupContents() {
        tableContents = [
            Section(title: "Push Configuration", rows: [
                SwitchRow(text: "푸시알림 받기", switchValue: self.viewModel.getPushEnabled(), action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setPushEnabled(row.switchValue)
                    }
                }),
                SwitchRow(text: "광고성 푸시알림 받기", switchValue: self.viewModel.getAdAgreement(), action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setAdAgreement(row.switchValue)
                    }
                }),
                SwitchRow(text: "야간 광고성 푸시알림 받기", switchValue: self.viewModel.getAdAgreementNight(), action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setAdAgreementNight(row.switchValue)
                    }
                }),
                SwitchRow(text: "푸시 권한 여부 상관없이 토큰 등록하기", switchValue: self.viewModel.getAlwaysAllowTokenRegistartion(), action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setAlwaysAllowTokenRegistartion(row.switchValue)
                    }
                })
            ]),
            Section(title: "Notification Options", rows: [
                SwitchRow(text: "앱 활성화 중에도 푸시알림 받기", switchValue: self.viewModel.getForegroundEnabled(), action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setForegroundEnabled(row.switchValue)
                    }
                }),
                SwitchRow(text: "배지 아이콘 사용", switchValue: self.viewModel.getBadgeEnabled(), action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setBadgeEnabled(row.switchValue)
                    }
                }),
                SwitchRow(text: "알림음 사용", switchValue: self.viewModel.getSoundEnabled(), action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setSoundEnabled(row.switchValue)
                    }
                })
            ])
        ]
    }
    
    private func bind() {
        let input = PushConfigurationViewModel.Input(registerPush: inputRegisterPush)
        let output = viewModel.transform(input: input)
        
        self.registerPushButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.inputRegisterPush.accept(())
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}
