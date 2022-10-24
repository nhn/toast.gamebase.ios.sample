//
//  ReceiptListViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/28.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

class ReceiptListViewModel {
    var receiptItemList = BehaviorRelay(value: [String]())
    private let isLoading = PublishRelay<Bool>()
    private let showAlert = PublishRelay<AlertInfo>()
    private let showEmptyView = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
}

// MARK: - ViewModelType
extension ReceiptListViewModel: ViewModelType {
    struct Input {
        let getReceiptItemList: PublishRelay<ReceiptListViewType>
    }
    
    struct Output {
        let isLoading: Signal<Bool>
        let showEmptyView: Signal<Void>
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.getReceiptItemList
            .subscribe(onNext: { [weak self] type in
                self?.isLoading.accept(true)
                self?.requestReceiptList(type: type)
            })
            .disposed(by: disposeBag)
        
        return Output(isLoading: isLoading.asSignal(),
                      showEmptyView: showEmptyView.asSignal(),
                      showAlert: showAlert.asSignal())
    }
}

// MARK: - Business logic
extension ReceiptListViewModel {
    private func requestReceiptList(type: ReceiptListViewType) {
        switch type {
        case .activatedPurchases:
            self.requestActivatedPurchases()
        case .itemListOfNotConsumed:
            self.requestItemListOfNotConsumed()
        }
    }
    
    private func requestActivatedPurchases() {
        GamebaseAsObservable.requestActivatedPurchases()
            .subscribe { [weak self] purchasableReceiptList in
                self?.setResult(recepitList: purchasableReceiptList)
                self?.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.showEmptyView.accept(())
                self?.isLoading.accept(false)
                self?.showAlert.accept(AlertInfo(title: "구독 목록 요청 실패", message: "구독 목록을 불러오지 못했습니다. 다시 시도해주세요."))
            }
            .disposed(by: disposeBag)
    }
    
    private func requestItemListOfNotConsumed() {
        GamebaseAsObservable.requestItemListOfNotConsumed()
            .subscribe { [weak self] purchasableReceiptList in
                self?.setResult(recepitList: purchasableReceiptList)
                self?.isLoading.accept(false)
            } onError: { [weak self] error in
                self?.showEmptyView.accept(())
                self?.isLoading.accept(false)
                self?.showAlert.accept(AlertInfo(title: "미소비 목록 요청 실패", message: "미소비 목록을 불러오지 못했습니다. 다시 시도해주세요."))
            }
            .disposed(by: disposeBag)
    }
    
    private func setResult(recepitList: [TCGBPurchasableReceipt]) {
        if recepitList.isEmpty {
            self.showEmptyView.accept(())
        }
        
        let itemList = recepitList.map { $0.JSONPrettyString() }
        self.receiptItemList.accept(itemList)
    }
}
