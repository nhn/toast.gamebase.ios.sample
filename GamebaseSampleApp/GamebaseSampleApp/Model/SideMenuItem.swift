//
//  SideMenuItem.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/25.
//

import Foundation

enum SideMenuItem: String, CaseIterable {
    case home = "Home"
    case shopping = "Shopping"
    case profile = "Profile"
    case settings = "Settings"
    case developer = "Developer"
    
    var segID: String? {
        switch self {
        case .home:
            return nil
        default:
            return "seg\(self.rawValue)"
        }
    }
    
    var icon: String {
        return  "\(self.rawValue.lowercased())_menu"
    }
    
    static subscript(index: Int) -> SideMenuItem {
        return SideMenuItem.allCases[index]
    }
}
