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
    
    func changeLogsVisibilityStatus(_ shouldBeShown: Bool)
}

final class NetworkLogger: LoggerProtocol {
    
    private var needToShowLogs: Bool
    var logClosure: ((String) -> Void)?
    
    init(needToShowLogs: Bool, logClosure: ((String) -> Void)? = nil) {
        self.needToShowLogs = needToShowLogs
        self.logClosure = logClosure ?? { print($0) }
    }

    func logRequest(_ request: URLRequest?) {
        guard needToShowLogs else { return }
        guard let request else { return }
        logClosure?("Request ---> \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "UNKNOWN URL")")
        if let headers = request.allHTTPHeaderFields {
            logClosure?("Headers: \(headers)")
        }
        if let body = request.httpBody, let bodyString = String(data: body, encoding: .utf8) {
            logClosure?("Body: \(bodyString)")
        }
    }

    
    func logResponse(_ response: HTTPURLResponse?, data: Data?) {
        guard needToShowLogs else { return }
        if let response {
            logClosure?("Response ---> \(response.statusCode) from \(response.url?.absoluteString ?? "UNKNOWN URL")")
        }
        if let data = data, let bodyString = String(data: data, encoding: .utf8) {
            logClosure?("Body: \(bodyString)")
        }
    }

    
    func logError(_ error: Error, for request: URLRequest?) {
        guard needToShowLogs else { return }
        guard let request else {
            logClosure?("Error \(error.localizedDescription)")
            return
        }
        logClosure?("Error \(error.localizedDescription) for \(request.httpMethod ?? "UNKNOWN") \(request.url?.absoluteString ?? "UNKNOWN URL")")
    }
    
    func changeLogsVisibilityStatus(_ shouldBeShown: Bool) {
        needToShowLogs = shouldBeShown
    }
}
