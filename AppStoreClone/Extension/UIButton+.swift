//
//  UIButton+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit

extension UIButton {
    func setImage(_ url: URL, for state: UIControl.State) {
        self.kf.setImage(with: url, for: state)
    }
    
    func setImage(_ urlString: String, for state: UIControl.State) {
        guard let url = URL(string: urlString) else { return }
        self.setImage(url, for: state)
    }
    
    func setBackgroundImage(_ url: URL, for state: UIControl.State) {
        self.kf.setBackgroundImage(with: url, for: state)
    }
    
    func setBackgroundImage(_ urlString: String, for state: UIControl.State) {
        guard let url = URL(string: urlString) else { return }
        self.setBackgroundImage(url, for: state)
    }
}
