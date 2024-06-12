//
//  UIAlertAction+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/21.
//

import UIKit
import Gamebase

extension UIAlertAction {
    static func closeAction() -> UIAlertAction {
        return UIAlertAction(title: "닫기", style: .cancel)
    }
    
    static func copyToClipboardAction(message: String) -> UIAlertAction {
        return UIAlertAction(title: "복사하기", style: .default) { _ in
            UIPasteboard.general.string = message
            TCGBUtil.showToast(message: "복사되었습니다.", length: .short)
        }
    }
}
