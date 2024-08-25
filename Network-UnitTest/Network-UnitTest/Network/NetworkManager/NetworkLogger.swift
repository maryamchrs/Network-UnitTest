//
//  NetworkLogger.swift
//  Network-UnitTest
//
//  Created by Maryam Chaharsooghi on 11/8/2024.
//

import Foundation

protocol LoggerProtocol {
    func logRequest(_ request: URLRequest?)
    func logResponse(_ response: HTTPURLResponse?, data: Data?)
    func logError(_ error: Error, for request: URLRequest?)
}

final class NetworkLogger: LoggerProtocol {
    
    private var needToShowLogs: Bool
    
    
    init(needToShowLogs: Bool) {
        self.needToShowLogs = needToShowLogs
    }

    func logRequest(_ request: URLRequest?) {
        guard needToShowLogs else { return }
        guard let request else { return }
        print("Request ---> \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "UNKNOWN URL")")
        if let headers = request.allHTTPHeaderFields {
            print("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }

    
    func logResponse(_ response: HTTPURLResponse?, data: Data?) {
        guard needToShowLogs else { return }
        if let response {
            print("Response ---> \(response.statusCode) from \(response.url?.absoluteString ?? "UNKNOWN URL")")
        }
        if let data = data, let bodyString = String(data: data, encoding: .utf8) {
            print("Body: \(bodyString)")
        }
    }

    
    func logError(_ error: Error, for request: URLRequest?) {
        guard needToShowLogs else { return }
        guard let request else {
            print("Error \(error.localizedDescription)")
            return
        }
        print("Error \(error.localizedDescription) for \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "UNKNOWN URL")")
    }
}
