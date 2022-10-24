//
//  AppPushConfiguration.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/24.
//

import Foundation

struct AppPushConfiguration: Equatable, Codable {
    var pushEnabled: Bool
    var adAgreement: Bool
    var adAgreementNight: Bool
    
    init(pushEnabled: Bool = true,
         adAgreement: Bool = true,
         adAgreementNight: Bool = true) {
        self.pushEnabled = pushEnabled
        self.adAgreement = adAgreement
        self.adAgreementNight = adAgreementNight
    }
}
