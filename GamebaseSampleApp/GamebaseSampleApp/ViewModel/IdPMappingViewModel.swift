//
//  IdPMappingViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/22.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Gamebase

final class IdPMappingViewModel {
    weak var viewController: UIViewController?
    lazy var mappingItemList = BehaviorRelay(value: self.idPMappingInfos)
    
    private let showAlert = PublishRelay<AlertInfo>()
    private let routeToRootView = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    var idPMappingInfos: [IdPMappingInfo] {
        AppConstants.idPList
            .filter { $0 != Gamebase.kTCGBAuthGuest }
            .filter { $0 != TCGBGamebase.currentProvider() }
            .map { idPType in
                IdPMappingInfo(idPType: idPType,
                               alreadyMapped: TCGBGamebase.authMappingList()?.contains(idPType) ?? false) { [weak self] isAlreadyMappged in
                    self?.mappingAction(idPType: idPType, isAlreadyMapped: isAlreadyMappged)
                }
            }
    }

    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - ViewModelType
extension IdPMappingViewModel: ViewModelType {
    struct Input {
        // Empty
    }
    
    struct Output {
        let showAlert: Signal<AlertInfo>
        let routeToRootView: Signal<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output(showAlert: showAlert.asSignal(),
                      routeToRootView: routeToRootView.asSignal())
    }
}

// MARK: - Business logic
extension IdPMappingViewModel {
    private func mappingAction(idPType: String, isAlreadyMapped: Bool) {
        if isAlreadyMapped {
            let action = UIAlertAction(title: "연동 해제", style: .default) { [weak self] _ in
                self?.removeMapping(idPType: idPType)
            }
            
            let alertInfo = AlertInfo(title: nil,
                                      message: "연동 해제하시겠습니까?",
                                      additionalActions: [action])
            
            self.showAlert.accept(alertInfo)
        } else {
            self.addMapping(idPType: idPType)
        }
    }
    
    private func addMapping(idPType: String) {
        GamebaseAsObservable.addMapping(idPType, viewController: viewController ?? UIApplication.topViewController()!)
            .observe(on: MainScheduler.asyncInstance)
            .retry(when: GamebaseAsObservable.retryHandler)
            .subscribe(with: self) { owner, _ in
                owner.mappingItemList.accept(owner.idPMappingInfos)
            } onError: { owner, error in
                let alertInfo: AlertInfo
                
                switch error.gamebaseErrorCode() {
                case .ERROR_AUTH_USER_CANCELED:
                    alertInfo = AlertInfo(title: "연동 취소", message: "로그인이 취소되었습니다.")
                case .ERROR_AUTH_ADD_MAPPING_ALREADY_MAPPED_TO_OTHER_MEMBER:
                    let tcgbError = error as! TCGBError
                    let ticket = TCGBForcingMappingTicket.forcingMappingTicket(fromError: tcgbError)!
                    
                    let actions = [
                        UIAlertAction(title: "계정 변경", style: .default) { [weak self] _ in
                            self?.changeLogin(ticket: ticket)
                        },
                        UIAlertAction(title: "강제 연동", style: .destructive) { [weak self] _ in
                            self?.addMappingForcibly(ticket: ticket)
                        },
                    ]
                    
                    alertInfo = AlertInfo(title: "연동 실패",
                                          message: """
                                          선택한 IdP에 매핑된 계정이 이미 존재합니다.
                                          
                                          '계정 변경'을 선택하면 현재 로그인 되어 있는 계정 정보를 선택한 IdP에 매핑된 계정으로 변경합니다.
                                          
                                          '강제 연동'을 선택하면 선택한 IdP를 현재 계정에 강제로 연동시킵니다.
                                          단, 선택한 IdP로 이전에 생성된 계정 정보는 사라지니 주의해 주세요.
                                          """,
                                          additionalActions: actions)
                default:
                    alertInfo = AlertInfo(title: "연동 실패", message: "알 수 없는 이유로 연동에 실패했습니다.\n잠시 후 다시 시도해주세요.")
                }
                
                owner.showAlert.accept(alertInfo)
            }
            .disposed(by: disposeBag)
    }
    
    private func addMappingForcibly(ticket: TCGBForcingMappingTicket) {
        GamebaseAsObservable.addMappingForcibly(ticket: ticket, viewController: viewController)
            .subscribe(with: self) { owner, _ in
                owner.mappingItemList.accept(owner.idPMappingInfos)
            } onError: { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "연동 실패",
                                                 message: "알 수 없는 이유로 연동에 실패했습니다.\n잠시 후 다시 시도해주세요."))
            }
            .disposed(by: disposeBag)
    }
    
    private func removeMapping(idPType: String) {
        GamebaseAsObservable.removeMapping(idPType, viewController: viewController ?? UIApplication.topViewController()!)
            .subscribe(with: self) { owner, _ in
                owner.mappingItemList.accept(owner.idPMappingInfos)
            } onError: { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "연동 해제 실패",
                                                 message: "다시 시도해주세요."))
            }
            .disposed(by: disposeBag)
    }
    
    private func changeLogin(ticket: TCGBForcingMappingTicket) {
        GamebaseAsObservable.changeLogin(ticket: ticket, viewController: viewController)
            .subscribe(with: self) { owner, _ in
                let alertInfo = AlertInfo(title: "계정 변경 성공",
                                          message: "앱을 재시작 합니다.",
                                          addCloseAction: false,
                                          confirmHandler: { [weak self] _ in
                    self?.routeToRootView.accept(())
                })
                
                owner.showAlert.accept(alertInfo)
            } onError: { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "계정 변경 실패",
                                                 message: "다시 시도해주세요."))
            }
            .disposed(by: disposeBag)

    }
}
