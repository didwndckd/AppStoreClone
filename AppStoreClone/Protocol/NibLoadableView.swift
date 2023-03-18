//
//  NibLoadableView.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import UIKit

protocol NibLoadableView {
    static var nibName: String { get }
}

extension NibLoadableView where Self: UIView {
    static var nibName: String {
        return String(describing: Self.self)
    }
    
    func setupFromNib() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: Self.nibName, bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: self).first as? UIView else {
            fatalError("error loading \(self) from nib")
        }
        
        self.addSubview(view)
        view.snp.makeConstraints { $0.edges.equalTo(self) }
    }
}
