//
//  ImageNoticeConfigurationViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/04.
//

import Foundation
import QuickTableViewController
import RxSwift
import RxCocoa
import SnapKit

final class ImageNoticeConfigurationViewController: QuickTableViewController {
    static private let storyboardID = "ImageNoticeConfiguration"
    static let segueID = "seg\(storyboardID)"
    static let navigationBarTitle = "이미지 공지 상세 설정"
    
    @IBOutlet private weak var showImageNoticeButton: UIButton!
    
    private lazy var viewModel: ImageNoticeConfigurationViewModel = {
        ImageNoticeConfigurationViewModel(viewController: self)
    }()
    private let inputShowImageNotice = PublishRelay<Void>()
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
        self.title = ImageNoticeConfigurationViewController.navigationBarTitle
        self.setupConstraint()
        self.setupContents()
        self.bind()
    }
}

extension ImageNoticeConfigurationViewController {
    private func setupConstraint() {
        self.tableView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.showImageNoticeButton.snp.top)
        }
    }
    
    private func setupContents() {
        tableContents = [
            Section(title: "ImageNotice Configuration", rows: [
                TapActionRow<CustomTapActionCell>(text: "배경색 설정", action: { [weak self] _ in
                    self?.viewModel.setBackgroundColor()
                }),
                TapActionRow<CustomTapActionCell>(text: "최대 로딩 시간 설정", action: { [weak self] _ in
                    self?.viewModel.setTimeoutMS()
                }),
                SwitchRow(text: "Custom scheme 발생 시 공지 닫기", switchValue: true, action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.setEnableAutoCloseByCustomScheme(row.switchValue)
                    }
                }),
                SwitchRow(text: "SchemeEvent 설정", switchValue: false, action: { [weak self] row in
                    if let row = row as? SwitchRowCompatible {
                        self?.viewModel.useSchemeEvent = row.switchValue
                    }
                })
            ])
        ]
    }
    
    private func bind() {
        let input = ImageNoticeConfigurationViewModel.Input(showImageNotice: inputShowImageNotice)
        let output = self.viewModel.transform(input: input)
        
        self.showImageNoticeButton.rx.tap
            .subscribe { [weak self] _ in
                self?.inputShowImageNotice.accept(())
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit { alertInfo in
                UIViewController.showAlert(alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}
