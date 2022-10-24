//
//  Error+Extension.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/03.
//

import Foundation
import Gamebase

extension Error {
    func gamebaseErrorCode() -> TCGBErrorCode {
        guard let tcgbError =  self as? TCGBError else { return TCGBErrorCode.ERROR_UNKNOWN_ERROR }
        return TCGBErrorCode(rawValue: tcgbError.code)!
    }
}
