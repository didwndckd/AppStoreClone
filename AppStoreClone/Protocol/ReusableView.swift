//
//  ReusableView.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import UIKit

protocol ReusableView {
    static var defaultReuseIdentifier: String { get }
}

extension ReusableView where Self: UIView {
    static var defaultReuseIdentifier: String {
        return String(describing: self)
    }
}
