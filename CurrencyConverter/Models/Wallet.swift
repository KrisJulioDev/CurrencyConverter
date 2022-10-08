//
//  Wallet.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
import Combine

class Wallet: Codable {
    let coins: [Coin]
}
 
class Coin: Codable {
    let currency: String
    let amount: Double
    let symbol, name, keyword: String
    
    var displayableAmount: String {
        return "\(symbol)\(amount)"
    }
}
