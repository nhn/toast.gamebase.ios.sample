//
//  CustomTitleSwitchModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/26.
//

import Foundation

struct CustomTitleSwitchModel {
    let title: String
    var isOn: Bool
    let handler: ((Bool) -> ())?
    
    init(title: String, isOn: Bool, handler: ((Bool) -> ())? = nil) {
        self.title = title
        self.isOn = isOn
        self.handler = handler
    }
}
