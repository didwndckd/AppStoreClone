//
//  APIError.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import Moya

enum APIError: Error {
    case connectionFailure
    case parsingFailure(originError: Error, originData: Data)
    case unknown(origin: Error)
}
