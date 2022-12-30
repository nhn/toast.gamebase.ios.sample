//
//  UIViewController+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/06.
//

import UIKit

extension UIViewController {
    static func showAlert(above viewController: UIViewController = UIApplication.topViewController()!,
                          title: String?,
                          message: String?,
                          preferredStyle: UIAlertController.Style = .alert,
                          actions: [UIAlertAction] = [UIAlertAction.closeAction()],
                          textFields: [((UITextField) -> Void)?]? = [],
                          confirmHandler: ((UIAlertController) -> ())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        
        textFields?.forEach { alert.addTextField(configurationHandler: $0) }
        
        actions.forEach { alert.addAction($0) }
        
        if let confirmHandler = confirmHandler {
            alert.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                confirmHandler(alert)
            }))
        }
        
        DispatchQueue.main.async {
            viewController.present(alert, animated: true)
        }
    }
    
    static func showAlert(above viewController: UIViewController = UIApplication.topViewController()!,
                          alertInfo: AlertInfo) {
        let actions = alertInfo.addCloseAction ? alertInfo.actions + UIAlertAction.closeAction() : alertInfo.actions
        
        let textFields = alertInfo.textFields?
            .compactMap { info -> ((UITextField) -> ()) in
                return {
                    $0.text = info.defaultText
                    $0.placeholder = info.placeholder
                    $0.clearButtonMode = .always
                }
            }
        
        UIViewController.showAlert(above: viewController,
                                   title: alertInfo.title,
                                   message: alertInfo.message,
                                   preferredStyle: alertInfo.preferredStyle,
                                   actions: actions,
                                   textFields: textFields,
                                   confirmHandler: alertInfo.confirmHandler)
    }
}

fileprivate func + <T>(lhs: [T], rhs: T) -> [T] {
    var copy = lhs
    copy.append(rhs)
    return copy
}

fileprivate func += <T>(lhs: inout [T], rhs: T) {
    lhs = lhs + rhs
}
