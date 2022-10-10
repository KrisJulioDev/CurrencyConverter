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
 
/// Mock data of currency available to the app
/// Should be coming from the backend API but we use mock json here for this case
struct Currency: Codable {
    let currency: String
    let amount: Double
    let symbol, locale, name: String
    
    var displayableAmount: String {
        return Formatter.currency(val: amount, symbol: symbol)
    }
}
