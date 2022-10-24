//
//  GamebaseAsObservable+Auth.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/17.
//

import Foundation
import RxSwift
import Gamebase

extension GamebaseAsObservable {
    static func loginForLastLoggedInProvider(viewController: UIViewController) -> Observable<TCGBAuthToken> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.loginForLastLoggedInProvider(viewController: viewController) { authToken, error in
                guard TCGBGamebase.isSuccess(error: error), let authToken = authToken else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(authToken)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func login(_ idPType: String,
                      additionalInfo: Dictionary<String, Any>? = nil,
                      viewController: UIViewController) -> Observable<TCGBAuthToken> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.login(type: idPType, additionalInfo: additionalInfo, viewController: viewController) { authToken, error in
                guard TCGBGamebase.isSuccess(error: error), let authToken = authToken else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(authToken)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func logout(viewController: UIViewController? = nil) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.logout(viewController: viewController) { error in
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
    
    static func requestTemporaryWithdrawal(viewController: UIViewController? = nil) -> Observable<TCGBTemporaryWithdrawalInfo> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.requestTemporaryWithdrawal(viewController: viewController) { info, error in
                guard TCGBGamebase.isSuccess(error: error), let info = info else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(info)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func cancelTemporaryWithdrawal(viewController: UIViewController? = nil) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.cancelTemporaryWithdrawal(viewController: viewController) { error in
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
    
    static func withdraw(viewController: UIViewController? = nil) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.withdraw(viewController: viewController) { error in
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
    
    static func addMapping(_ idPType: String,
                           additionalInfo: Dictionary<String, Any>? = nil,
                           viewController: UIViewController) -> Observable<TCGBAuthToken> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.addMapping(type: idPType, additionalInfo: additionalInfo, viewController: viewController) { authToken, error in
                guard TCGBGamebase.isSuccess(error: error), let authToken = authToken else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(authToken)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func addMappingForcibly(ticket: TCGBForcingMappingTicket,
                                   viewController: UIViewController?) -> Observable<TCGBAuthToken> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.addMappingForcibly(ticket: ticket, viewController: viewController) { authToken, error in
                guard TCGBGamebase.isSuccess(error: error), let authToken = authToken else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(authToken)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
    
    static func removeMapping(_ idPType: String,
                              viewController: UIViewController?) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.removeMapping(type: idPType, viewController: viewController) { error in
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
    
    static func changeLogin(ticket: TCGBForcingMappingTicket,
                            viewController: UIViewController?) -> Observable<TCGBAuthToken> {
        return Observable.create { observer -> Disposable in
            TCGBGamebase.changeLogin(forcingMappingTicket: ticket, viewController: viewController) { authToken, error in
                guard TCGBGamebase.isSuccess(error: error), let authToken = authToken else {
                    observer.onError(error!)
                    return
                }
                observer.onNext(authToken)
                observer.onCompleted()
            }
            return Disposables.create()
        }
    }
}

//MARK: - Helper
extension GamebaseAsObservable {
    static let retryHandler: (Observable<Error>) -> Observable<Int> = { error in
        error.enumerated().flatMap { retryCount, error -> Observable<Int> in
            let errorCode = error.gamebaseErrorCode()
            
            if !errorCode.isNetworkError() {
                return .error(error)
            }
            
            if retryCount >= AppConstants.retryCount - 1 {
                return .error(error)
            }
            
            return Observable<Int>.timer(.seconds(1), scheduler: MainScheduler.asyncInstance)
        }
    }
}
