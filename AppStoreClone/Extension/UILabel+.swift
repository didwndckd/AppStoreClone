//
//  UILabel+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/22.
//

import UIKit

extension UILabel {
    var isMoreText: Bool {
        let bounds = CGRect(origin: .zero, size: CGSize(width: self.self.bounds.width, height: CGFloat(Int.max)))
        let fullTextHeight = self.textRect(forBounds: bounds, limitedToNumberOfLines: 0).height
        return fullTextHeight > self.bounds.height
    }
}
