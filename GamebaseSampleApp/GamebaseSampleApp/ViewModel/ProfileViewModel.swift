//
//  ProfileViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/26.
//

import Foundation
import Gamebase

struct ProfileViewItem {
    let title: String
    let content: String
    let showCopyButton: Bool
}

final class ProfileViewModel {
    private let profile = {
        Profile(
            userID: TCGBGamebase.userID(),
            accessToken: TCGBGamebase.accessToken(),
            lastLoggedInProvider: TCGBGamebase.lastLoggedInProvider(),
            authMappingList: TCGBGamebase.authMappingList()
        )
    }()

    var profileItems: [ProfileViewItem] {
        let mappingList = profile.authMappingList ?? []
        return [
            ProfileViewItem(
                title: "Gamebase UserID",
                content: profile.userID ?? "",
                showCopyButton: true
            ),
            ProfileViewItem(
                title: "Gamebase AccessToken",
                content: profile.accessToken ?? "",
                showCopyButton: true
            ),
            ProfileViewItem(
                title: "Last LoggedIn Provider",
                content: profile.lastLoggedInProvider ?? "",
                showCopyButton: false
            ),
            ProfileViewItem(
                title: "Auth Mapping List",
                content: "[\(mappingList.joined(separator: ", "))]",
                showCopyButton: false
            )
        ]
    }
}
