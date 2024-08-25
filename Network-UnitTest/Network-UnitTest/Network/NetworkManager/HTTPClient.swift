//
//  HTTPClient.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation
import Combine

protocol HTTPClient {
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse)
    func perform(_ request: URLRequest) async throws
}

extension URLSession: HTTPClient {
    /*
     This error only use with URLSession so no need to move in outside the extension URLSession
     */
    struct InvalidHTTPResponseError: Error {}
    /*
     TIP:
     HTTPURLResponse: is a subclass of URLResponse and specifically deals with HTTP responses.
     It provides additional HTTP-specific information, such as status code, headers, and localized status code string
     */
    
    func publisher(_ request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        return dataTaskPublisher(for: request)
            .tryMap({ result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw InvalidHTTPResponseError()
                }
                return (result.data, httpResponse)
            })
            .eraseToAnyPublisher()
    }
    
    func perform(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        let result: (data: Data, response: URLResponse) = try await data(for: request)
        guard let httpResponse = result.response as? HTTPURLResponse else {
            throw InvalidHTTPResponseError()
        }
        return (result.data, httpResponse)
    }
   
    func perform(_ request: URLRequest) async throws {
        let _ = try await data(for: request)
    }
}
