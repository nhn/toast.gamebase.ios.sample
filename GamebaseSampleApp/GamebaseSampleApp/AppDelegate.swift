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
    
    /*
     For Weibo Login
     https://docs.toast.com/en/Game/Gamebase/en/ios-initialization/#openurl-event
     */
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return TCGBGamebase.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
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
            }
        }
    }
}
