//
//  CurrencyServiceProtocol.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
  
protocol CurrencyServiceProtocol {
    func fetchCurrencies<T: Codable>() throws -> T
}
