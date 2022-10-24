//
//  WebViewConfigurationViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/02.
//

import Foundation
import QuickTableViewController
import RxSwift
import RxCocoa
import SnapKit

final class WebViewConfigurationViewController: QuickTableViewController {
    static private let storyboardID = "WebViewConfiguration"
    static let segueID = "seg\(storyboardID)"
    static let navigationBarTitle = "웹뷰 상세 설정"
    
    @IBOutlet private weak var showWebViewButton: UIButton!
    
    private lazy var viewModel: WebViewConfigurationViewModel = {
        WebViewConfigurationViewModel(viewController: self)
    }()
    private let inputShowWebView = PublishRelay<Void>()
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
        self.title = WebViewConfigurationViewController.navigationBarTitle
        self.setupConstraint()
        self.setupContents()
        self.bind()
    }
}

extension WebViewConfigurationViewController {
    private func setupConstraint() {
        self.tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.showWebViewButton.snp.top)
        }
    }
    
    private func setupContents() {
        tableContents = [
            setupContentsModeSection(),
            Section(title: "내비게이션바 설정", rows: [
                SwitchRow(text: "뒤로가기 버튼 표시", switchValue: true, action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setBackButtonVisible(row.switchValue)
                    }
                }),
                SwitchRow(text: "내비게이션 바 표시", switchValue: true, action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setNavigationBarVisible(row.switchValue)
                    }
                }),
                TapActionRow<CustomTapActionCell>(text: "내비게이션바 제목 설정", action: { [weak self] _ in
                    self?.viewModel.setNavigationBarTitle()
                }),
                TapActionRow<CustomTapActionCell>(text: "내비게이션바 색상 설정", action: { [weak self] _ in
                    self?.viewModel.setNavigationBarColor()
                })
            ])
        ]
    }
    
    private func setupContentsModeSection() -> RadioSection {
        let section = RadioSection(title: "Content Mode 설정", options: [
            OptionRow(text: WebViewContentModeItem[0], isSelected: true, action: didToggleContentMode()),
            OptionRow(text: WebViewContentModeItem[1], isSelected: false, action: didToggleContentMode()),
            OptionRow(text: WebViewContentModeItem[2], isSelected: false, action: didToggleContentMode())
        ])
        
        section.alwaysSelectsOneOption = true
        return section
    }
    
    private func didToggleContentMode() -> ((Row) -> Void)? {
        return { [weak self] in
            if let row = $0 as? OptionRowCompatible, row.isSelected {
                self?.viewModel.setContentMode(row.text)
            }
        }
    }
    
    private func bind() {
        let input = WebViewConfigurationViewModel.Input(showWebView: inputShowWebView)
        let output = self.viewModel.transform(input: input)
        
        self.showWebViewButton.rx.tap
            .subscribe { [weak self] _ in
                self?.inputShowWebView.accept(())
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit { [weak self] alertInfo in
                guard let self = self else { return }
                UIViewController.showAlert(above: self, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}
