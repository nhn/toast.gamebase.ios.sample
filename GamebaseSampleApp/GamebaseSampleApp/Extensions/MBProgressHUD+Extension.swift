//
//  MBProgressHUD+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/11.
//

import Foundation
import MBProgressHUD

extension MBProgressHUD {
    static func showProgress(_ isLoading: Bool, to view: UIView, animated: Bool) {
        if isLoading {
            self.showAdded(to: view, animated: animated)
        } else {
            self.hide(for: view, animated: animated)
        }
    }
}
