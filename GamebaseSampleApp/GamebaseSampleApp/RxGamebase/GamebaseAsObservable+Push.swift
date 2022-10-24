//
//  GamebaseAsObservable+Push.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/25.
//

import Foundation
import RxSwift
import Gamebase

extension GamebaseAsObservable {
    static func registerPush(configuration: TCGBPushConfiguration,
                             notificationOptions: TCGBNotificationOptions? = nil) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
#if DEBUG
            TCGBPush.setSandboxMode(true)
#endif
            TCGBPush.registerPush(configuration: configuration, notificationOptions: notificationOptions) { error in
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
    
    static func queryTokenInfo() -> Observable<TCGBPushTokenInfo> {
        return Observable.create { observer -> Disposable in
#if DEBUG
            TCGBPush.setSandboxMode(true)
#endif
            TCGBPush.queryTokenInfo { pushTokenInfo, error in
                guard TCGBGamebase.isSuccess(error: error), let pushTokenInfo = pushTokenInfo else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(pushTokenInfo)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func queryNotificationAllowed() -> Observable<Bool> {
        return Observable.create { observer -> Disposable in
            TCGBPush.queryNotificationAllowed { allowed, error in
                guard TCGBGamebase.isSuccess(error: error) else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(allowed)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
