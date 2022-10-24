//
//  IdPMappingInfo.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/23.
//

import Foundation

struct IdPMappingInfo {
    let idPType: String
    let icon: String
    let alreadyMapped: Bool
    let handler: ((Bool) -> ())?
    
    init(idPType: String, alreadyMapped: Bool, handler: ((Bool) -> ())? = nil) {
        self.idPType = idPType
        self.icon = "\(idPType)_logo"
        self.alreadyMapped = alreadyMapped
        self.handler = handler
    }
}
