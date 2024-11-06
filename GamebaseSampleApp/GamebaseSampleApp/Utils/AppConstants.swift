//
//  AppConstants.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/21.
//

import Foundation
import Gamebase

struct AppConstants {
    static let idPList = [
        Gamebase.kTCGBAuthGuest,
        Gamebase.kTCGBAuthGoogle,
        Gamebase.kTCGBAuthiOSGameCenter,
        Gamebase.kTCGBAuthFacebook,
        Gamebase.kTCGBAuthAppleID,
        "payco",    // payco는 sdk에 상수가 정의되어 있지 않아 string으로 선언 필요.
        Gamebase.kTCGBAuthWeibo,
        Gamebase.kTCGBAuthTwitter,
        Gamebase.kTCGBAuthLine,
        Gamebase.kTCGBAuthNaver,
        Gamebase.kTCGBAuthKakaogame,
        Gamebase.kTCGBAuthSteam,
    ]
    
    static let retryCount = 3
}
