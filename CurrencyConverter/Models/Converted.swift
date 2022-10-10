//
//  Converted.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
 
/// Response from exchange rate API
class Converted: Codable {
    /// amount of converted currency from request
    let amount: String
    
    /// currency of the response amount
    let currency: String
    
    init(amount: String, currency: String) {
        self.amount = amount
        self.currency = currency
    }
}
