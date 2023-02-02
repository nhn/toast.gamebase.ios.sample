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
            .subscribe(with: self) { owner, idpType in
                owner.login(idpType, viewController: owner.viewController ?? UIApplication.topViewController()!)
            }
            .disposed(by: disposeBag)
        
        input.openContact
            .subscribe(with: self) { owner, _ in
                owner.openContact(viewController: owner.viewController ?? UIApplication.topViewController()!)
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
         [NOTICE]
         For LINE login, you can register multiple regions to provide services to the console.
         When logging in as an IdP, you must manually enter a region to provide services as an additionalInfo parameter.
         https://docs.toast.com/en/Game/Gamebase/en/ios-authentication/#login-with-idp
         */
        if idPType == kTCGBAuthLine {
            additionalInfo[kTCGBAuthLoginWithCredentialLineChannelRegionKeyname] = "japan"
        }
        
        GamebaseAsObservable.login(idPType, additionalInfo: additionalInfo, viewController: viewController)
            .observe(on: MainScheduler.asyncInstance)
            .retry(when: GamebaseAsObservable.retryHandler)
            .subscribe(with: self) { owner, authToken in
                UserManager.setAuthToken(authToken)
                owner.routeToHomeView.accept(())
            } onError: { owner, error in
                switch error.gamebaseErrorCode() {
                case .ERROR_AUTH_USER_CANCELED:
                    owner.showAlert.accept(AlertInfo(title: "로그인 취소",
                                                     message: "로그인이 취소되었습니다."))
                case .ERROR_BANNED_MEMBER:
                    /*
                     [NOTICE]
                     If you set to TCGBConfiguration.enableBanPopup = false, check the ban information and inform the game user why he cannot play the game.
                     https://docs.toast.com/en/Game/Gamebase/en/ios-authentication/#login-flow
                     */
                    fallthrough
                default:
                    owner.showAlert.accept(AlertInfo(title: "로그인 실패",
                                                     message: "잠시 후 다시 시도해주세요."))
                }
            }
            .disposed(by: self.disposeBag)
    }
    
    private func openContact(viewController: UIViewController) {
        TCGBContact.openContact(viewController: viewController)
    }
}
