//
//  SpyNetworkLogger.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 26/08/2024.
//

import XCTest
@testable import Network_UnitTest

final class SpyNetworkLogger: LoggerProtocol {
    
    var logRequestCalled: Bool = false
    var logResponseCalled: Bool = false
    var logErrorCalled: Bool = false
    var loggedError: Error?
    
    var changeLogsVisibilityStatusCalled: Bool = false
    
    func logRequest(_ request: URLRequest?) {
        logRequestCalled = true
    }
    
    func logResponse(_ response: HTTPURLResponse?, data: Data?) {
        logResponseCalled = true
    }
    
    func logError(_ error: Error, for request: URLRequest?) {
        loggedError = error
        logErrorCalled = true
    }
    
    func changeLogsVisibilityStatus(_ shouldBeShown: Bool) {
        changeLogsVisibilityStatusCalled = true
    }
}
