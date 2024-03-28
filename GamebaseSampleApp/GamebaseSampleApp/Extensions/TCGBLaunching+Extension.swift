//
//  TCGBLaunching+Extension.swift
//  GamebaseSampleApp
//
//  Created by Philip Chung on 3/26/24
//

import Foundation
import Gamebase

extension TCGBLaunching {
    private static var testDeviceInfo: [String: Any]? {
        let launchingDict = self.launchingInformations() ?? [String: Any]()
        return TCGBUtil.extractValue(fromJson: launchingDict, searchString: "launching.user.testDevice") as? [String: Any]
    }
    
    static var isTestDevice: Bool {
        guard let testDeviceInfo = self.testDeviceInfo else { return false }
        return (testDeviceInfo["matchingFlag"] as? Bool) ?? false
    }
    
    static var testDeviceTypes: [String] {
        guard let testDeviceInfo = self.testDeviceInfo else { return [String]() }
        return (testDeviceInfo["matchingTypes"] as? [String]) ?? [String]()
    }
}
