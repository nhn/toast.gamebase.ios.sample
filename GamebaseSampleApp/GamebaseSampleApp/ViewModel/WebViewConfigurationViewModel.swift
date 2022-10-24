//
//  WebViewConfigurationViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/02.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class WebViewConfigurationViewModel {
    private weak var viewController: UIViewController?
        
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
    
    private let webViewConfiguration = TCGBWebViewConfiguration()
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - ViewModelType
extension WebViewConfigurationViewModel: ViewModelType {
    struct Input {
        let showWebView: PublishRelay<Void>
    }
    
    struct Output {
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.showWebView
            .subscribe { [weak self] _ in
                self?.showWebView()
            }
            .disposed(by: disposeBag)
        return Output(showAlert: showAlert.asSignal())
    }
}

extension WebViewConfigurationViewModel {
    func setContentMode(_ mode: String) {
        guard let contentMode = WebViewContentModeItem(rawValue: mode) else {
            return
        }
    
        switch contentMode {
        case .TCGBWebViewContentModeRecommended:
            self.webViewConfiguration.contentMode = TCGBWebViewContent.modeRecommended.rawValue
        case .TCGBWebViewContentModeMobile:
            self.webViewConfiguration.contentMode = TCGBWebViewContent.modeMobile.rawValue
        case .TCGBWebViewContentModeDesktop:
            self.webViewConfiguration.contentMode = TCGBWebViewContent.modeDesktop.rawValue
        }
    }
    
    func setBackButtonVisible(_ isVisible: Bool) {
        self.webViewConfiguration.isBackButtonVisible = isVisible
    }
    
    func setNavigationBarVisible(_ isVisible: Bool) {
        self.webViewConfiguration.isNavigationBarVisible = isVisible
    }
    
    func setNavigationBarTitle() {
        let textFields = [
            AlertTextFieldInfo(placeholder: "내비게이션바 제목")
        ]
        let alertInfo = AlertInfo(title: "내비게이션바 제목 설정",
                                  textFields: textFields,
                                  confirmHandler: { [weak self] alert in
            guard let title = alert.textFields?[0].text, !title.isEmpty else { return }
            self?.webViewConfiguration.navigationBarTitle = title
        })
        self.showAlert.accept(alertInfo)
    }
    
    func setNavigationBarColor() {
        let textFields = [
            AlertTextFieldInfo(placeholder: "RED(0 ~ 1.0)"),
            AlertTextFieldInfo(placeholder: "GREEN(0 ~ 1.0)"),
            AlertTextFieldInfo(placeholder: "BLUE(0 ~ 1.0)"),
            AlertTextFieldInfo(placeholder: "ALPHA(0 ~ 1.0)")
        ]
        
        let alertInfo = AlertInfo(title: "내비게이션바 배경색 설정",
                                  textFields: textFields,
                                  confirmHandler: { [weak self] alert in
            
            guard let red = alert.textFields?[0].text, !red.isEmpty else { return }
            guard let green = alert.textFields?[1].text, !green.isEmpty else { return }
            guard let blue = alert.textFields?[2].text, !blue.isEmpty else { return }
            guard let alpha = alert.textFields?[3].text, !alpha.isEmpty else { return }
            
            self?.webViewConfiguration.navigationBarColor = UIColor(red: CGFloat((red as NSString).floatValue),
                                                                    green: CGFloat((green as NSString).floatValue),
                                                                    blue: CGFloat((blue as NSString).floatValue),
                                                                    alpha: CGFloat((alpha as NSString).floatValue))
        })
        self.showAlert.accept(alertInfo)
    }
}

// MARK: - Business logic
extension WebViewConfigurationViewModel {
    private func showWebView() {
        let textFields = [
            AlertTextFieldInfo(defaultText: "https://gameplatform.nhncloud.com/", placeholder: "URL 입력")
        ]
        
        let alertInfo = AlertInfo(title: "웹뷰 열기",
                                  textFields: textFields,
                                  confirmHandler: { [weak self] alert in
            guard let urlString = alert.textFields?[0].text, !urlString.isEmpty else { return }
            
            let closeCompletion: TCGBWebViewCloseCompletion = { [weak self] error in
                self?.showAlert.accept(AlertInfo(title: "웹뷰 종료", message: "error => \(error?.localizedDescription ?? "nil")"))
            }
            
            TCGBWebView.showWebView(urlString: urlString,
                                    viewController: self?.viewController,
                                    configuration: self?.webViewConfiguration,
                                    closeCompletion: closeCompletion,
                                    schemeList: nil,
                                    schemeEvent: nil)
        })
        self.showAlert.accept(alertInfo)
    }
}
