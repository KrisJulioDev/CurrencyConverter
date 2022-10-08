//
//  ConversionService.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import Combine

class Converted: Codable {
    let amount: String
    let currency: String
}

protocol ConversionServiceProtocol {
    func convert(conversion: Conversion) -> AnyPublisher<Converted, Error>
}

class ConversionService: ConversionServiceProtocol {
    let client: ConversionHTTPClient
    
    init(client: ConversionHTTPClient) {
        self.client = client
    }
    
    func convert(conversion: Conversion) -> AnyPublisher<Converted, Error> {
        let path = createPath(from: conversion) 
        return client.request(path: path).eraseToAnyPublisher()
    }
    
    private func createPath(from conversion: Conversion) -> String {
        return "/currency/commercial/exchange/\(conversion.fromAmount)-\(conversion.fromCurrency)/\(conversion.toCurrency)/latest"
    }
}
