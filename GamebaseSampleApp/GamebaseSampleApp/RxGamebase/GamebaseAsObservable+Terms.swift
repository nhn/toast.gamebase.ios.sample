//
//  GamebaseAsObservable+Terms.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/16.
//

import Foundation
import RxSwift
import Gamebase

extension GamebaseAsObservable {
    static func showTermsView(configuration: TCGBTermsConfiguration,
                              viewController: UIViewController? = nil) -> Observable<TCGBDataContainer> {
        return Observable.create { observer -> Disposable in
            TCGBTerms.showTermsView(configuration: configuration, viewController: viewController) { dataContainer, error in
                guard TCGBGamebase.isSuccess(error: error), let dataContainer = dataContainer else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(dataContainer)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func showTermsView(viewController: UIViewController? = nil) -> Observable<TCGBDataContainer> {
        return Observable.create { observer -> Disposable in
            TCGBTerms.showTermsView(viewController: viewController) { dataContainer, error in
                guard TCGBGamebase.isSuccess(error: error), let dataContainer = dataContainer else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(dataContainer)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func queryTerms(viewController: UIViewController? = nil) -> Observable<TCGBQueryTermsResult> {
        return Observable.create { observer -> Disposable in
            TCGBTerms.queryTerms(viewController: viewController) { queryTermsResult, error in
                guard TCGBGamebase.isSuccess(error: error), let queryTermsResult = queryTermsResult else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(queryTermsResult)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func updateTerms(viewController: UIViewController? = nil,
                            configuration: TCGBUpdateTermsConfiguration) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBTerms.updateTerms(viewController: viewController, configuration: configuration) { error in
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
