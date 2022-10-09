//
//  String+Extension.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit
import Foundation

extension Formatter {
    static func currency(val: Double, symbol: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencySymbol = symbol
        
        if let formatted = formatter.string(from: val as NSNumber) {
            return formatted
        }
        
        return ""
    }
}
 
