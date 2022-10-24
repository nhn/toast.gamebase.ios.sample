//
//  GamebaseAsObservable+Purchase.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/28.
//

import Foundation
import Gamebase
import RxSwift

extension GamebaseAsObservable {
    static func requestItemListOfNotConsumed() -> Observable<[TCGBPurchasableReceipt]> {
        return Observable.create { observer -> Disposable in
            TCGBPurchase.requestItemListOfNotConsumed { purchasableReceiptList, error in
                guard TCGBGamebase.isSuccess(error: error), let purchasableReceiptList = purchasableReceiptList else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(purchasableReceiptList)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }

    static func requestItemListPurchasable() -> Observable<[TCGBPurchasableItem]> {
        return Observable.create { observer -> Disposable in
            TCGBPurchase.requestItemListPurchasable { purchasableItemList, error in
                guard TCGBGamebase.isSuccess(error: error), let purchasableItemList = purchasableItemList else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(purchasableItemList)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func requestPurchase(productId: String,
                                viewController: UIViewController) -> Observable<TCGBPurchasableReceipt> {
        return Observable.create { observer -> Disposable in
            TCGBPurchase.requestPurchase(gamebaseProductId: productId, viewController: viewController) { purchasableReceipt, error in
                guard TCGBGamebase.isSuccess(error: error), let purchasableReceipt = purchasableReceipt else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(purchasableReceipt)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func requestRestorePurchase() -> Observable<[TCGBPurchasableReceipt]> {
        return Observable.create { observer -> Disposable in
            TCGBPurchase.requestRestore { purchasableReceiptList, error in
                guard TCGBGamebase.isSuccess(error: error), let purchasableReceiptList = purchasableReceiptList else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(purchasableReceiptList)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func requestActivatedPurchases() -> Observable<[TCGBPurchasableReceipt]> {
        return Observable.create { observer -> Disposable in
            TCGBPurchase.requestActivatedPurchases { purchasableReceiptList, error in
                guard TCGBGamebase.isSuccess(error: error), let purchasableReceiptList = purchasableReceiptList else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(purchasableReceiptList)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
