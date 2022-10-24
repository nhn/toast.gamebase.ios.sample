//
//  GamebaseSubject.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/12.
//

import Foundation
import RxSwift
import Gamebase

final class GamebaseAsObservable {
    static func initialize(configuration: TCGBConfiguration) -> Observable<[String: Any]> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.initialize(configuration: configuration) { launchingData, error in
                guard TCGBGamebase.isSuccess(error: error), let launchingData = launchingData else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(launchingData)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
