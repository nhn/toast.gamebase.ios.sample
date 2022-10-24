//
//  PushSettingsViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/25.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class PushSettingsViewModel {
    let pushSettingItemList = BehaviorRelay(value: [CustomTitleSwitchModel]())
    
    private var pushConfiguration: TCGBPushConfiguration!
    private var notificationsOptions: TCGBNotificationOptions!
    
    private let isLoading = PublishRelay<Bool>()
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
}

// MARK: - ViewModelType
extension PushSettingsViewModel: ViewModelType {
    struct Input {
        let prepareItems: PublishRelay<Void>
        let enterForeground: PublishRelay<Void>
    }
    
    struct Output {
        let isLoading: Signal<Bool>
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.prepareItems
            .subscribe(onNext: { [weak self] _ in
                self?.isLoading.accept(true)
                self?.getPushSettingItemList()
            })
            .disposed(by: disposeBag)
        
        input.enterForeground
            .flatMap { _ in GamebaseAsObservable.queryNotificationAllowed() }
            .subscribe(onNext: { [weak self] allowed in
                if !allowed {
                    let action = UIAlertAction(title: "설정", style: .default, handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                    })
                    
                    let alertInfo = AlertInfo(title: "알림 설정",
                                              message: "알림 사용을 위한 사용자 설정이 필요합니다.\n기기 설정으로 이동해서 알림을 허용해주세요.",
                                              addCloseAction: false,
                                              additionalActions: [action])
                    
                    self?.showAlert.accept(alertInfo)
                }
            })
            .disposed(by: disposeBag)
        
        return Output(isLoading: isLoading.asSignal(),
                      showAlert: showAlert.asSignal())
    }
}

// MARK: - Business logic
extension PushSettingsViewModel {
    private func getPushSettingItemList() {
        var config = TCGBPushConfiguration()
        let options = TCGBPush.notificationOptions() ?? TCGBNotificationOptions()
        
        GamebaseAsObservable.queryTokenInfo()
            .map { $0.agreement }
            .map { agreement -> TCGBPushConfiguration in
                let configuration = TCGBPushConfiguration()
                configuration.pushEnabled = agreement.pushEnabled
                configuration.adAgreement = agreement.adAgreement
                configuration.adAgreementNight = agreement.adAgreementNight
                return configuration
            }
            .subscribe(onNext: {
                config = $0
            }, onDisposed: { [weak self] in
                guard let self = self else { return }
                self.pushConfiguration = config
                self.notificationsOptions = options
                
                let items = self.pushSettingItems()
                
                self.pushSettingItemList.accept(items)
                self.isLoading.accept(false)
            })
            .disposed(by: disposeBag)
    }
    
    private func registerPush() {
#if DEBUG
        TCGBPush.setSandboxMode(true)
#endif
        TCGBPush.registerPush(configuration: pushConfiguration, notificationOptions: notificationsOptions)
    }
}

// MARK: - Push Setting Item Info
extension PushSettingsViewModel {
    func pushSettingItems() -> [CustomTitleSwitchModel] {
        return [
            CustomTitleSwitchModel(title: "푸시알림 받기", isOn: pushConfiguration.pushEnabled, handler: { [weak self] value in
                self?.pushConfiguration.pushEnabled = value
                self?.registerPush()
            }),
            CustomTitleSwitchModel(title: "광고성 푸시알림 받기", isOn: pushConfiguration.adAgreement, handler: { [weak self] value in
                self?.pushConfiguration.adAgreement = value
                self?.registerPush()
            }),
            CustomTitleSwitchModel(title: "야간 광고성 푸시알림 받기", isOn: pushConfiguration.adAgreementNight, handler: { [weak self] value in
                self?.pushConfiguration.adAgreementNight = value
                self?.registerPush()
            }),
            CustomTitleSwitchModel(title: "앱 활성화 중에도 푸시알림 받기", isOn: notificationsOptions.foregroundEnabled, handler: { [weak self] value in
                self?.notificationsOptions.foregroundEnabled = value
                self?.registerPush()
            }),
        ]
    }
}
