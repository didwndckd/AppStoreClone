//
//  ViewModelBased.swift
//  AppStoreClone
//
//  Created by yjc_mac on 2023/03/18.
//

import UIKit

protocol ViewModelBased: AnyObject {
    associatedtype ViewModelType: ViewModel
    var viewModel: ViewModelType! { get set }
}

extension ViewModelBased where Self: StoryboardBased & UIViewController {
    static func instantiate<ViewModelType>(withViewModel viewModel: ViewModelType) -> Self where ViewModelType == Self.ViewModelType {
        let viewController = Self.instantiate()
        viewController.viewModel = viewModel
        return viewController
    }
}
