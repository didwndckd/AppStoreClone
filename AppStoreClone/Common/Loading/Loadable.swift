//
//  Loadable.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import UIKit

protocol Loadable: AnyObject {
    func startLoading()
    func stopLoading()
    func startLoading(loadingView: LoadingView)
    func stopLoading(loadingView: LoadingView)
}

extension Loadable {
    func loading(_ newValue: Bool) {
        if newValue {
            self.startLoading()
        } else {
            self.stopLoading()
        }
    }
}

extension Loadable where Self: UIViewController {
    func startLoading() {
        self.startLoading(loadingView: DefaultLoadingView())
    }
    
    func startLoading(loadingView: LoadingView) {
        loadingView.startLoading() { [weak self, weak loadingView] in
            guard let self = self, let view = loadingView as? UIView else { return }
            self.view.addSubview(view)
            view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    
    func stopLoading() {
        self.view.subviews
            .compactMap { $0 as? LoadingView }
            .forEach { self.stopLoading(loadingView: $0) }
    }
    
    func stopLoading(loadingView: LoadingView) {
        loadingView.stopLoading() { [weak loadingView] in
            (loadingView as? UIView)?.removeFromSuperview()
        }
    }
    
}

extension Loadable where Self: UIView {
    func startLoading() {
        self.startLoading(loadingView: DefaultLoadingView())
    }
    
    func startLoading(loadingView: LoadingView) {
        loadingView.startLoading() { [weak self, weak loadingView] in
            guard let self = self, let view = loadingView as? UIView else { return }
            self.addSubview(view)
            view.snp.makeConstraints { $0.edges.equalToSuperview() }
        }
    }
    
    func stopLoading() {
        self.subviews
            .compactMap { $0 as? LoadingView }
            .forEach { self.stopLoading(loadingView: $0) }
    }
    
    func stopLoading(loadingView: LoadingView) {
        loadingView.stopLoading() { [weak loadingView] in
            (loadingView as? UIView)?.removeFromSuperview()
        }
    }
}
