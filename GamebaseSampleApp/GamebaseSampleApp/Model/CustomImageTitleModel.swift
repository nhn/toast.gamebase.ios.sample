//
//  CustomImageTitleModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/27.
//

import Foundation

struct CustomImageTitleModel {
    let icon: String
    let title: String
    let etc: String?
    
    init(icon: String, title: String, etc: String? = nil) {
        self.icon = icon
        self.title = title
        self.etc = etc
    }
}
