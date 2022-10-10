//
//  Conversion.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation

/// Used for API request to check conversion rate
struct Conversion {
    
    /// amount to convert
    let fromAmount: Double
    
    /// currency of the amount to convert
    let fromCurrency: String
    
    /// currency of what you want it to convert to
    let toCurrency: String
}

