//
//  AppPermissionViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/07.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class AppPermissionViewController: UIViewController {
    static private let storyboardID = "AppPermission"
    static let segueID = "seg\(storyboardID)"
    private let viewModel = AppPermissionViewModel.shared
    
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var okButton: UIButton!
    
    private var disposeBag = DisposeBag()
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 20
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupLayout()
        self.setupContents()
        self.bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
}

// MARK: - setup
extension AppPermissionViewController {
    private func setupLayout() {
        self.modalPresentationStyle = .fullScreen
        
        if #available(iOS 13.0, *) {
            self.isModalInPresentation = true
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.top.equalTo(subTitleLabel.snp.bottom).offset(20)
            make.bottom.equalTo(okButton.snp.top).offset(-20)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
    }
    
    private func setupContents() {
        let permissionDetailViews = viewModel.getPermissionInfos().map { AppPermissionDetailView($0) }
        stackView.addArrangedSubviews(permissionDetailViews)
    }
    
    private func bind() {
        okButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.viewModel.agreeAboutAppPermission()
                owner.dismiss(animated: true)
            }
            .disposed(by: disposeBag)
    }
}
