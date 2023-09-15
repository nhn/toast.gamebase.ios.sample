//
//  TermsConfigurationViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/06.
//

import Foundation
import QuickTableViewController
import RxCocoa
import RxSwift

final class TermsConfigurationViewController: QuickTableViewController {
    static private let storyboardID = "TermsConfiguration"
    static let segueID = "seg\(storyboardID)"
    static let navigationBarTitle = "약관 상세 설정"
    
    @IBOutlet private weak var showTermsViewButton: UIButton!
    
    private lazy var viewModel: TermsConfigurationViewModel = {
        TermsConfigurationViewModel(viewController: self)
    }()
    private let inputShowTermsView = PublishRelay<Void>()
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
        self.title = TermsConfigurationViewController.navigationBarTitle
        self.setupConstraint()
        self.setupContents()
        self.bind()
    }
}

extension TermsConfigurationViewController {
    private func setupConstraint() {
        self.tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.showTermsViewButton.snp.top)
        }
    }
    
    private func setupContents() {
        tableContents = [
            Section(title: "Terms Configuration", rows: [
                SwitchRow(text: "약관 강제 표시", switchValue: false, action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setForceShow(row.switchValue)
                    }
                }),
            ])
        ]
    }
    
    private func bind() {
        let input = TermsConfigurationViewModel.Input(showTermsView: inputShowTermsView)
        let output = self.viewModel.transform(input: input)
        
        self.showTermsViewButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.inputShowTermsView.accept(())
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}

