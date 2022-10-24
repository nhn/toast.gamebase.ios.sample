//
//  UpdateTermsViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/06.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class UpdateTermsViewModel {
    let termsContentItemList = BehaviorRelay(value: [CustomTitleSwitchModel]())
        
    private let isLoading = PublishRelay<Bool>()
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
    
    private var queryTermsResult: TCGBQueryTermsResult? = nil
    private var termsContentDetails: [TCGBTermsContentDetail] = []
}

// MARK: - ViewModelType
extension UpdateTermsViewModel: ViewModelType {
    struct Input {
        let prepareData: PublishRelay<Void>
        let updateTerms: PublishRelay<Void>
    }

    struct Output {
        let isLoading: Signal<Bool>
        let showAlert: Signal<AlertInfo>
    }

    func transform(input: Input) -> Output {
        input.prepareData
            .subscribe { [weak self] _ in
                self?.isLoading.accept(true)
                self?.setTermsItemList()
            }
            .disposed(by: disposeBag)
        
        input.updateTerms
            .subscribe { [weak self] _ in
                self?.isLoading.accept(true)
                self?.updateTerms()
            }
            .disposed(by: disposeBag)

        return Output(isLoading: isLoading.asSignal(),
                      showAlert: showAlert.asSignal())
    }
}

// MARK: - Business logic
extension UpdateTermsViewModel {
    private func setTermsItemList() {
        GamebaseAsObservable.queryTerms()
            .subscribe { [weak self] queryTermsResult in
                guard let self = self else { return }
                
                self.queryTermsResult = queryTermsResult
                self.termsContentDetails = queryTermsResult.contents
                
                let itemList = self.termsContentDetails
                    .map { contentDetail -> CustomTitleSwitchModel in
                        CustomTitleSwitchModel(title: contentDetail.name, isOn: contentDetail.agreed) { value in
                            contentDetail.agreed = value
                        }
                    }
                
                self.termsContentItemList.accept(itemList)
                self.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.isLoading.accept(false)
                self?.showAlert.accept(AlertInfo(title: "약관 정보 조회 실패", message: "\(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
    
    private func updateTerms() {
        guard let queryTermsResult = self.queryTermsResult else {
            self.showAlert.accept(AlertInfo(title: "저장할 데이터가 없습니다."))
            return
        }
        
        let contents = self.termsContentDetails
            .map { contentDetail -> TCGBTermsContent in
                let content = TCGBTermsContent()
                content.termsContentSeq = contentDetail.termsContentSeq
                content.agreed = contentDetail.agreed
                return content
            }
        
        let configuration = TCGBUpdateTermsConfiguration.updateTermsConfiguration(termsVersion: queryTermsResult.termsVersion,
                                                                                  termsSeq: queryTermsResult.termsSeq,
                                                                                  contents: contents)
        
        GamebaseAsObservable.updateTerms(configuration: configuration)
            .do(onNext: { [weak self] in
                self?.isLoading.accept(false)
            })
            .subscribe { [weak self] _ in
                self?.showAlert.accept(AlertInfo(title: "약관 동의 내역 저장 성공"))
            } onError: { [weak self] error in
                self?.showAlert.accept(AlertInfo(title: "약관 동의 내역 저장 실패", message: "\(error.localizedDescription)"))
            }
            .disposed(by: self.disposeBag)
    }
}
