//
//  IntroViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/06.
//

import UIKit
import RxSwift
import RxCocoa
import Gamebase

final class IntroViewModel {
    static let shared = IntroViewModel()
    private var disposeBag = DisposeBag()
    weak var viewController: UIViewController?
    
    /*
     TODO: Change to your Gamebase project AppID
     */
    private let appInfo = InitializeInfo(appID: "6ypq5kwa", appVersion: "1.0.0")
    private let isAppPermissionAgreed = UserDefaults.standard.rx.observe(Bool.self, UserDefaults.isAppPermissionAgreedKeyname).map { $0 ?? false }
    private let routeToChildView = PublishRelay<String>()
    private let showAlert = PublishRelay<AlertInfo>()
}

// MARK: - ViewModelType
extension IntroViewModel: ViewModelType {
    struct Input {
        let prepareToPlay: PublishRelay<Void>
    }
    
    struct Output {
        let isAppPermissionAgreed: Signal<Bool>
        let routeToChildView: Signal<String>
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.prepareToPlay
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                UserManager.reset()
                self.initializeGamebase()
            }
            .disposed(by: disposeBag)
        
        return Output(isAppPermissionAgreed: isAppPermissionAgreed.asSignal(onErrorJustReturn: false),
                      routeToChildView: routeToChildView.asSignal(),
                      showAlert: showAlert.asSignal())
    }

}

// MARK: - Business logic
extension IntroViewModel {
    private func initializeGamebase() {
#if DEBUG
        TCGBGamebase.setDebugMode(true)
#endif
        let config: TCGBConfiguration = TCGBConfiguration.configuration(appID: appInfo.appID,
                                                                        appVersion: appInfo.appVersion)
        config.enablePopup(true)
        config.enableLaunchingStatusPopup(true)
        config.enableBanPopup(true)

        GamebaseAsObservable.initialize(configuration: config)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                if self.checkServiceAvailable() {
                    self.showTermsView()
                }
            } onError: { [weak self] _ in
                let action = UIAlertAction(title: "닫기", style: .default) { _ in
                    UIApplication.terminateApp()
                }
                
                self?.showAlert.accept(AlertInfo(title: "게임을 플레이할 수 없습니다.",
                                                 message: "잠시 후 다시 실행해주세요. 문제가 계속될 경우 관리자에게 문의해주세요.",
                                                 addCloseAction: false,
                                                 additionalActions: [action]))
            }
            .disposed(by: self.disposeBag)
    }
    
    private func checkServiceAvailable() -> Bool {
        let status = TCGBLaunching.launchingStatus()
        
        switch status {
        case .IN_SERVICE,
                .RECOMMEND_UPDATE,
                .IN_SERVICE_BY_QA_WHITE_LIST,
                .IN_TEST,
                .IN_REVIEW,
                .IN_BETA:
            return true
            
        case .REQUIRE_UPDATE,
                .BLOCKED_USER,
                .TERMINATED_SERVICE,
                .INSPECTING_SERVICE,
                .INSPECTING_ALL_SERVICES,
                .INTERNAL_SERVER_ERROR:
            return false
            
        @unknown default:
            return false
        }
    }
    
    private func showTermsView() {
        GamebaseAsObservable.showTermsView(viewController: viewController)
            .subscribe { [weak self] dataContainer in
                /* Cache PushTokenInfo */
                if let gbPushConfiguration = TCGBPushConfiguration.fromDataContainer(dataContainer) {
                    UserDefaultManager.appPushConfiguration = AppPushConfiguration(gbPushConfiguration: gbPushConfiguration)
                }
                
                self?.startLoginForLastLoggedInProviderFlow()
            } onError: { [weak self] _ in
                let action = UIAlertAction(title: "닫기", style: .default) { _ in
                    UIApplication.terminateApp()
                }
                
                let alertInfo = AlertInfo(title: "알 수 없는 에러가 발생했습니다.",
                                          message: "앱을 재실행 시켜주세요.",
                                          addCloseAction: false,
                                          additionalActions: [action])
                self?.showAlert.accept(alertInfo)
            }
            .disposed(by: self.disposeBag)
    }
    
    private func startLoginForLastLoggedInProviderFlow() {
        GamebaseAsObservable.loginForLastLoggedInProvider(viewController: viewController ?? UIApplication.topViewController()!)
            .observe(on: MainScheduler.asyncInstance)
            .retry(when: GamebaseAsObservable.retryHandler)
            .subscribe { [weak self] authToken in
                guard let self = self else { return }
                
                UserManager.setAuthToken(authToken)
                self.routeToChildView.accept(HomeViewController.segueID)
            } onError: { [weak self] error in
                guard let self = self else { return }
                
                switch error.gamebaseErrorCode() {
                case .ERROR_BANNED_MEMBER:
                    /*
                     TODO: If you set to TCGBConfiguration.enableBanPopup = false, check the ban information and inform the game user why he cannot play the game.
                     https://docs.toast.com/en/Game/Gamebase/en/ios-authentication/#login-flow
                     */
                    self.routeToChildView.accept(LoginViewController.segueID)
                default:
                    self.startIdPLoginFlow()
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func startIdPLoginFlow() {
        guard let loginIdP = TCGBGamebase.lastLoggedInProvider(), let _ = TCGBGamebase.accessToken() else {
            self.routeToChildView.accept(LoginViewController.segueID)
            return
        }
        
        let alertInfo = AlertInfo(title: "IdP 로그인 시도",
                                  message: "알 수 없는 이유로 자동 로그인에 실패했습니다. 가장 최근에 로그인했던 IdP로 로그인을 재시도합니다.",
                                  addCloseAction: false,
                                  confirmHandler: { [weak self] _ in
            self?.login(loginIdP)
        })
        
        self.showAlert.accept(alertInfo)
    }
    
    private func login(_ idPType: String) {
        var additionalInfo = [String: Any]()
        
        /*
         TODO: For LINE login, you can register multiple regions to provide services to the console.
         When logging in as an IdP, you must manually enter a region to provide services as an additionalInfo parameter.
         https://docs.toast.com/en/Game/Gamebase/en/ios-authentication/#login-as-the-latest-login-idp
         */
        if idPType == kTCGBAuthLine {
            additionalInfo[kTCGBAuthLoginWithCredentialLineChannelRegionKeyname] = "japan"
        }
        
        GamebaseAsObservable.login(idPType, additionalInfo: additionalInfo, viewController: viewController ?? UIApplication.topViewController()!)
            .observe(on: MainScheduler.asyncInstance)
            .retry(when: GamebaseAsObservable.retryHandler)
            .subscribe { [weak self] _ in
                guard let self = self else { return }
                self.routeToChildView.accept(HomeViewController.segueID)
            } onError: { [weak self] error in
                guard let self = self else { return }
                
                switch error.gamebaseErrorCode() {
                case .ERROR_BANNED_MEMBER:
                    /*
                     TODO: If you set to TCGBConfiguration.enableBanPopup = false, check the ban information and inform the game user why he cannot play the game.
                     https://docs.toast.com/en/Game/Gamebase/en/ios-authentication/#login-flow
                     */
                    fallthrough
                default:
                    self.routeToChildView.accept(LoginViewController.segueID)
                }
            }
            .disposed(by: disposeBag)
    }
}

fileprivate extension AppPushConfiguration {
    init(gbPushConfiguration: TCGBPushConfiguration) {
        self.init(pushEnabled: gbPushConfiguration.pushEnabled,
                  adAgreement: gbPushConfiguration.adAgreement,
                  adAgreementNight: gbPushConfiguration.adAgreementNight)
    }
}
