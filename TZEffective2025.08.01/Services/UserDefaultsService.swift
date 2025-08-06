//
//  UserDefaultsService.swift
//  TZEffective2025.08.01
//
//  Created by Валентин on 06.08.2025.
//

import Foundation

protocol UserDefaultsServiceProtocol {
    func isNotFirstLaunch() -> Bool
    func markAsNotFirstLaunch()
}

class UserDefaultsService: UserDefaultsServiceProtocol {
    private let userDefaults = UserDefaults.standard
    private let notFirstLaunchKey = "isNotFirstLaunch"
    
    func isNotFirstLaunch() -> Bool {
        return userDefaults.bool(forKey: notFirstLaunchKey)
    }
    
    func markAsNotFirstLaunch() {
        userDefaults.set(true, forKey: notFirstLaunchKey)
    }

}
