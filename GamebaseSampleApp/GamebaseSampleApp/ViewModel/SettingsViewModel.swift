//
//  SettingsViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/19.
//

import Foundation
import Gamebase
import RxSwift
import RxCocoa

final class SettingsViewModel {
    private weak var viewController: UIViewController?
    
    // MARK: - Private
    private var disposeBag = DisposeBag()
    private let routeToRootView = PublishRelay<Void>()
    private let routeToChildView = PublishRelay<String>()
    private let showAlert = PublishRelay<AlertInfo>()
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

extension SettingsViewModel {
    func sdkVersion() -> String {
        return TCGBGamebase.SDKVersion()
    }
    
    func openContact() {
        TCGBContact.openContact(viewController: viewController)
    }
    
    func showOpenSourceLicense() {
        let config = TCGBWebViewConfiguration()
        config.navigationBarTitle = "오픈소스 라이선스"
        config.navigationBarColor = .systemBlue
        
        TCGBWebView.showWebView(urlString: "https://raw.githubusercontent.com/nhn/toast.gamebase.ios.sample/master/opensource-license.txt",
                                viewController: viewController,
                                configuration: config,
                                closeCompletion: nil,
                                schemeList: nil)
    }
    
    func showAppSourceCode() {
        TCGBWebView.openWebBrowser(urlString: "https://github.com/nhn/toast.gamebase.ios.sample")
    }
}

// MARK: - ViewModelType
extension SettingsViewModel: ViewModelType {
    struct Input {
        let mapping: PublishRelay<Void>
        let logout: PublishRelay<Void>
        let withdraw: PublishRelay<Void>
        let push: PublishRelay<Void>
    }
    
    struct Output {
        let routeToRootView: Signal<Void>
        let routeToChildView: Signal<String>
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.mapping
            .subscribe(with: self) { owner, _ in
                owner.mapping()
            }
            .disposed(by: disposeBag)
        
        input.logout
            .subscribe(with: self) { owner, _ in
                owner.confirmLogout()
            }
            .disposed(by: disposeBag)
        
        input.withdraw
            .subscribe(with: self) { owner, _ in
                owner.confirmWithdraw()
            }
            .disposed(by: disposeBag)

        input.push
            .subscribe(with: self) { owner, _ in
                owner.checkPush()
            }
            .disposed(by: disposeBag)
        
        return Output(routeToRootView: routeToRootView.asSignal(),
                      routeToChildView: routeToChildView.asSignal(),
                      showAlert: showAlert.asSignal())
    }
}

// MARK: - Business logic
extension SettingsViewModel {
    private func mapping() {
        self.routeToChildView.accept(IdPMappingViewController.segueID)
    }
    
    private func confirmLogout() {
        let action = UIAlertAction(title: "로그아웃", style: .destructive) { [weak self] _ in
            self?.logout()
        }
        let alertInfo = AlertInfo(title: "로그아웃",
                                  message: "로그아웃하시겠습니까?",
                                  preferredStyle: .actionSheet,
                                  additionalActions: [action])
        self.showAlert.accept(alertInfo)
    }
    
    private func logout() {
        GamebaseAsObservable.logout()
            .subscribe(with: self) { owner, _ in
                owner.routeToRootView.accept(())
            } onError: { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "로그아웃 실패",
                                                 message: "알 수 없는 이유로 로그아웃에 실패했습니다. 잠시 후 다시 한번 시도해주세요.\n계속해서 문제가 발생하는 경우 고객센터로 문의주시기 바랍니다."))
            }
            .disposed(by: disposeBag)
    }

    private func confirmWithdraw() {
        let action = UIAlertAction(title: "탈퇴하기", style: .destructive) { [weak self] _ in
            self?.withdraw()
        }
        let alertInfo = AlertInfo(title: "탈퇴하기",
                                  message: "탈퇴하시겠습니까?\n탈퇴 후에는 계정 복구가 어렵습니다.",
                                  preferredStyle: .actionSheet,
                                  additionalActions: [action])
        self.showAlert.accept(alertInfo)
    }
    
    private func withdraw() {
        GamebaseAsObservable.withdraw()
            .subscribe(with: self) { owner, _ in
                owner.routeToRootView.accept(())
            } onError: { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "탈퇴 실패",
                                                 message: "알 수 없는 이유로 탈퇴에 실패했습니다. 잠시 후 다시 한번 시도해주세요.\n계속해서 문제가 발생하는 경우 고객센터로 문의주시기 바랍니다."))
            }
            .disposed(by: disposeBag)
    }
    
    private func checkPush() {
        GamebaseAsObservable.queryNotificationAllowed()
            .subscribe(with: self) { owner, allowed in
                if allowed {
                    owner.routeToChildView.accept(PushSettingsViewController.segueID)
                } else {
                    let action = UIAlertAction(title: "설정", style: .default) { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    }
                    
                    let alertInfo = AlertInfo(title: "알림 설정",
                                              message: "알림 사용을 위한 사용자 설정이 필요합니다.\n기기 설정으로 이동해서 알림을 허용해주세요.",
                                              additionalActions: [action])
                    owner.showAlert.accept(alertInfo)
                }
            } onError: { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "실패",
                                                 message: "잠시 후 다시 한번 시도해주세요."))
            }
            .disposed(by: disposeBag)
    }
}
