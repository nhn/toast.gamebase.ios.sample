//
//  ImageNoticeConfigurationViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/04.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class ImageNoticeConfigurationViewModel {
    private weak var viewController: UIViewController?
        
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
    
    private let imageNoticeConfiguration = TCGBImageNoticeConfiguration()
    var useSchemeEvent = false
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - ViewModelType
extension ImageNoticeConfigurationViewModel: ViewModelType {
    struct Input {
        let showImageNotice: PublishRelay<Void>
    }
    
    struct Output {
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.showImageNotice
            .subscribe { [weak self] _ in
                self?.showImageNotice()
            }
            .disposed(by: disposeBag)
        
        return Output(showAlert: showAlert.asSignal())
    }
}

extension ImageNoticeConfigurationViewModel {
    func setBackgroundColor() {
        let textFields = [
            AlertTextFieldInfo(placeholder: "RED(0 ~ 1.0)"),
            AlertTextFieldInfo(placeholder: "GREEN(0 ~ 1.0)"),
            AlertTextFieldInfo(placeholder: "BLUE(0 ~ 1.0)"),
            AlertTextFieldInfo(placeholder: "ALPHA(0 ~ 1.0)")
        ]
        
        let alertInfo = AlertInfo(title: "뒷 배경색",
                                  textFields: textFields,
                                  confirmHandler: { [weak self] alert in
            guard let red = alert.textFields?[0].text, !red.isEmpty else { return }
            guard let green = alert.textFields?[1].text, !green.isEmpty else { return }
            guard let blue = alert.textFields?[2].text, !blue.isEmpty else { return }
            guard let alpha = alert.textFields?[3].text, !alpha.isEmpty else { return }
            
            self?.imageNoticeConfiguration.backgroundColor = UIColor(red: CGFloat((red as NSString).floatValue),
                                                                     green: CGFloat((green as NSString).floatValue),
                                                                     blue: CGFloat((blue as NSString).floatValue),
                                                                     alpha: CGFloat((alpha as NSString).floatValue))
        })
        self.showAlert.accept(alertInfo)
    }
    
    func setTimeoutMS() {
        let textFields = [
            AlertTextFieldInfo(placeholder: "millisecond")
        ]
        
        let alertInfo = AlertInfo(title: "최대 로딩 시간",
                                  textFields: textFields,
                                  confirmHandler: { [weak self] alert in
            guard let millisecond = alert.textFields?[0].text, !millisecond.isEmpty else { return }
            self?.imageNoticeConfiguration.timeoutMS = Int(millisecond) ?? 5000
        })
        self.showAlert.accept(alertInfo)
    }
    
    func setEnableAutoCloseByCustomScheme(_ enabled: Bool) {
        imageNoticeConfiguration.enableAutoCloseByCustomScheme = enabled
    }
}

// MARK: - Business logic
extension ImageNoticeConfigurationViewModel {
    private func showImageNotice() {
        let closeCompletion: (TCGBError?) -> () = { [weak self] error in
            self?.showAlert.accept(AlertInfo(title: "이미지 공지 종료", message: "error => \(error?.localizedDescription ?? "nil")"))
        }
        
        let schemeEvent: ((String?, TCGBError?) -> ()) = { [weak self] payload, error in
            guard let self = self else { return }
            
            if !self.useSchemeEvent {
                return
            }
            
            self.showAlert.accept(AlertInfo(title: "이미지 공지 클릭 이벤트", message: "payload => \(payload ?? "nil")"))
        }
        
        TCGBImageNotice.showImageNotices(viewController: self.viewController,
                                         configuration: self.imageNoticeConfiguration,
                                         closeCompletion: closeCompletion,
                                         schemeEvent:schemeEvent)
    }
}
