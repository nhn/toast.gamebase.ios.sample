//
//  AppDelegate.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/06/22.
//

import UIKit
import Gamebase

@main
@objc(AppDelegate)
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.registerEventHandler()
        return TCGBGamebase.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
        
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return TCGBGamebase.application(app, open: url, options: options)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        TCGBGamebase.applicationDidBecomeActive(application)
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        TCGBGamebase.applicationDidEnterBackground(application)
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        TCGBGamebase.applicationWillEnterForeground(application)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        TCGBGamebase.application(application, continue: userActivity, restorationHandler: restorationHandler)
    }
}

extension AppDelegate {
    private func registerEventHandler() {
        TCGBGamebase.addEventHandler {
            if $0.category == TCGBGamebaseEventCategory.purchaseUpdated.rawValue {
                /*
                 [NOTICE]
                 This event is triggered when a product is acquired by redeeming a promotion code. Can acquire payment receipt information.
                 */
            } else if $0.category == TCGBGamebaseEventCategory.pushReceivedMessage.rawValue {
                /*
                 [NOTICE]
                 This event occurs when a push message is received. By converting the extras field to JSON, you can also get custom information sent along with the push message.
                 */
            } else if $0.category == TCGBGamebaseEventCategory.pushClickMessage.rawValue {
                /*
                 [NOTICE]
                 This event is triggered when a received push message is clicked.
                 */
            } else if $0.category == TCGBGamebaseEventCategory.pushClickAction.rawValue {
                /*
                 [NOTICE]
                 This event is triggered when the button created by the Rich Message feature is clicked.
                 actionType provides the following: "OPEN_APP", "OPEN_URL", "REPLY", "DISMISS"
                 */
            } else if $0.category == TCGBGamebaseEventCategory.observerNetwork.rawValue {
                /*
                 [NOTICE]
                 This event is triggered when network status is changed.
                 */
                let networkObserverData = TCGBGamebaseEventObserverData.gamebaseEventObserverData(jsonString: $0.data)
                let errorCode = NetworkStatus(rawValue: Int(networkObserverData.code))
                
                switch errorCode {
                case .NotReachable, .ReachabilityIsNotDefined:
                    TCGBUtil.showToast(message: "인터넷 연결이 끊겼습니다.", length: .long)
                case .ReachableViaWWAN:
                    TCGBUtil.showToast(message: "모바일 네트워크가 연결되었습니다.", length: .long)
                case .ReachableViaWifi:
                    TCGBUtil.showToast(message: "WiFi가 연결되었습니다.", length: .long)
                default:
                    return
                }
            }
        }
    }
}
