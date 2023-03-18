//
//  WindowService.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import UIKit

final class WindowService {
    static let shared = WindowService()
    private init() {}
    
    var window: UIWindow?
}

extension WindowService {
    func configure(window: UIWindow) {
        window.rootViewController = MainTabBarViewController()
        window.makeKeyAndVisible()
        self.window = window
    }
}
