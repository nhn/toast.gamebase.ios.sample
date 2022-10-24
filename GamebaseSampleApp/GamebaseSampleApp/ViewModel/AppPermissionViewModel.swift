//
//  AppPermissionViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/26.
//

import Foundation

final class AppPermissionViewModel {
    static let shared = AppPermissionViewModel()
    private let permissionInfos = [
        AppPermissionInfo(imageName: "person",
                          title: "광고 식별자(선택)",
                          description: "Gamebase IDFA API 호출 시 필요."),
        AppPermissionInfo(imageName: "camera",
                          title: "카메라(선택)",
                          description: "Gamebase 고객센터 API 호출시 필요.\n사용자가 문의사항에 사진 또는 동영상 첨부 시 사용."),
        AppPermissionInfo(imageName: "photo",
                          title: "사진(선택)",
                          description: "Gamebase 고객센터 API 호출 시 필요.\n사용자가 문의사항에 앨범에서 사진 또는 동영상 첨부 시 사용."),
    ]

    func getPermissionInfos() -> [AppPermissionInfo] {
        return permissionInfos
    }
    
    func agreeAboutAppPermission() {
        UserDefaultManager.isAppPermissionAgreed = true
    }
}
