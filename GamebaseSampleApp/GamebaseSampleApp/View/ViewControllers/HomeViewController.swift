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
    @IBOutlet weak var testDeviceLabel: UILabel!
    
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
            .subscribe(with: self) { owner, _ in
                let menu = owner.storyboard?.instantiateViewController(withIdentifier: "leftMenuNavVC") as! SideMenuNavigationController
                owner.present(menu, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .emit(with: self) { owner, isLoading in
                MBProgressHUD.showProgress(isLoading, to: owner.view, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.testDeviceLabelText
            .emit(with: self) { owner, labelText in
                owner.testDeviceLabel.text = labelText
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
        
        output.routeToRootView
            .emit(with: self) { owner, _ in
                owner.navigationController?.popToRootViewController(animated: true)
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
