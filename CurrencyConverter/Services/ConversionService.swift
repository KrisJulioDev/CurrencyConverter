//
//  ConversionService.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import Combine

protocol ConversionServiceProtocol {
    func getConversion(conversion: Conversion) -> AnyPublisher<Converted, Error>
//    func convert(from: Currency, to: Currency) -> (Currency, Currency)
}

class ConversionService: ConversionServiceProtocol {
    let client: ConversionHTTPClient
    
    init(client: ConversionHTTPClient) {
        self.client = client
    }
    
    func getConversion(conversion: Conversion) -> AnyPublisher<Converted, Error> {
        let path = createPath(from: conversion)
        return client.request(path: path).eraseToAnyPublisher()
    }
    
    private func createPath(from conversion: Conversion) -> String {
        return "/currency/commercial/exchange/\(conversion.fromAmount)-\(conversion.fromCurrency)/\(conversion.toCurrency)/latest"
    }
}

