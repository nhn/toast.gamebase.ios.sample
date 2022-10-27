//
//  StoreViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/24.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class ShoppingViewModel {
    private weak var viewController: UIViewController?

    let purchasableItemList = BehaviorRelay(value: [ShoppingCellModel]())

    private let purchaseSuccess = PublishRelay<TCGBPurchasableReceipt?>()
    private let isLoading = PublishRelay<Bool>()
    private let showEmptyView = PublishRelay<Void>()
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - ViewModelType
extension ShoppingViewModel: ViewModelType {
    struct Input {
        let prepareShopping: PublishRelay<Void>
        let getPurchasableItemList: PublishRelay<Void>
        let tryToPurchase: PublishRelay<String>
    }
    
    struct Output {
        let isLoading: Signal<Bool>
        let showEmptyView: Signal<Void>
        let showAlert: Signal<AlertInfo>
    }
    
    func transform(input: Input) -> Output {
        input.prepareShopping
            .subscribe { [weak self] _ in
                self?.isLoading.accept(true)
                
                /*
                 [NOTICE]
                 Request a list of non-consumed items, which have not been normally consumed (delivered, or provided) after purchase.
                 https://docs.toast.com/en/Game/Gamebase/en/ios-purchase/#list-non-consumed-items
                 */
                self?.requestItemListOfNotConsumed()
            }
            .disposed(by: disposeBag)

        input.getPurchasableItemList
            .subscribe { [weak self] _ in
                self?.isLoading.accept(true)
                self?.requestItemListPurchasable()
            }
            .disposed(by: disposeBag)

        input.getPurchasableItemList
            .subscribe { [weak self] _ in
                self?.isLoading.accept(true)
                self?.requestItemListPurchasable()
            }
            .disposed(by: disposeBag)
        
        input.tryToPurchase
            .subscribe(onNext: { [weak self] productId in
                self?.isLoading.accept(true)
                self?.requestPurchase(productId,
                                      viewController: self?.viewController ?? UIApplication.topViewController()!)
            })
            .disposed(by: disposeBag)
        
        return Output(isLoading: isLoading.asSignal(),
                      showEmptyView: showEmptyView.asSignal(),
                      showAlert: showAlert.asSignal())
    }
}

// MARK: - Business logic
extension ShoppingViewModel {
    private func requestItemListOfNotConsumed() {
        GamebaseAsObservable.requestItemListOfNotConsumed()
            .subscribe { [weak self] _ in
                self?.requestItemListPurchasable()
                                
                /*
                 [NOTICE]
                 In case there is any non-purchased item, request the game server (item server) to proceed with item delivery (provision).
                 */
            } onError: { [weak self] _ in
                self?.requestItemListPurchasable()
            }
            .disposed(by: disposeBag)
    }
    
    private func requestItemListPurchasable() {
        GamebaseAsObservable.requestItemListPurchasable()
            .subscribe { [weak self] purchasableItemList in
                let itemList = purchasableItemList
                    .map {
                        ShoppingCellModel(title: $0.localizedTitle,
                                          description: $0.localizedDescription,
                                          price: $0.localizedPrice,
                                          productId: $0.gamebaseProductId)
                    }
                
                self?.purchasableItemList.accept(itemList)
                
                if purchasableItemList.isEmpty {
                    self?.showEmptyView.accept(())
                }
                self?.isLoading.accept(false)
            } onError: { [weak self] _ in
                guard let self = self else { return }
                self.isLoading.accept(false)
                self.showEmptyView.accept(())
                self.showAlert.accept(AlertInfo(title: "아이템 요청 실패", message: "아이템을 불러오지 못했습니다. 잠시 후 다시 시도해주세요."))
            }
            .disposed(by: disposeBag)
    }
    
    private func requestPurchase(_ productId: String, viewController: UIViewController) {
        GamebaseAsObservable.requestPurchase(productId: productId, viewController: viewController)
            .subscribe { [weak self] purchasableReceipt in
                self?.showAlert.accept(AlertInfo(title: "구매 성공", message: "아이템을 구매했습니다."))
            } onError: { [weak self] _ in
                guard let self = self else { return }
                self.showAlert.accept(AlertInfo(title: "구매 실패", message: "잠시 후 다시 시도해주세요."))
            } onDisposed: { [weak self] in
                self?.isLoading.accept(false)
            }
            .disposed(by: disposeBag)
    }
}
