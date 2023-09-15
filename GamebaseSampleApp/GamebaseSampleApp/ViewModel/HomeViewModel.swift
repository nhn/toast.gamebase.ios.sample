//
//  HomeViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/30.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase
import UIKit

final class HomeViewModel {
    private weak var viewController: UIViewController?
    
    private var disposeBag = DisposeBag()
    private let isLoading = PublishRelay<Bool>()
    private let showAlert = PublishRelay<AlertInfo>()
    private let routeToRootView = PublishRelay<Void>()
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - ViewModelType
extension HomeViewModel: ViewModelType {    
    struct Input {
        let prepareHome: PublishRelay<Void>
    }
    
    struct Output {
        let isLoading: Signal<Bool>
        let showAlert: Signal<AlertInfo>
        let routeToRootView: Signal<Void>
    }
    
    func transform(input: Input) -> Output {
        input.prepareHome
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(true)
                self?.startRegisterPushFlow()
            })
            .flatMap { _ in
                /*
                 [NOTICE]
                 Request a list of non-consumed items, which have not been normally consumed (delivered, or provided) after purchase.
                 https://docs.toast.com/en/Game/Gamebase/en/ios-purchase/#list-non-consumed-items
                 */
                GamebaseAsObservable.requestItemListOfNotConsumed()
            }
            .do(onNext: { [weak self] _ in
                /*
                 [NOTICE]
                 In case there is any non-purchased item, request the game server (item server) to proceed with item delivery (provision).
                 */
                self?.isLoading.accept(false)
            })
            .flatMap { [weak self] _ in
                GamebaseAsObservable.showImageNotices(viewController: self?.viewController)
            }
            .filter { _ in UserManager.isTemporaryWithdrawalUser() }
            .compactMap { _ in UserManager.temporaryWithdrawalGracePeriod() }
            .map { Double($0 / 1000) }
            .map { Date(timeIntervalSince1970: $0) }
            .map { date -> String in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy년 MM월 dd일 HH시 mm분"
                return dateFormatter.string(from: date)
            }
            .subscribe(with: self) { owner, date in
                let actions = [
                    UIAlertAction(title: "철회하기", style: .destructive, handler: { [weak self] _ in
                        self?.cancelTemporaryWithdrawal()
                    })
                ]
                let alertInfo = AlertInfo(title: "주의",
                                          message: "\(date) 이후 계정이 탈퇴됩니다.\n탈퇴 유예를 철회하고 싶으시면, '철회하기' 버튼을 눌러주세요.",
                                          additionalActions: actions)
                owner.showAlert.accept(alertInfo)
            }
            .disposed(by: disposeBag)

        return Output(isLoading: isLoading.asSignal(),
                      showAlert: showAlert.asSignal(),
                      routeToRootView: routeToRootView.asSignal())
    }
}

extension HomeViewModel {
    private func startRegisterPushFlow() {
        let cachedPushConfiguration = UserDefaultManager.appPushConfiguration
        
        if let cachedPushConfiguration = cachedPushConfiguration {
            let gbPushConfiguration = TCGBPushConfiguration(appPushConfiguration: cachedPushConfiguration)
            let gbNotificationOptions = TCGBPush.notificationOptions() ?? TCGBNotificationOptions()
            
            self.registerPush(configuration: gbPushConfiguration, notificationOptions: gbNotificationOptions)
            UserDefaultManager.appPushConfiguration = nil
            return
        }
        
        GamebaseAsObservable.queryTokenInfo()
            .map { $0.agreement }
            .map { agreement -> TCGBPushConfiguration in
                let configuration = TCGBPushConfiguration()
                configuration.pushEnabled = agreement.pushEnabled
                configuration.adAgreement = agreement.adAgreement
                configuration.adAgreementNight = agreement.adAgreementNight
                /*
                 [NOTICE]
                 If a user has denied push permission but you still want to register a push token, please set `alwaysAllowTokenRegistration` to `true`.
                 `alwaysAllowTokenRegistration` to `true`, the app will be able to receive push messages without requiring the user to restart the app, as long as they grant permission for notifications in the device settings.
                 */
                configuration.alwaysAllowTokenRegistration = false
                return configuration
            }
            .subscribe(with: self) { owner, config in
                let options = TCGBPush.notificationOptions()
                owner.registerPush(configuration: config, notificationOptions: options)
            }
            .disposed(by: disposeBag)
    }
    
    private func registerPush(configuration: TCGBPushConfiguration, notificationOptions: TCGBNotificationOptions?) {
#if DEBUG
        TCGBPush.setSandboxMode(true)
#endif
        TCGBPush.registerPush(configuration: configuration, notificationOptions: notificationOptions)
    }
    
