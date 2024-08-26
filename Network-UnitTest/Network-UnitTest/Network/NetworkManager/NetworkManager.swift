//
//  NetworkManager.swift
//  Network-UnitTest
//
//  Created by Maryam Chrs on 11/07/2024.
//

import Foundation
import Combine

protocol NetworkManagerProtocol: AnyObject {
    var isNetworkReachable: Bool { get }
    
    func request<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response
    func request<Response: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<Response, Error>
}

final class NetworkManager {
    
    // MARK: - Properties and Constants
    // MARK: Public
    var isNetworkReachable: Bool = true
    
    // MARK: Private
    private var httpClient: HTTPClient
    private var requestMapper: RequestMapperProtocol
    private let errorMapper: ErrorMapperProtocol
    private let logger: LoggerProtocol
    private let networkMonitor = NetworkMonitor()
    private var cancellable = Set<AnyCancellable>()
    
    init(
        client: HTTPClient = URLSession.shared,
        requestMapper: RequestMapperProtocol = APIHTTPRequestMapper(),
        errorMapper: ErrorMapperProtocol = ErrorMapper(),
        logger: LoggerProtocol = NetworkLogger(needToShowLogs: true)
    ) {
        self.httpClient = client
        self.requestMapper = requestMapper
        self.errorMapper = errorMapper
        self.logger = logger
        observeForConnectivityChanges()
    }
}

extension NetworkManager: NetworkManagerProtocol {
    func request<Response: Decodable>(_ urlRequest: URLRequest) async throws -> Response {
        logger.logRequest(urlRequest)
        var response: HTTPURLResponse?
        do {
            let data: (value: Data, response: HTTPURLResponse) = try await httpClient.perform(urlRequest)
            response = data.response
            logger.logResponse(response, data: data.value)
            let convertedData: Response = try requestMapper.map(
                data: data.value,
                response: data.response
            )
            return convertedData
        } catch {
            let mappedError = errorMapper.map(
                error: error,
                response: response,
                isNetworkReachable: isNetworkReachable
            )
                        
            logger.logError(mappedError, for: urlRequest)
            throw mappedError
        }
    }
    
    func request<Response: Decodable>(_ urlRequest: URLRequest) -> AnyPublisher<Response, Error> {
        logger.logRequest(urlRequest)
        return httpClient
            .publisher(urlRequest)
            .tryMap { [weak self] (data, httpURLResponse) in
                guard let self else {
                    throw NetworkError.general
                }
                self.logger.logResponse(httpURLResponse, data: data)
                do {
                    let convertedData: Response = try self.requestMapper.map(
                        data: data,
                        response: httpURLResponse
                    )
                    return convertedData
                } catch {
                    let mappedError = errorMapper.map(
                        error: error,
                        response: httpURLResponse,
                        isNetworkReachable: self.isNetworkReachable
                    )
                    logger.logError(mappedError, for: urlRequest)
                    throw mappedError
                }
            }
            .mapError { [weak self] error in
                guard let self else { return error }
                let mappedError = errorMapper.map(
                    error: error,
                    response: nil,
                    isNetworkReachable: self.isNetworkReachable
                )
                logger.logError(mappedError, for: urlRequest)
                return error
            }
            .eraseToAnyPublisher()
    }
}

extension NetworkManager {
    
    private func makeConfiguration(
        timeout: TimeInterval,
        cachePolicy: URLRequest.CachePolicy
    ) -> URLSessionConfiguration {
        let configuration = URLSessionConfiguration.default
        
        configuration.timeoutIntervalForRequest = timeout
        configuration.timeoutIntervalForResource = timeout
        /*
         A Boolean value that indicates whether connections may use a network interface that the system considers expensive.
         */
        configuration.allowsExpensiveNetworkAccess = false
        /*
         A Boolean value that indicates whether connections may use the network when the user has specified Low Data Mode.
         */
        configuration.allowsConstrainedNetworkAccess = false
        configuration.waitsForConnectivity = true
        
        configuration.requestCachePolicy = cachePolicy
        
        return configuration
    }
    
    /// Start observing the connectivity changes to aware user due to the fact that they need this information.
    private func observeForConnectivityChanges() {
        networkMonitor.startMonitoringNetwork()
            .sink { [weak self] networkInfo in
                guard let self else { return }
                self.isNetworkReachable = networkInfo.isActive
            }
            .store(in: &cancellable)
    }
}
