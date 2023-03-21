//
//  BaseViewModel.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/21.
//

import Foundation
 
class BaseViewModel {
    deinit {
        print("deinit -> \(type(of: self))")
    }
}
