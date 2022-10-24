//
//  WebViewContentModeItem.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/03.
//

import Foundation

enum WebViewContentModeItem: String, CaseIterable {
    case TCGBWebViewContentModeRecommended = "현재 플랫폼 추천 브라우저"
    case TCGBWebViewContentModeMobile = "모바일 브라우저"
    case TCGBWebViewContentModeDesktop = "데스크톱 브라우저"
    
    static subscript(index: Int) -> String {
        return WebViewContentModeItem.allCases[index].rawValue
    }
}
