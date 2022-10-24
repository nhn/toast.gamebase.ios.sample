//
//  GamebaseAsObservable+ImageNotice.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/12.
//

import Foundation
import RxSwift
import Gamebase

extension GamebaseAsObservable {
    static func showImageNotices(viewController: UIViewController? = nil) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBImageNotice.showImageNotices(viewController: viewController) { error in
                guard TCGBGamebase.isSuccess(error: error) else {
                    observer.onError(error!)
                    return
                }
                
                observer.onNext(())
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
