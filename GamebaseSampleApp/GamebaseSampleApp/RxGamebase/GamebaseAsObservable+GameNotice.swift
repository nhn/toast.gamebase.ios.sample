//
//  GamebaseAsObservable+GameNotice.swift
//  GamebaseSampleApp
//
//  Created by NHN on 4/14/25.
//

import Foundation
import RxSwift
import Gamebase

extension GamebaseAsObservable {
    static func openGameNotice(viewController: UIViewController? = nil) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBGameNotice.openGameNotice(viewController: viewController) { error in
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
