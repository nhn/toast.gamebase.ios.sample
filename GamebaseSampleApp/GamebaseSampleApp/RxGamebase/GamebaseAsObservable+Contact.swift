//
//  GamebaseAsObservable+Contact.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/07.
//

import Foundation
import RxSwift
import Gamebase

extension GamebaseAsObservable {
    static func openContact(configuration: TCGBContactConfiguration? = nil,
                            viewController: UIViewController? = nil) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBContact.openContact(viewController: viewController, configuration: configuration) { error in
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
    
    static func requestContactURL(configuration: TCGBContactConfiguration? = nil) -> Observable<String> {
        return Observable.create { observer -> Disposable in
            TCGBContact.requestContactURL(configuration: configuration) { contactURL, error in
                guard TCGBGamebase.isSuccess(error: error), let contactUrl = contactURL else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(contactUrl)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}
