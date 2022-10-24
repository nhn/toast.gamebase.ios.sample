//
//  TCGBErrorCode+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/04.
//

import Foundation
import Gamebase

extension TCGBErrorCode {
    func isNetworkError() -> Bool {
        switch self {
        case .ERROR_SOCKET_ERROR, .ERROR_SOCKET_RESPONSE_TIMEOUT:
            return true
        default:
            return false
        }
    }
}
