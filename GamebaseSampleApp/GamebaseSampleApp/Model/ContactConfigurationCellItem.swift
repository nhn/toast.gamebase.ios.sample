//
//  ContactConfigurationCellItem.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/13.
//

import Foundation

struct ContactConfigurationCellItem {
    let title: String
    let subTitle: String
    let handler: (() -> ())
    
    init(title: String,
         strValue: String? = nil,
         dicValue: [String: String]? = nil,
         handler: @escaping (() -> ())) {
        
        self.title = title
        self.handler = handler
        
        if let strValue = strValue {
            self.subTitle = strValue
            return
        }
        
        if let dicValue = dicValue {
            self.subTitle = dicValue.description
            return
        }
        
        self.subTitle = "입력한 값이 없습니다."
    }
}
