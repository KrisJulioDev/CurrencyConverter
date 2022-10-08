//
//  WalletService.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
 
import Foundation
 
class WalletService: CurrencyServiceProtocol {
    func fetchCurrencies<T: Codable>() throws -> T {
        guard let jsonFile = Bundle.main.url(forResource: "wallet",
                                             withExtension: "json")
        else {
            throw CurrencyServiceError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: jsonFile)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CurrencyServiceError.decodingFail
        }
    }
}
