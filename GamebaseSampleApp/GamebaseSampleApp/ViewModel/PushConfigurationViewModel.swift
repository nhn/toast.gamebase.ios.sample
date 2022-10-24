//
//  PushConfigurationViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/08.
//

import Foundation
import RxCocoa
import RxSwift
import Gamebase

final class PushConfigurationViewModel {        
    private let isLoading = PublishRelay<Bool>()
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
    
    private let pushConfiguration = TCGBPushConfiguration()
    private let notificationOptions = TCGBPush.notificationOptions() ?? TCGBNotificationOptions()
}

extension PushConfigurationViewModel: ViewModelType {
    struct Input {
        let registerPush: PublishRelay<Void>
    }
    
    struct Output {
        let isLoading: Signal<Bool>
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.registerPush
            .subscribe { [weak self] _ in
                self?.isLoading.accept(true)
                self?.registerPush()
            }
            .disposed(by: disposeBag)
        
        return Output(isLoading: isLoading.asSignal(), showAlert: showAlert.asSignal())
    }
}

extension PushConfigurationViewModel {
    func getPushEnabled() -> Bool {
        return self.pushConfiguration.pushEnabled
    }
    
    func setPushEnabled(_ agreement: Bool) {
        self.pushConfiguration.pushEnabled = agreement
    }
    
    func getAdAgreement() -> Bool {
        return self.pushConfiguration.adAgreement
    }
    
    func setAdAgreement(_ agreement: Bool) {
        self.pushConfiguration.adAgreement = agreement
    }
    
    func getAdAgreementNight() -> Bool {
        return self.pushConfiguration.adAgreementNight
    }
    
    func setAdAgreementNight(_ agreement: Bool) {
        self.pushConfiguration.adAgreementNight = agreement
    }
    
    func getForegroundEnabled() -> Bool {
        return self.notificationOptions.foregroundEnabled
    }
    
    func setForegroundEnabled(_ enabled: Bool) {
        self.notificationOptions.foregroundEnabled = enabled
    }
    
    func getBadgeEnabled() -> Bool {
        return self.notificationOptions.badgeEnabled
    }
    
    func setBadgeEnabled(_ enabled: Bool) {
        self.notificationOptions.badgeEnabled = enabled
    }
    
    func getSoundEnabled() -> Bool {
        return self.notificationOptions.soundEnabled
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        self.notificationOptions.soundEnabled = enabled
    }
}


extension PushConfigurationViewModel {
    private func registerPush() {
        GamebaseAsObservable.registerPush(configuration: self.pushConfiguration, notificationOptions: self.notificationOptions)
            .subscribe { [weak self] _ in
                self?.isLoading.accept(false)
                self?.showAlert.accept(AlertInfo(title: "푸시 설정 등록 성공", message: "푸시 설정을 등록했습니다."))
            } onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.showAlert.accept(AlertInfo(title: "푸시 설정 등록 실패", message: "\(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
}
