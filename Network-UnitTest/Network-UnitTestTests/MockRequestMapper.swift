//
//  MockRequestMapper.swift
//  Network-UnitTestTests
//
//  Created by Maryam Chrs on 25/08/2024.
//

import XCTest
@testable import Network_UnitTest

class MockRequestMapper: RequestMapperProtocol {
    var jsonDecoder: JSONDecoder
    var shouldThrowError: Bool
    var simulatedStatusCode: Int

    init(jsonDecoder: JSONDecoder = JSONDecoder(),
         shouldThrowError: Bool = false,
         simulatedStatusCode: Int = 200) {
        self.jsonDecoder = jsonDecoder
        self.shouldThrowError = shouldThrowError
        self.simulatedStatusCode = simulatedStatusCode
    }

    func map<T>(data: Data, response: HTTPURLResponse) throws -> T where T: Decodable {
        guard (200..<300).contains(simulatedStatusCode) else {
            throw NetworkError.notAcceptedStatusCode(simulatedStatusCode)
        }
        
        if shouldThrowError {
            throw NetworkError.unableToDecode
        }
        
        do {
            return try jsonDecoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.unableToDecode
        }
    }
}


