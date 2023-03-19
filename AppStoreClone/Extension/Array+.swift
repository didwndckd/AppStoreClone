//
//  Array+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/19.
//

import Foundation

extension Array {
    func safety(index: Int) -> Element? {
        guard index < self.count else { return nil }
        return self[index]
    }
}
