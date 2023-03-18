//
//  StoryboardBased.swift
//  AppStoreClone
//
//  Created by yjc_mac on 2023/03/18.
//

import UIKit

protocol StoryboardBased: AnyObject {
    static var storyboardIdentifier: String { get }
    static var sceneStoryboard: UIStoryboard { get }
}

extension StoryboardBased {
    static var storyboardIdentifier: String {
        return String(describing: self)
    }
    
    static var sceneStoryboard: UIStoryboard {
        return UIStoryboard(name: Self.storyboardIdentifier, bundle: Bundle(for: Self.self))
    }
}

extension StoryboardBased where Self: UIViewController {
    static func instantiate() -> Self {
        let viewController = Self.sceneStoryboard.instantiateViewController(withIdentifier: Self.storyboardIdentifier)
        guard let typeViewController = viewController as? Self else {
            fatalError("The initialViewController of '\(Self.sceneStoryboard)' is not of class '\(self)'")
        }
        return typeViewController
    }
}
