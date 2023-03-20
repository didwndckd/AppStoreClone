//
//  UIImageView+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/20.
//

import UIKit
import Kingfisher

extension UIImageView {
    func setImage(_ url: URL, placeholder: UIImage? = nil) {
        self.kf.setImage(with: url, placeholder: placeholder)
    }
    
    func setImage(_ urlString: String, placeholder: UIImage? = nil) {
        guard let url = URL(string: urlString) else {
            self.image = placeholder
            return
        }
        
        self.kf.setImage(with: url, placeholder: placeholder)
    }
}
