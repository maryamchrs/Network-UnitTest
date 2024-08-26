//
//  MockHTTPClient.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 25/08/2024.
//

import Combine
import XCTest
@testable import Network_UnitTest

final class MockHTTPClient: HTTPClient {
    
    var performDataResponse: (Data, HTTPURLResponse)?
    var performError: Error?
    
    var publisherDataResponse: (Data, HTTPURLResponse)?
    var publisherError: Error?
    
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        if let error = publisherError {
            return Fail(error: error)
                .eraseToAnyPublisher()
        } else if let response = publisherDataResponse {
            return Just(response)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: NetworkError.general)
                .eraseToAnyPublisher()
        }
    }
    
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        if let error = performError {
            throw error
        } else if let response = performDataResponse {
            return response
        } else {
            throw NetworkError.general
        }
    }
    
    func perform(_ request: URLRequest) async throws {
        if let error = performError {
            throw error
        }
    }
}
