//
//  ErrorMapper.swift
//  Network-UnitTest
//
//  Created by Maryam Chrs on 15/07/2024.
//

import Foundation

/*
 The reason for having ErrorMapperProtocol is, if user wants to have their oun map method and customise is the just need to create a class and conform to ErrorMapperProtocol. And then pass it in the NetworkManage.
 */
protocol ErrorMapperProtocol: AnyObject {
    func map(error: Error, response: HTTPURLResponse?, isNetworkReachable: Bool) -> Error
}

class ErrorMapper: ErrorMapperProtocol {
    
    func map(error: Error, response: HTTPURLResponse?, isNetworkReachable: Bool) -> Error {
        if !isNetworkReachable {
            return NetworkError.networkConnectionError
        }
        
        if let response {
            switch response.statusCode {
            case 401:
                return NetworkError.unauthorized
            case 403:
                return NetworkError.forbidden
            case 404:
                return NetworkError.notFound
            case 500..<600:
                return NetworkError.serverError
            default:
                break
            }
        }
        
        if let networkError = error as? NetworkError {
            return networkError
        }
        
        return NetworkError.general
    }
}
