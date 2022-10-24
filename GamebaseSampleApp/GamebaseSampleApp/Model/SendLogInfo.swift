//
//  SendLogInfo.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/23.
//

import Foundation

struct SendLogInfo {
    let type: LogType
    let title: String
    
    enum LogType: String {
        case debug
        case info
        case warn
        case error
        case fatal
    }
}
