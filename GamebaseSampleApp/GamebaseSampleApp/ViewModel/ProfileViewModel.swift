//
//  ProfileViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/26.
//

import Foundation
import Gamebase

final class ProfileViewModel {
    private let profile = {
        Profile(userID: TCGBGamebase.userID(),
                accessToken: TCGBGamebase.accessToken(),
                lastLoggedInProvider: TCGBGamebase.lastLoggedInProvider(),
                authMappingList: TCGBGamebase.authMappingList())
    }()
    
    func getProfile() -> Profile {
        return profile
    }
}
