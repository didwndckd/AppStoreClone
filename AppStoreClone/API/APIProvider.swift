//
//  APIProvider.swift
//  AppStoreClone
//
//  Created by yjc on 2023/03/18.
//

import Foundation
import RxSwift
import Moya

final class APIProvider<T: APITargetType>: MoyaProvider<T> {
    func request(target: T, callbackQueue: DispatchQueue? = nil, progress: ProgressBlock?) -> Single<Response> {
        return Single.create { single in
            let request = self.request(target, callbackQueue: callbackQueue, progress: progress) { result in
                switch result {
                case .success(let response):
                    single(.success(response))
                case .failure(let error):
                    let apiError = self.convertMoyaErrorToAPIError(error)
                    single(.failure(apiError))
                }
            }
            
            return Disposables.create {
                request.cancel()
            }
        }
    }
    
    private func convertMoyaErrorToAPIError(_ moyaError: MoyaError) -> APIError {
        switch moyaError {
        case .underlying(let error, _) where error.isNetworkConnectionFailure:
            return APIError.connectionFailure
        case .jsonMapping(let response):
            return APIError.parsingFailure(originError: moyaError, originData: response.data)
        default:
            return APIError.unknown(origin: moyaError)
        }
    }
}
