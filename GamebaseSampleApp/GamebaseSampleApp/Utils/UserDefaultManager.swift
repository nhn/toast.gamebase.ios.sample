//
//  UserDefaultManager.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/25.
//

import Foundation

struct UserDefaultManager {
    // MARK: - AppPermission
    @UserDefaultWrapper(key: UserDefaults.isAppPermissionAgreedKeyname, defaultValue: false)
    static var isAppPermissionAgreed: Bool?
    
    // MARK: - Push
    @UserDefaultWrapperForCodable(key: UserDefaults.appPushConfigurationKeyname, defaultValue: AppPushConfiguration())
    static var appPushConfiguration: AppPushConfiguration?
}

@propertyWrapper
struct UserDefaultWrapper<T> {
    private let key: String
    private let defaultValue: T?
    
    init(key: String, defaultValue: T?) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T? {
        get {
            return UserDefaults.standard.value(forKey: key) as? T ?? defaultValue
        }
        
        set {
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
}

@propertyWrapper
struct UserDefaultWrapperForCodable<T: Codable> {
    private let key: String
    private let defaultValue: T?
    
    init(key: String, defaultValue: T?) {
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue: T? {
        get {
            if let savedData = UserDefaults.standard.object(forKey: key) as? Data {
                let decoder = JSONDecoder()
                if let savedObject = try? decoder.decode(T.self, from: savedData) {
                    return savedObject
                }
            }
            return defaultValue
        }
        
        set {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(newValue) {
                UserDefaults.standard.setValue(encoded, forKey: key)
            }
        }
    }
}
