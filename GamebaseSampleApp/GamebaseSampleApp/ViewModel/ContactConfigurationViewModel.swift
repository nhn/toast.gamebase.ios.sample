//
//  ContactConfigurationViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/07.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class ContactConfigurationViewModel {
    private weak var viewController: UIViewController?
    let contactConfigurationItemList = BehaviorRelay(value: [ContactConfigurationCellItem]())
    
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
    
    private let contactConfiguration = TCGBContactConfiguration()
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - ViewModelType
extension ContactConfigurationViewModel: ViewModelType {
    struct Input {
        let prepareData: PublishRelay<Void>
        let openContact: PublishRelay<Void>
    }

    struct Output {
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.prepareData
            .subscribe { [weak self] _ in
                self?.setupContents()
            }
            .disposed(by: disposeBag)
        
        input.openContact
            .subscribe { [weak self] _ in
                self?.openContact()
            }
            .disposed(by: disposeBag)

        return Output(showAlert: showAlert.asSignal())
    }
}

extension ContactConfigurationViewModel {
    func setUserName(_ name: String) {
        self.contactConfiguration.userName = name
        self.setupContents()
    }
    
    func setAdditionalURL(_ url: String) {
        self.contactConfiguration.additionalURL = url
        self.setupContents()
    }
    
    func setAdditionalParameters(_ parameters: [String: String]) {
        self.contactConfiguration.additionalParameters = parameters
        self.setupContents()
    }
    
    func setExtraData(_ data: [String: String]) {
        self.contactConfiguration.extraData = data
        self.setupContents()
    }
}

// MARK: - Business logic
extension ContactConfigurationViewModel {
    private func setupContents() {
        let itemList = [
            ContactConfigurationCellItem(title: "사용자 이름 입력", strValue: self.contactConfiguration.userName, handler: {
                let textFields = [
                    AlertTextFieldInfo(placeholder: "사용자 이름")
                ]
                
                let alertInfo = AlertInfo(title: "사용자 이름 입력",
                                          textFields: textFields,
                                          confirmHandler: { [weak self] alert in
                    guard let name = alert.textFields?[0].text, !name.isEmpty else { return }
                    self?.setUserName(name)
                })
                self.showAlert.accept(alertInfo)
            }),
            ContactConfigurationCellItem(title: "Additional URL 입력", strValue: self.contactConfiguration.additionalURL, handler: {
                let textFields = [
                    AlertTextFieldInfo(placeholder: "Additional URL")
                ]
                
                let alertInfo = AlertInfo(title: "Additional URL 입력",
                                          textFields: textFields,
                                          confirmHandler: { [weak self] alert in
                    guard let url = alert.textFields?[0].text, !url.isEmpty else { return }
                    self?.setAdditionalURL(url)
                })
                self.showAlert.accept(alertInfo)
            }),
            ContactConfigurationCellItem(title: "Additional Parameter 입력", dicValue: self.contactConfiguration.additionalParameters, handler: {
                let textFields = [
                    AlertTextFieldInfo(placeholder: "Parameter key"),
                    AlertTextFieldInfo(placeholder: "Parameter value")
                ]
                
                let alertInfo = AlertInfo(title: "Additional Parameter 입력",
                                          textFields: textFields,
                                          confirmHandler: { [weak self] alert in
                    guard let key = alert.textFields?[0].text, !key.isEmpty, let value = alert.textFields?[0].text else { return }
                    self?.setAdditionalParameters([key: value])
                })
                self.showAlert.accept(alertInfo)
            }),
            ContactConfigurationCellItem(title: "Extra data 입력", dicValue: self.contactConfiguration.extraData, handler: {
                let textFields = [
                    AlertTextFieldInfo(placeholder: "Extra data key"),
                    AlertTextFieldInfo(placeholder: "Extra data value")
                ]
                
                let alertInfo = AlertInfo(title: "Extra data 입력",
                                          textFields: textFields,
                                          confirmHandler: { [weak self] alert in
                    guard let key = alert.textFields?[0].text, !key.isEmpty, let value = alert.textFields?[1].text else { return }
                    self?.setExtraData([key: value])
                })
                self.showAlert.accept(alertInfo)
            })
        ]
        
        self.contactConfigurationItemList.accept(itemList)
    }
    
    private func openContact() {
        GamebaseAsObservable.openContact(configuration: self.contactConfiguration, viewController: self.viewController)
            .subscribe { [weak self] _ in
                self?.showAlert.accept(AlertInfo(title: "고객센터", message: "고객센터를 닫았습니다."))
            } onError: { [weak self] error in
                self?.showAlert.accept(AlertInfo(title: "고객센터", message: "고객센터를 여는 중 오류가 발생했습니다.\n\n\(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
}
