//
//  HomeViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/06/23.
//

import Foundation
import UIKit
import SideMenu
import RxSwift
import RxCocoa
import MBProgressHUD

final class HomeViewController: UIViewController {
    static private let storyboardID = "Home"
    static let segueID = "seg\(storyboardID)"

    @IBOutlet private weak var sideMenuButton: UIBarButtonItem!
    private lazy var viewModel: HomeViewModel = {
        HomeViewModel(viewController: self)
    }()
    private let inputPrepareHome = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.bind()
    }
}

// MARK: - setup
extension HomeViewController {
    private func setupNavigationBar() {
        navigationController?.isNavigationBarHidden = false
        
        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = .systemBlue
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController?.navigationBar.tintColor = .white
        } else {
            navigationController?.navigationBar.barTintColor = .systemBlue
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        }
    }
    
    private func bind() {
        viewModel.registerEventHandler()
        
        let input = HomeViewModel.Input(prepareHome: inputPrepareHome)
        let output = viewModel.transform(input: input)
        
        sideMenuButton.rx.tap
            .subscribe { [weak self] _ in
                let menu = self?.storyboard!.instantiateViewController(withIdentifier: "leftMenuNavVC") as! SideMenuNavigationController
                self?.present(menu, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .emit { [weak self] isLoading in
                guard let self = self else { return }
                MBProgressHUD.showProgress(isLoading, to: self.view, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit { [weak self] alertInfo in
                guard let self = self else { return }
                UIViewController.showAlert(above: self, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
        
        output.routeToRootView
            .emit { [weak self] _ in
                self?.navigationController?.popToRootViewController(animated: true)
            }
            .disposed(by: disposeBag)
        
        self.inputPrepareHome.accept(())
    }
}

// MARK: - SideMenuNavigationControllerDelegate
extension HomeViewController: SideMenuNavigationControllerDelegate {
    func sideMenuWillAppear(menu: SideMenuNavigationController, animated: Bool) {
        self.view.backgroundColor = .systemGray
    }
    
    func sideMenuWillDisappear(menu: SideMenuNavigationController, animated: Bool) {
        self.view.backgroundColor = .white
        
        guard let sideMenu = menu as? CustomSideMenuNavigationController else { return }
        guard let selectedMenu = sideMenu.selectedMenu else { return }
        
        if let segID = selectedMenu.segID {
            performSegue(withIdentifier: segID, sender: nil)
        }
    }
}
