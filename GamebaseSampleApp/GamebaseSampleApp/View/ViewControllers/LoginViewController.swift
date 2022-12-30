//
//  LoginViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/05.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

final class LoginViewController: UIViewController {
    static private let storyboardID = "Login"
    static let segueID = "seg\(storyboardID)"
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var contactButton: UIButton!
    
    private struct LoginConstants {
        static let tableViewLineHeight: CGFloat = 50.0
        static let tableViewLineSpacing: CGFloat = 10.0
    }
    
    private let viewModel = LoginViewModel.shared
    private let inputTryToLogin = PublishRelay<String>()
    private let inputOpenContact = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        self.bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - setup
extension LoginViewController {
    private func setupTableView() {
        registerTableViewCells()
        
        tableView.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        Observable.just(viewModel.loginItems)
            .bind(to: tableView.rx.items(cellIdentifier: CustomImageTitleCell.cellID, cellType: CustomImageTitleCell.self)) { _, item, cell in
                cell.lineSpacing = LoginConstants.tableViewLineSpacing
                cell.contentView.layer.borderWidth = 1
                cell.contentView.layer.borderColor = UIColor.darkGray.cgColor
                cell.contentView.layer.cornerRadius = 8

                cell.bind(title: item.title, iconImageName: item.icon)                
            }
            .disposed(by: disposeBag)
    }
    
    private func registerTableViewCells() {
        let cell = UINib(nibName: CustomImageTitleCell.nibName, bundle: nil)
        tableView.register(cell, forCellReuseIdentifier: CustomImageTitleCell.cellID)
    }
    
    private func bind() {
        viewModel.viewController = self
        let input = LoginViewModel.Input(tryToLogin: inputTryToLogin,
                                         openContact: inputOpenContact)
        let output = viewModel.transform(input: input)
        
        tableView.rx.modelSelected(CustomImageTitleModel.self)
            .compactMap { $0.etc }
            .bind(to: inputTryToLogin)
            .disposed(by: disposeBag)
        
        contactButton.rx.tap
            .bind(to: inputOpenContact)
            .disposed(by: disposeBag)
        
        output.routeToHomeView
            .emit(with: self) { owner, _ in
                owner.performSegue(withIdentifier: HomeViewController.segueID, sender: nil)
                owner.disposeBag = DisposeBag()
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDelegate
extension LoginViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return LoginConstants.tableViewLineHeight + LoginConstants.tableViewLineSpacing
    }
}
