//
//  ViewModel.swift
//  AppStoreClone
//
//  Created by yjc_mac on 2023/03/18.
//

import Foundation

protocol ViewModel {
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
