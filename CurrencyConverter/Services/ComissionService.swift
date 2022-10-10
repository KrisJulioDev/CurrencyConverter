//
//  ComissionService.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/9/22.
//

import Foundation

class ComissionService: DecodingServiceProtocol {
    
    /// fetch comission from json, throw error serviceNotAvailable if fails
    func fetchServiceData<T: Codable>() throws -> T {
        guard let jsonFile = Bundle.main.url(forResource: "commision_rules",
                                             withExtension: "json")
        else {
            throw ExchangeError.serviceNotAvailable
        }
        
        do {
            let data = try Data(contentsOf: jsonFile)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ExchangeError.serviceNotAvailable
        }
    }
    
    
}
