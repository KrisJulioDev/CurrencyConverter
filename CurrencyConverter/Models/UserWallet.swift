//
//  UserWallet.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/9/22.
//

import Combine

/// hash-map to store values of all currencies, we can use to sum up user's wallet into USD
class UserWallet {
    /// use to store all kind of currencies
    @Published var international: [Currency] = []
    
    /// use to store all currencies converted to dollar
    @Published var dollars: [String: Double] = [:]
}

extension UserWallet {
    func currencyInWallet(symbol: String) -> Currency? {
        return international.filter({ $0.currency == symbol }).first
    }
    
    func addToWallet(_ currency: Currency) {
        removeFromWallet(symbol: currency.currency)
        international.append(currency)
    }
    
    func removeFromWallet(symbol: String) {
        international = international.filter({ $0.currency != symbol })
    }
    
    func hasBalance(amount: Double, currency: Currency) -> Bool {
        if let currentValue = international.filter({ $0.symbol == currency.symbol }).first {
            return currentValue.amount >= amount
        }
        return false
    }
}
