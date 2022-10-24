//
//  UserManager.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/12.
//

import Foundation
import Gamebase

final class UserManager {
    static let shared = UserManager()
    private var authToken: TCGBAuthToken?
}

extension UserManager {
    static func reset() {
        UserManager.shared.authToken = nil
    }
    
    static func setAuthToken(_ authToken: TCGBAuthToken?) {
        UserManager.shared.authToken = authToken
    }
    
    static func isTemporaryWithdrawalUser() -> Bool {
        return (UserManager.shared.authToken?.tcgbMember.temporaryWithdrawal != nil) ? true : false
    }
    
    static func temporaryWithdrawalGracePeriod() -> Int? {
        return UserManager.shared.authToken?.tcgbMember.temporaryWithdrawal?.gracePeriodDate
    }
}
