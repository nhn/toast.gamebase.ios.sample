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
    
    private lazy var testDeviceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .systemRed
        label.font = .boldSystemFont(ofSize: 10)
        return label
    }()
    
    private lazy var subMenuStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        stackView.addArrangedSubview(self.gameNoticeButton)
        stackView.addArrangedSubview(self.contactButton)
        
        return stackView
    }()
    
    private lazy var gameNoticeButton: UIButton = {
       let button = HomeSubMenuButton(image: UIImage(named: "gameNotice"), text: "게임공지")
        return button
    }()
    
    private lazy var contactButton: UIButton = {
       let button = HomeSubMenuButton(image: UIImage(named: "contact"), text: "고객센터")
        return button
    }()
    
    private lazy var viewModel: HomeViewModel = {
        HomeViewModel(viewController: self)
    }()
    
    private let inputPrepareHome = PublishRelay<Void>()
    private let inputGameNoticeClicked = PublishRelay<UIViewController>()
    private let inputContactClicked = PublishRelay<UIViewController>()
    
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupNavigationBar()
        self.setupLayout()
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
            navigationBarAppearance.backgroundColor = .accentColor
            navigationBarAppearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
            navigationController?.navigationBar.standardAppearance = navigationBarAppearance
            navigationController?.navigationBar.scrollEdgeAppearance = navigationBarAppearance
            navigationController?.navigationBar.tintColor = .white
        } else {
            navigationController?.navigationBar.barTintColor = .accentColor
            navigationController?.navigationBar.tintColor = .white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        }
    }
    
    private func setupLayout() {
        self.view.addSubview(self.testDeviceLabel)
        self.view.addSubview(self.subMenuStackView)
        
        self.testDeviceLabel.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(5)
            make.leading.equalTo(self.view.safeAreaLayoutGuide).offset(5)
        }
            
        self.subMenuStackView.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(15)
            make.trailing.equalTo(self.view.safeAreaLayoutGuide).offset(-10)
            make.width.equalTo(60)
        }
    }
    
    private func bind() {
        viewModel.registerEventHandler()
        
        let input = HomeViewModel.Input(
            prepareHome: inputPrepareHome, 
            gameNoticeClicked: inputGameNoticeClicked,
            contactClicked: inputContactClicked
        )
        let output = viewModel.transform(input: input)
        
        sideMenuButton.rx.tap
            .subscribe(with: self) { owner, _ in
                let menu = owner.storyboard?.instantiateViewController(withIdentifier: "leftMenuNavVC") as! SideMenuNavigationController
                owner.present(menu, animated: true)
            }
            .disposed(by: disposeBag)
        
        gameNoticeButton.rx.tap
            .compactMap { self }
            .bind(to: inputGameNoticeClicked)
            .disposed(by: disposeBag)
        
        contactButton.rx.tap
            .compactMap { self }
            .bind(to: inputContactClicked)
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
