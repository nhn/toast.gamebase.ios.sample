//
//  AlertInfo.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/22.
//

import UIKit

struct AlertInfo {
    let title: String?
    let message: String?
    let preferredStyle: UIAlertController.Style
    let addCloseAction: Bool
    let actions: [UIAlertAction]
    let textFields: [AlertTextFieldInfo]?
    let clipboardCopyable: Bool
    let confirmHandler: ((UIAlertController) -> ())?

    init(title: String?,
         message: String? = nil,
         addCloseAction: Bool = true,
         preferredStyle: UIAlertController.Style = .alert,
         additionalActions: [UIAlertAction] = [],
         textFields: [AlertTextFieldInfo]? = nil,
         clipboardCopyable: Bool = false,
         confirmHandler: ((UIAlertController) -> ())? = nil) {
        self.title = title
        self.message = message
        self.preferredStyle = preferredStyle
        self.addCloseAction = addCloseAction
        self.actions = additionalActions
        self.textFields = textFields
        self.clipboardCopyable = clipboardCopyable
        self.confirmHandler = confirmHandler
    }
}

struct AlertTextFieldInfo {
    let defaultText: String?
    let placeholder: String?
    
    init(defaultText: String? = nil, placeholder: String? = nil) {
        self.defaultText = defaultText
        self.placeholder = placeholder
    }
}
