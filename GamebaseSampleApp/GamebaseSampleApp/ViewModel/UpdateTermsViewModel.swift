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
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.setTermsItemList()
            }
            .disposed(by: disposeBag)
        
        input.updateTerms
            .subscribe(with: self) { owner, _ in
                owner.isLoading.accept(true)
                owner.updateTerms()
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
            .subscribe(with: self) { owner, queryTermsResult in
                owner.queryTermsResult = queryTermsResult
                owner.termsContentDetails = queryTermsResult.contents
                
                let itemList = owner.termsContentDetails
                    .map { contentDetail -> CustomTitleSwitchModel in
                        CustomTitleSwitchModel(title: contentDetail.name, isOn: contentDetail.agreed) { value in
                            contentDetail.agreed = value
                        }
                    }
                
                owner.termsContentItemList.accept(itemList)
                owner.isLoading.accept(false)
            } onError: { owner, error in
                owner.isLoading.accept(false)
                owner.showAlert.accept(AlertInfo(title: "약관 정보 조회 실패",
                                                 message: "\(error.localizedDescription)"))
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
                let content = TCGBTermsContent(
                    termsContentSeq: Int(contentDetail.termsContentSeq),
                    agreed: contentDetail.agreed
                )
                return content
            }
        
        let configuration = TCGBUpdateTermsConfiguration.updateTermsConfiguration(termsVersion: queryTermsResult.termsVersion,
                                                                                  termsSeq: queryTermsResult.termsSeq,
                                                                                  contents: contents)
        
        GamebaseAsObservable.updateTerms(configuration: configuration)
            .do(onNext: { [weak self] in
                self?.isLoading.accept(false)
            })
            .subscribe(with: self) { owner, _ in
                owner.showAlert.accept(AlertInfo(title: "약관 동의 내역 저장 성공"))
            } onError: { owner, error in
                owner.showAlert.accept(AlertInfo(title: "약관 동의 내역 저장 실패",
                                                 message: "\(error.localizedDescription)"))
            }
            .disposed(by: self.disposeBag)
    }
}
