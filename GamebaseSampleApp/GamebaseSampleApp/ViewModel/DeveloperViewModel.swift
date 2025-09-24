//
//  DeveloperViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/22.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class DeveloperViewModel: NSObject {
    private weak var viewController: UIViewController?
    
    private var disposeBag = DisposeBag()
    private let isLoading = PublishRelay<Bool>()
    private let routeToChildView = PublishRelay<String>()
    private let routeToReceiptView = PublishRelay<ReceiptListViewType>()
    private let showAlert = PublishRelay<AlertInfo>()
    
    init(viewController: UIViewController?) {
        super.init()
        self.viewController = viewController
        TCGBLogger.setDelegate(self)
    }
}

// MARK: - ViewModelType
extension DeveloperViewModel: ViewModelType {
    struct Input {
        let requestTemporaryWithdrawal: PublishRelay<Void>
        let cancelTemporaryWithdrawal: PublishRelay<Void>
        let activatedPurchases: PublishRelay<Void>
        let itemListOfNotConsumed: PublishRelay<Void>
        let restorePurchase: PublishRelay<Void>
        let queryTokenInfo: PublishRelay<Void>
        let pushConfiguration: PublishRelay<Void>
        let sendLog: PublishRelay<SendLogInfo>
        let queryTerms: PublishRelay<Void>
        let termsConfiguration: PublishRelay<Void>
        let updateTerms: PublishRelay<Void>
        let imageNoticeConfiguration: PublishRelay<Void>
        let webViewConfiguration: PublishRelay<Void>
        let requestContactURL: PublishRelay<Void>
        let contactConfiguration: PublishRelay<Void>
        let idfa: PublishRelay<Void>
        let deviceLanguage: PublishRelay<Void>
        let deviceCountryCode: PublishRelay<Void>
        let displayLanguage: PublishRelay<Void>
    }

    struct Output {
        let isLoading: Signal<Bool>
        let routeToChildView: Signal<String>
        let routeToReceiptView: Signal<ReceiptListViewType>
        let showAlert: Signal<AlertInfo>
    }

    func transform(input: Input) -> Output {
        input.requestTemporaryWithdrawal
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.requestTemporaryWithdrawal()
            }
            .disposed(by: disposeBag)
        
        input.cancelTemporaryWithdrawal
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.cancelTemporaryWithdrawal()
            }
            .disposed(by: disposeBag)
        
        input.activatedPurchases
            .subscribe(with: self) { owner, _ in
                owner.routeToReceiptView.accept(.activatedPurchases)
            }
            .disposed(by: disposeBag)
        
        input.itemListOfNotConsumed
            .subscribe(with: self) { owner, _ in
                owner.routeToReceiptView.accept(.itemListOfNotConsumed)
            }
            .disposed(by: disposeBag)
        
        input.restorePurchase
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.requestRestorePurchase()
            }
            .disposed(by: disposeBag)
        
        input.queryTokenInfo
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.queryTokenInfo()
            }
            .disposed(by: disposeBag)
        
        input.pushConfiguration
            .subscribe(with: self) { owner, _ in
                owner.pushConfiguration()
            }
            .disposed(by: disposeBag)        
        
        input.sendLog
            .subscribe(with: self) { owner, logInfo in
                owner.sendLog(logInfo: logInfo)
            }
            .disposed(by: disposeBag)
        
        input.queryTerms
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.queryTerms()
            }
            .disposed(by: disposeBag)
        
        input.termsConfiguration
            .subscribe(with: self) { owner, _ in
                owner.termsConfiguration()
            }
            .disposed(by: disposeBag)
        
        input.updateTerms
            .subscribe(with: self) { owner, _ in
                owner.updateTerms()
            }
            .disposed(by: disposeBag)


        input.imageNoticeConfiguration
            .subscribe(with: self) { owner, _ in
                owner.imageNoticeConfiguration()
            }
            .disposed(by: disposeBag)
        
        input.webViewConfiguration
            .subscribe(with: self) { owner, _ in
                owner.webViewConfiguration()
            }
            .disposed(by: disposeBag)
        
        input.requestContactURL
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.requestContactURL()
            }
            .disposed(by: disposeBag)
        
        input.contactConfiguration
            .subscribe(with: self) { owner, _ in
                owner.contactConfiguration()
            }
            .disposed(by: disposeBag)

        input.idfa
            .subscribe(with: self) { owner, _ in
                owner.idfa()
            }
            .disposed(by: disposeBag)
        
        input.deviceLanguage
            .subscribe(with: self) { owner, _ in
                owner.deviceLanguage()
            }
            .disposed(by: disposeBag)
        
        input.deviceCountryCode
            .subscribe(with: self) { owner, _ in
                owner.deviceCountryCode()
            }
            .disposed(by: disposeBag)
        
        input.displayLanguage
            .subscribe(with: self) { owner, _ in
                owner.displayLanguage()
            }
            .disposed(by: disposeBag)
        
        return Output(isLoading: isLoading.asSignal(),
                      routeToChildView: routeToChildView.asSignal(),
                      routeToReceiptView: routeToReceiptView.asSignal(),
                      showAlert: showAlert.asSignal())
    }
}

