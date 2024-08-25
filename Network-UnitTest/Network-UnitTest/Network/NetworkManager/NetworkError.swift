//
//  NetworkError.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation

enum NetworkError: Error, Equatable {
    case noData
    case unableToDecode
    case URLSessionError(String)
    case networkConnectionError
    case serverError
    case outDated
    case unauthorized
    case forbidden
    case notFound
    case notAcceptedStatusCode(Int)
    case general
}

extension NetworkError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .noData:
            return "No Data"
        case .unableToDecode:
            return "Unable To Decode"
        case .URLSessionError(let model):
            return model
        case .networkConnectionError:
            return "some problem occured in connection"
        case .serverError:
            return "some problem occured in server"
        case .outDated:
            return "out dated"
        case .unauthorized:
            return "User is not authorized"
        case .forbidden:
            return "Request is forbidden"
        case .notFound:
            return "not found"
        case .notAcceptedStatusCode(let statusCode):
            return "Response Status code is \(statusCode)"
        case .general:
            return "Something went wrong"
        }
    }
}
