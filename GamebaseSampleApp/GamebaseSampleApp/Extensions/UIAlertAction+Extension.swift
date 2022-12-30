//
//  UIAlertAction+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/21.
//

import UIKit

extension UIAlertAction {
    static func closeAction() -> UIAlertAction {
        return UIAlertAction(title: "닫기", style: .cancel)
    }
}
