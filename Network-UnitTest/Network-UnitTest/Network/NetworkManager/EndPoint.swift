//
//  EndPoint.swift
//
//  Created by Maryam Chrs on 09/02/2024.
//

import Foundation

protocol EndPoint {
    
    var baseURL: String { get }
    
    var path: String { get }
    
    var httpMethod: HTTPMethod { get }
    
    var httpHeaders: [String: String]? { get }
    
    var allHeaders: [String: String] { get }
    
    var httpBody: Encodable? { get }
    
    var timeoutInterval: TimeInterval { get }
    
     var cachePolicy: URLRequest.CachePolicy { get }
}

extension EndPoint {
    
    var timeoutInterval: TimeInterval { 60 }
    
    var cachePolicy: URLRequest.CachePolicy { .returnCacheDataElseLoad }
    
    var allHeaders: [String: String] {
        defaultHeaders.merging(httpHeaders ?? [:]) { (_, new) in new }
    }
    
    var urlRequest: URLRequest? {
        guard let url = URL(string: baseURL + path) else { return nil }
        var urlRequest = URLRequest(url: url, 
                                    cachePolicy: cachePolicy, 
                                    timeoutInterval: timeoutInterval)
        urlRequest.httpMethod = httpMethod.rawValue
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        if let body = httpBody {
            let jsonData = try? encoder.encode(body)
            urlRequest.httpBody = jsonData
        }
        allHeaders.forEach({
            urlRequest.addValue($1, forHTTPHeaderField: $0)
        })
        return urlRequest
    }
}

extension EndPoint {
    private var defaultHeaders: [String: String] {
        ["Content-Type": "application/json",
         "Accept": "application/json"]
    }
}