    private func cancelTemporaryWithdrawal() {
        GamebaseAsObservable.cancelTemporaryWithdrawal()
            .subscribe(with: self) { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "탈퇴 유예 철회 성공"))
            } onError: { owner, error in
                owner.showAlert.accept(AlertInfo(title: "탈퇴 유예 철회 실패",
                                                 message: "잠시 후 'Developer > 탈퇴 유예 철회' 버튼을 눌러서 다시 시도해주세요."))
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Gamebase Event Handler
extension HomeViewModel {
    func registerEventHandler() {
        TCGBGamebase.addEventHandler { [weak self] in
            if $0.category == TCGBGamebaseEventCategory.loggedOut.rawValue {
                self?.showAlertForRouteToRootView(title: "로그아웃", message: "Gamebase Access Token이 만료되었습니다. 다시 로그인해주세요.")
            } else if $0.category == TCGBGamebaseEventCategory.serverPushAppKickoutMessageReceived.rawValue {
                /*
                 [NOTICE]
                 If you register a kickout ServerPush message in Operation > Kickout in the NHN Cloud Gamebase console, all clients connected to Gamebase will receive a kickout message.
                 This event occurs immediately after receiving a server message from the client device.
                 It can be used to pause the game when the game is running, as in the case of 'Auto Play'.
                 */
            } else if $0.category == TCGBGamebaseEventCategory.serverPushAppKickout.rawValue {
                self?.showAlertForTerminateApp(title: "킥아웃 되었습니다.", message: "킥아웃 ServerPush 메시지를 수신하여 킥아웃 되었습니다.")
            } else if $0.category == TCGBGamebaseEventCategory.serverPushTransferKickout.rawValue {
                self?.showAlertForTerminateApp(title: "킥아웃 되었습니다.", message: "Guest 계정이 다른 단말기로 이전되어 킥아웃 되었습니다.")
            } else if $0.category == TCGBGamebaseEventCategory.observerLaunching.rawValue {
                let observerData = TCGBGamebaseEventObserverData.gamebaseEventObserverData(jsonString: $0.data)
                self?.launchingStatusChanged(observerData: observerData)
            } else if $0.category == TCGBGamebaseEventCategory.observerHeartbeat.rawValue {
                let observerData = TCGBGamebaseEventObserverData.gamebaseEventObserverData(jsonString: $0.data)
                self?.accountStatusChanged(observerData: observerData)
            } else if $0.category == TCGBGamebaseEventCategory.idPRevoked.rawValue {
                let idPRevokedData = TCGBGamebaseEventIdPRevokedData.gamebaseEventIdPRevokedData(jsonString: $0.data)
                self?.idPRevoked(idPRevokedData: idPRevokedData)
            }
        }
    }
    
    private func launchingStatusChanged(observerData: TCGBGamebaseEventObserverData) {
        switch observerData.code {
        case Int64(TCGBLaunchingStatus.IN_SERVICE.rawValue):
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "서비스 이용 가능 상태로 변경되었습니다.")
        case Int64(TCGBLaunchingStatus.RECOMMEND_UPDATE.rawValue):
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "업데이트가 가능합니다.")
        case Int64(TCGBLaunchingStatus.REQUIRE_UPDATE.rawValue):
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "필수 업데이트를 진행해 주세요")
        case Int64(TCGBLaunchingStatus.BLOCKED_USER.rawValue):
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "접속 차단으로 등록된 단말기로 서비스에 접속했습니다.")
        case Int64(TCGBLaunchingStatus.TERMINATED_SERVICE.rawValue):
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "서비스가 종료되었습니다.")
        case Int64(TCGBLaunchingStatus.INSPECTING_SERVICE.rawValue):
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "서비스가 점검 중입니다.")
        case Int64(TCGBLaunchingStatus.INSPECTING_ALL_SERVICES.rawValue):
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "전체 서비스가 점검 중입니다.")
        default:
            self.showAlertForRouteToRootView(title: "서비스 상태 변경", message: "서비스 상태가 변경되었습니다.(\(observerData.code)")
            break
        }
    }
    
    private func accountStatusChanged(observerData: TCGBGamebaseEventObserverData) {
        switch observerData.code {
        case Int64(TCGBErrorCode.ERROR_BANNED_MEMBER.rawValue):
            self.showAlertForRouteToRootView(title: "계정 상태 변경", message: "이용 정지로 계정 상태가 변경되었습니다.")
        case Int64(TCGBErrorCode.ERROR_INVALID_MEMBER.rawValue):
            self.showAlertForRouteToRootView(title: "계정 상태 변경", message: "탈퇴 처리로 계정 상태가 변경되었습니다.")
        default:
            break;
        }
    }
    
    private func idPRevoked(idPRevokedData: TCGBGamebaseEventIdPRevokedData) {
        switch idPRevokedData.code {
        case Int64(TCGBIdPRevokedCode.IDP_REVOKED_WITHDRAW.rawValue):
            self.idPRevokedWithdrawProcess(idPRevokedData: idPRevokedData)
        case Int64(TCGBIdPRevokedCode.IDP_REVOKED_OVERWRITE_LOGIN_AND_REMOVE_MAPPING.rawValue):
            self.idPRevokedOverwriteLoginAndRemoveMappingProcess(idPRevokedData: idPRevokedData)
        case Int64(TCGBIdPRevokedCode.IDP_REVOKED_REMOVE_MAPPING.rawValue):
            self.idPRevokedRemoveMappingProcess(idPRevokedData: idPRevokedData)
        default:
            break;
        }
    }
    
    private func idPRevokedWithdrawProcess(idPRevokedData: TCGBGamebaseEventIdPRevokedData) {
        let revokedIdP = idPRevokedData.idPType
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.withdraw()
        }
        let alertInfo = AlertInfo(title: "\(revokedIdP)가 사용 중지 됨",
                                  message: "현재 사용 중지된 IdP로 로그인되어 있고, 대체 할 수 있는 매핑된 IdP 목록이 없어 탈퇴 처리를 진행합니다.",
                                  addCloseAction: false,
                                  additionalActions: [action])
        self.showAlert.accept(alertInfo)
    }

    private func idPRevokedOverwriteLoginAndRemoveMappingProcess(idPRevokedData: TCGBGamebaseEventIdPRevokedData) {
        let revokedIdP = idPRevokedData.idPType
        let mappingList = idPRevokedData.authMappingList
        
        let actions = mappingList.map { idPType in
            UIAlertAction(title: idPType, style: .default, handler: { [weak self] _ in
                self?.loginForRemoveMapping(idPType: idPType,
                                            revokedIdP: revokedIdP,
                                            additionalInfo: [kTCGBAuthLoginWithCredentialIgnoreAlreadyLoggedInKeyname: true],
                                            title: "\(idPType) 로그인, \(revokedIdP) 연동 해제")
            })
        }
        
        let alertInfo = AlertInfo(title: "\(revokedIdP)가 사용 중지 됨",
                                  message: "현재 사용 중지된 IdP로 로그인되어 있어 해당 IdP는 연동 해제 합니다. 로그인할 다른 IdP를 선택하세요.",
                                  addCloseAction: false,
                                  additionalActions: actions)
        self.showAlert.accept(alertInfo)
    }

    private func idPRevokedRemoveMappingProcess(idPRevokedData: TCGBGamebaseEventIdPRevokedData) {
        let revokedIdP = idPRevokedData.idPType
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.removeMapping(idPType: revokedIdP, title: "계정 연동 해제")
        }
        let alertInfo = AlertInfo(title: "\(revokedIdP)가 사용 중지 됨",
                                  message: "현재 계정에 매핑된 IdP 중 사용 중지된 IdP가 있어 해당 IdP의 계정 연동을 해제합니다.",
                                  addCloseAction: false,
                                  additionalActions: [action])
        self.showAlert.accept(alertInfo)
    }
    
    private func withdraw() {
        GamebaseAsObservable.withdraw()
            .subscribe(with: self) { owner, _ in
                owner.routeToRootView.accept(())
            } onError: { owner, _ in
                owner.showAlertForTerminateApp(title: "탈퇴하기 실패",
                                               message: "알 수 없는 이유로 탈퇴하기에 실패했습니다. 앱을 종료합니다.")
            }
            .disposed(by: disposeBag)
    }
    
    private func loginForRemoveMapping(idPType: String, revokedIdP: String, additionalInfo: [String: Any], title: String) {
        GamebaseAsObservable.login(idPType, additionalInfo: additionalInfo, viewController: self.viewController ?? UIApplication.topViewController()!)
            .subscribe(with: self) { owner, _ in
                owner.removeMapping(idPType: revokedIdP, title: title)
            } onError: { owner, error in
                owner.showAlertForTerminateApp(title: title,
                                               message: "알 수 없는 이유로 로그인에 실패했습니다. 앱을 종료합니다.")
            }
            .disposed(by: disposeBag)
    }
    
    private func removeMapping(idPType: String, title: String, message: String? = nil) {
        GamebaseAsObservable.removeMapping(idPType, viewController: self.viewController)
            .subscribe(with: self) { owner, _ in
                owner.routeToRootView.accept(())
            } onError: { owner, _ in
                owner.showAlertForTerminateApp(title: title,
                                               message: "알 수 없는 이유로 연동 해제에 실패했습니다. 앱을 종료합니다.")
            }
            .disposed(by: disposeBag)
    }
    
    private func showAlertForRouteToRootView(title: String, message: String?) {
        let action = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            self?.routeToRootView.accept(())
        }
        let alertInfo = AlertInfo(title: title, message: message, addCloseAction: false, additionalActions: [action])
        self.showAlert.accept(alertInfo)
    }
    
    private func showAlertForTerminateApp(title: String, message: String?) {
        let action = UIAlertAction(title: "확인", style: .default) { _ in
            UIApplication.terminateApp()
        }
        self.showAlert.accept(AlertInfo(title: title, message: message, addCloseAction: false, additionalActions: [action]))
    }
}
