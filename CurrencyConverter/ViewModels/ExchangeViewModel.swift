//
//  ExchangeViewModel.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation

class ExchangeViewModel { 
    @Published var currencies: [Currency] = []
    @Published var error: CurrencyServiceError?
    
    @Published var fromCurrency: Currency?
    @Published var toCurrency: Currency? 
    
    init(currencies: [Currency]) {
        self.currencies = currencies
        
        /// set first currency by default as From
        if let first = currencies.first {
            self.fromCurrency = first
            
            /// set second currency by default as To
            if currencies.count > 1 {
                let second = currencies[1]
                self.toCurrency = second
            }
        }
    }
}