// MARK: - Business logic (Auth)
extension DeveloperViewModel {
    private func requestTemporaryWithdrawal() {
        GamebaseAsObservable.requestTemporaryWithdrawal()
            .subscribe(with: self) { owner, info in
                owner.showAlert.accept(AlertInfo(title: "탈퇴 유예 성공",
                                                 message: "info => \(info.description)"))
            } onError: { owner, error in
                owner.showAlert.accept(AlertInfo(title: "탈퇴 유예 실패",
                                                 message: "error => \(error.localizedDescription)"))
            } onDisposed: { owner in
                owner.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
    }
    
    private func cancelTemporaryWithdrawal() {
        GamebaseAsObservable.cancelTemporaryWithdrawal()
            .subscribe(with: self) { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "탈퇴 유예 철회 성공"))
            } onError: { owner, error in
                owner.showAlert.accept(AlertInfo(title: "탈퇴 유예 철회 실패",
                                                 message: "error => \(error.localizedDescription)"))
            } onDisposed: { owner in
                owner.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Business logic (IAP)
extension DeveloperViewModel {
    private func requestRestorePurchase() {
        GamebaseAsObservable.requestRestorePurchase()
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(false)
                owner.showAlert.accept(AlertInfo(title: "구매 내역 복원 성공",
                                                 message: "구매 내역을 복원했습니다."))
            } onError: { owner, error in
                owner.isLoading.accept(false)
                owner.showAlert.accept(AlertInfo(title: "구매 내역 복원 실패",
                                                 message: "구매 내역 복원에 실패했습니다.\n\n\(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
}

// MARK: - Business logic (Push)
extension DeveloperViewModel{
    private func queryTokenInfo() {
        GamebaseAsObservable.queryTokenInfo()
            .subscribe(with: self) { owner, pushTokenInfo in
                owner.isLoading.accept(false)
                owner.showAlert.accept(AlertInfo(title: "푸시 설정 조회 성공",
                                                 message: "\(pushTokenInfo.prettyJsonString())",
                                                 clipboardCopyable: true))
            } onError: { owner, error in
                owner.isLoading.accept(false)
                owner.showAlert.accept(AlertInfo(title: "푸시 설정 조회 실패",
                                                 message: "푸시 설정 정보를 가져오지 못했습니다.\n\n\(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
    
    private func pushConfiguration() {
        self.routeToChildView.accept(PushConfigurationViewController.segueID)
    }
}

// MARK: - Business logic (Logger)
extension DeveloperViewModel {
    func initialzeLogger() {
        let textFields = [
            AlertTextFieldInfo(placeholder: "AppKey")
        ]
        
        let alertInfo = AlertInfo(title: "Logger 초기화", textFields: textFields, confirmHandler: { [weak self] alert in
            guard let appKey = alert.textFields?[0].text, !appKey.isEmpty else {
                self?.showAlert.accept(AlertInfo(title: "Logger 초기화 실패", message: "AppKey를 입력해주세요."))
                return
            }
            
            let loggerConfiguration = TCGBLoggerConfiguration.configuration(appKey: appKey)
            TCGBLogger.initialize(configuration: loggerConfiguration)
        })
        self.showAlert.accept(alertInfo)
    }
    
    private func sendLog(logInfo: SendLogInfo) {
        let textFields = [
            AlertTextFieldInfo(placeholder: "Log message"),
            AlertTextFieldInfo(placeholder: "User defined key"),
            AlertTextFieldInfo(placeholder: "User defined value")
        ]
        
        let alertInfo = AlertInfo(title: logInfo.title,
                                  textFields: textFields,
                                  confirmHandler: { [weak self] alert in
            guard let message = alert.textFields?[0].text, !message.isEmpty else {
                self?.showAlert.accept(AlertInfo(title: "로그 전송 실패", message: "메시지를 입력해주세요."))
                return
            }
            
            var userFields: [String: String]? {
                if let key = alert.textFields?[1].text, let value = alert.textFields?[2].text {
                    return [key: value]
                }
                return nil
            }
            
            switch logInfo.type {
            case .debug:
                TCGBLogger.debug(message: message, userFields: userFields)
            case .info:
                TCGBLogger.info(message: message, userFields: userFields)
            case .warn:
                TCGBLogger.warn(message: message, userFields: userFields)
            case .error:
                TCGBLogger.error(message: message, userFields: userFields)
            case .fatal:
                TCGBLogger.fatal(message: message, userFields: userFields)
            }
        })
        
        self.showAlert.accept(alertInfo)
    }
}
 
// MARK: - Business logic (Terms)
extension DeveloperViewModel {
    private func queryTerms() {
        GamebaseAsObservable.queryTerms()
            .subscribe(with: self) { owner, queryTermsResult in
                owner.isLoading.accept(false)
                owner.showAlert.accept(AlertInfo(title: "약관 정보 조회 성공",
                                                 message: "\(queryTermsResult.prettyJsonString())",
                                                 clipboardCopyable: true))
            } onError: { owner, error in
                owner.isLoading.accept(false)
                owner.showAlert.accept(AlertInfo(title: "약관 정보 조회 실패",
                                                 message: "약관 정보를 가져오지 못했습니다.\n\n\(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
    
    private func termsConfiguration() {
        self.routeToChildView.accept(TermsConfigurationViewController.segueID)
    }
    
    private func updateTerms() {
        self.routeToChildView.accept(UpdateTermsViewController.segueID)
    }
}
 
// MARK: - Business logic (ImageNotice)
extension DeveloperViewModel {
    func showImageNotices() {
        TCGBImageNotice.showImageNotices(viewController: self.viewController)
    }
    
    private func imageNoticeConfiguration() {
        self.routeToChildView.accept(ImageNoticeConfigurationViewController.segueID)
    }
}

// MARK: - Business logic (GameNotice)
extension DeveloperViewModel {
    func showGameNotices() {
        TCGBGameNotice.openGameNotice(viewController: self.viewController)
    }
}

// MARK: - Business logic (WebView)
extension DeveloperViewModel {
    func showWebView() {
        let textFields = [
            AlertTextFieldInfo(defaultText: "https://www.nhncloud.com/kr/service/game/gamebase", placeholder: "URL 입력")
        ]
        
        let alertInfo = AlertInfo(title: "웹뷰 열기",
                                  textFields: textFields,
                                  confirmHandler: { [weak self] alert in
            guard let urlString = alert.textFields?[0].text, !urlString.isEmpty else { return }
            
            TCGBWebView.showWebView(urlString: urlString,
                                    viewController: self?.viewController,
                                    configuration: nil,
                                    closeCompletion: nil,
                                    schemeList: nil)
        })
        self.showAlert.accept(alertInfo)
    }
    
    func openWebBrowser() {
        let textFields = [
            AlertTextFieldInfo(defaultText: "https://www.nhncloud.com/kr/service/game/gamebase", placeholder: "URL 입력")
        ]
        
        let alertInfo = AlertInfo(title: "외부 브라우저 열기",
                                  textFields: textFields,
                                  confirmHandler: { alert in
            guard let urlString = alert.textFields?[0].text, !urlString.isEmpty else { return }
            TCGBWebView.openWebBrowser(urlString: urlString)
        })
        self.showAlert.accept(alertInfo)
    }

    private func webViewConfiguration() {
        self.routeToChildView.accept(WebViewConfigurationViewController.segueID)
    }
}

// MARK: - Business logic (Popup)
extension DeveloperViewModel {
    func showGamebaseAlert() {
        TCGBUtil.showAlert(title: "Alert", message: "Alert 입니다.")
    }
    
    func showGamebaseActionSheet() {
        let handler: @convention(block) (UIAlertAction) -> Void = { [weak self] action in
            self?.showAlert.accept(AlertInfo(title: "ActionSheet", message: "\(action.title!) 입니다."))
        }

        let blocks = [
            "첫 번째 액션": handler,
            "두 번째 액션": handler
        ]
        
        TCGBUtil.showActionSheet(title: "ActionSheet", message: "ActionSheet 입니다.", blocks: blocks)
    }
    
    func showGamebaseToastShort() {
        TCGBUtil.showToast(message: "짧은 토스트 메시지 입니다.", length: GamebaseToastLength.short)
    }
    
    func showGamebaseToastLong() {
        TCGBUtil.showToast(message: "긴 토스트 메시지 입니다.", length: GamebaseToastLength.long)
    }
}

// MARK: - Business logic (Analytics)
extension DeveloperViewModel {
    func setGameUserData() {
        let textFields = [
            AlertTextFieldInfo(placeholder: "Level(Int)"),
            AlertTextFieldInfo(placeholder: "Channel ID"),
            AlertTextFieldInfo(placeholder: "Character ID")
        ]
        
        let alertInfo = AlertInfo(title: "Analytics",
                                  message: "레벨 정보 설정 지표 전송",
                                  textFields: textFields, confirmHandler: { alert in
            guard let level = alert.textFields?[0].text, !level.isEmpty else { return }
            guard let levelInt = Int32(level) else { return }
            
            let channelId  = alert.textFields?[1].text
            let characterId = alert.textFields?[2].text
            
            let gameUserData = TCGBAnalyticsGameUserData(userLevel: levelInt)
            gameUserData.channelId = channelId
            gameUserData.characterId = characterId
            
            TCGBAnalytics.setGameUserData(gameUserData)
        })
        self.showAlert.accept(alertInfo)
    }
    
    func traceLevelUpData() {
        let textFields = [
            AlertTextFieldInfo(placeholder: "User level(Int)")
        ]
        
        let alertInfo = AlertInfo(title: "Analytics",
                                  message: "레벨업 정보 지표 전송",
                                  textFields: textFields, confirmHandler: { alert in
            guard let userLevel = alert.textFields?[0].text, !userLevel.isEmpty else { return }
            guard let userLevelInt = Int32(userLevel) else { return }
            
            let levelUpTime = NSDate().timeIntervalSince1970 * 1000
            let levelUpData = TCGBAnalyticsLevelUpData(userLevel: userLevelInt,
                                                       levelUpTime: Int64(levelUpTime))
            
            TCGBAnalytics.traceLevelUp(levelUpData: levelUpData)
        })
        self.showAlert.accept(alertInfo)
    }
}

// MARK: - Business logic (Contact)
extension DeveloperViewModel {
    private func requestContactURL() {
        GamebaseAsObservable.requestContactURL()
            .do(onNext: { [weak self] _ in
                self?.isLoading.accept(false)
            })
            .subscribe(with: self) { owner, contactURL in
                owner.showAlert.accept(AlertInfo(title: "고객센터 URL",
                                                 message: "\(contactURL)",
                                                 clipboardCopyable: true))
            } onError: { owner, error in
                owner.showAlert.accept(AlertInfo(title: "고객센터 URL",
                                                 message: "고객센터 URL을 가져오지 못했습니다.\nerror=> \(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
    
    private func contactConfiguration() {
        self.routeToChildView.accept(ContactConfigurationViewController.segueID)
    }
}

// MARK: - Business logic (ETC)
extension DeveloperViewModel {
    func osVersion() -> String {
        return TCGBUtil.osVersion()
    }
    
    func idfa() {
        let idfa = TCGBUtil.idfa()
        self.showAlert.accept(AlertInfo(title: "IDFA", message: idfa, clipboardCopyable: true))
    }
    
    func deviceLanguage() {
        let deviceLanguage = TCGBUtil.deviceLanguageCode()
        self.showAlert.accept(AlertInfo(title: "Device Language", message: deviceLanguage, clipboardCopyable: true))
    }
    
    func deviceCountryCode() {
        let deviceCountryCode = TCGBUtil.deviceCountryCode()
        self.showAlert.accept(AlertInfo(title: "Device Country Code", message: deviceCountryCode, clipboardCopyable: true))
    }
    
    func displayLanguage() {
        let displayLanguageCode = TCGBGamebase.displayLanguageCode() ?? "Display Language가 설정되지 않았습니다."
        self.showAlert.accept(AlertInfo(title: "Display Language", message: displayLanguageCode, clipboardCopyable: true))
    }
}

// MARK: - TCGBLoggerDelegate
extension DeveloperViewModel: TCGBLoggerDelegate {
    func tcgbLogDidFail(_ log: TCGBLog, error: TCGBError) {
        let alertInfo = AlertInfo(title: "로그 전송 실패",
                                  message: "로그 전송에 실패했습니다.\n\n\(error.localizedDescription)")
        self.showAlert.accept(alertInfo)
    }
    func tcgbLogDidSuccess(_ log: TCGBLog) {
        let alertInfo = AlertInfo(title: "로그 전송 성공",
                                  message: "로그를 전송했습니다.\n\n\(log.message())")
        self.showAlert.accept(alertInfo)
    }
    func tcgbLogDidFilter(_ log: TCGBLog, logFilter: TCGBLogFilter) {
        let alertInfo = AlertInfo(title: "로그 전송 실패",
                                  message: "로그가 필터링되어 전송되지 않았습니다.")
        self.showAlert.accept(alertInfo)
    }
    
    func tcgbLogDidSave(_ log: TCGBLog) {
        let alertInfo = AlertInfo(title: "로그 전송 실패",
                                  message: "네트워크 연결 해제로 인해 로그 전송에 실패할 경우 로그 재전송을 위한 파일로 저장됩니다.\n(저장된 파일은 확인할 수 없습니다.)")
        self.showAlert.accept(alertInfo)
    }
}
