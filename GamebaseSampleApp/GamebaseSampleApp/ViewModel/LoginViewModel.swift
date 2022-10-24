//
//  LoginViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/24.
//

import UIKit
import RxCocoa
import RxSwift
import Gamebase

final class LoginViewModel {
    static let shared = LoginViewModel()
    weak var viewController: UIViewController?
    var loginItems: [CustomImageTitleModel] {
        AppConstants.idPList.map {
            CustomImageTitleModel(icon: "\($0)_logo", title: "\($0) 로그인", etc: $0)
        }
    }
    
    // MARK: - Private
    private var disposeBag = DisposeBag()
    private let routeToHomeView = PublishRelay<Void>()
    private let showAlert = PublishRelay<AlertInfo>()
}

// MARK: - ViewModelType
extension LoginViewModel: ViewModelType {
    struct Input {
        let tryToLogin: PublishRelay<String>
        let openContact: PublishRelay<Void>
    }
    
    struct Output {
        let routeToHomeView: Signal<Void>
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.tryToLogin
            .subscribe(onNext: { [weak self] idpType in
                self?.login(idpType, viewController: self?.viewController ?? UIApplication.topViewController()!)
            })
            .disposed(by: disposeBag)
        
        input.openContact
            .subscribe { [weak self] _ in
                self?.openContact(viewController: self?.viewController ?? UIApplication.topViewController()!)
            }
            .disposed(by: disposeBag)

        
        return Output(routeToHomeView: routeToHomeView.asSignal(),
                      showAlert: showAlert.asSignal())
    }
}

// MARK: - Business logic
extension LoginViewModel {
    private func login(_ idPType: String, viewController: UIViewController) {
        var additionalInfo = [String: Any]()
        
        /*
         TODO: For LINE login, you can register multiple regions to provide services to the console.
         When logging in as an IdP, you must manually enter a region to provide services as an additionalInfo parameter.
         https://docs.toast.com/en/Game/Gamebase/en/ios-authentication/#login-as-the-latest-login-idp
         */
        if idPType == kTCGBAuthLine {
            additionalInfo[kTCGBAuthLoginWithCredentialLineChannelRegionKeyname] = "japan"
        }
        
        GamebaseAsObservable.login(idPType, additionalInfo: additionalInfo, viewController: viewController)
            .observe(on: MainScheduler.asyncInstance)
            .retry(when: GamebaseAsObservable.retryHandler)
            .subscribe { [weak self] authToken in
                guard let self = self else { return }
                
                UserManager.setAuthToken(authToken)
                self.routeToHomeView.accept(())
            } onError: { [weak self] error in
                switch error.gamebaseErrorCode() {
                case .ERROR_BANNED_MEMBER:
                    /*
                     TODO: If you set to TCGBConfiguration.enableBanPopup = false, check the ban information and inform the game user why he cannot play the game.
                     https://docs.toast.com/en/Game/Gamebase/en/ios-authentication/#login-flow
                     */
                    fallthrough
                default:
                    self?.showAlert.accept(AlertInfo(title: "로그인 실패", message: "잠시 후 다시 시도해주세요."))
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    private func openContact(viewController: UIViewController) {
        TCGBContact.openContact(viewController: viewController)
    }
}
