//
//  TCGBPushConfiguration+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/26.
//

import Foundation
import Gamebase

extension TCGBPushConfiguration {
    convenience init(appPushConfiguration: AppPushConfiguration) {
        self.init()
        self.pushEnabled = appPushConfiguration.pushEnabled
        self.adAgreement = appPushConfiguration.adAgreement
        self.adAgreementNight = appPushConfiguration.adAgreementNight
    }
}
