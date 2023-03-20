//
//  LoadingView.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation

protocol LoadingView: AnyObject {
    func startLoading()
    func stopLoading()
    func startLoading(completion: (() -> Void)?)
    func stopLoading(completion: (() -> Void)?)
}

extension LoadingView {
    func startLoading(completion: (() -> Void)?) {
        self.startLoading()
        completion?()
    }
    
    func stopLoading(completion: (() -> Void)?) {
        self.stopLoading()
        completion?()
    }
}
