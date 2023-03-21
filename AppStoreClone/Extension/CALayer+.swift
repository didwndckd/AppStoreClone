//
//  CALayer+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit

extension CALayer {
    func applySketchShadow(color: UIColor = .black,
                           alpha: Float = 0.5,
                           x: CGFloat = 0,
                           y: CGFloat = 2,
                           blur: CGFloat = 4,
                           spread: CGFloat = 0) {
        self.masksToBounds = false
        self.shadowColor = color.cgColor
        self.shadowOpacity = alpha
        self.shadowOffset = CGSize(width: x, height: y)
        self.shadowRadius = blur / 2
        let dx = -spread
        let rect = self.bounds.insetBy(dx: dx, dy: dx)
        self.shadowPath = UIBezierPath(roundedRect: rect, cornerRadius: self.cornerRadius).cgPath
    }
    
    func updateCurrentShadowPath() {
        self.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: self.cornerRadius).cgPath
    }
}
