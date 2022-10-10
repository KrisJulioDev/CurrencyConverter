//
//  DecodingServiceProtocol.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
  
protocol DecodingServiceProtocol {
    func fetchServiceData<T: Codable>() throws -> T
}
