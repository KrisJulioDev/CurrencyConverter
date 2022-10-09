//
//  Wallet.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
import Combine
import UIKit

struct Wallet: Codable {
    let currencies: [Currency]
}
 
struct Currency: Codable {
    let currency: String
    let amount: Double
    let symbol, locale, name: String
    
    var displayableAmount: String {
        return Formatter.currency(val: amount, symbol: symbol)
    }
}
