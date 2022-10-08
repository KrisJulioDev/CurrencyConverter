//
//  CurrencyServiceProtocol.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
 
enum CurrencyServiceError: Error {
    case fileNotFound
    case decodingFail
    
    var reason: String {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .decodingFail:
            return "Decoding failed"
        }
    }
}

protocol CurrencyServiceProtocol {
    func fetchCurrencies<T: Codable>() throws -> T
}
