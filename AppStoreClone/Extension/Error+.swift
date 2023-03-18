//
//  Error+.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation

extension Error {
    var isNetworkConnectionFailure: Bool {
        if let apiError = self as? APIError, case APIError.connectionFailure = apiError {
            return true
        }
        else if let error = self.asAFError?.underlyingError {
            let code = (error as NSError).code
            return code == -1009 || code == -1020
        }
        else {
            let code = (self as NSError).code
            return code == -1009 || code == -1020
        }
    }
}
