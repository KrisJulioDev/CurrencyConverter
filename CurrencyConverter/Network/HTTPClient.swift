//
//  HTTPClient.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import Combine

enum APIError: LocalizedError {
  /// Invalid request, e.g. invalid URL
  case invalidRequestError(String)
}

protocol HTTPClient {
    func request<T: Codable>(path: String) -> AnyPublisher<T, Error>
}

class ConversionHTTPClient: HTTPClient {
    private let scheme = "http"
    private let host = "api.evp.lt"
    
    func request<T: Codable>(path: String) -> AnyPublisher<T, Error> {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
     
        guard let url = components.url else {
            return Fail(error: APIError.invalidRequestError("URL Invalid"))
                .eraseToAnyPublisher()
        }
        
        return URLSession.shared
                .dataTaskPublisher(for: url)
                .map(\.data) 
                .decode(type: T.self, decoder: JSONDecoder())
                .eraseToAnyPublisher()
    }
}
