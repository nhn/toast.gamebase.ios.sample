//
//  UIStackView+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/29.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach {
            self.addArrangedSubview($0)
        }
    }
}

