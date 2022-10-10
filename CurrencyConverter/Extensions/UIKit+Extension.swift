//
//  String+Extension.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit
import Foundation
import Combine

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

extension UITextField {
    func textPublisher() -> AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: self)
            .map { ($0.object as? UITextField)?.text  ?? "" }
            .eraseToAnyPublisher()
    }
  }

extension String {
    // formatting text for currency textField
    func currencyFormatting() -> String {
        if let value = Double(self) {
            let formatter = NumberFormatter()
            formatter.numberStyle = .currency
            formatter.maximumFractionDigits = 2
            formatter.minimumFractionDigits = 2
            formatter.currencySymbol = ""
            if let str = formatter.string(for: value) {
                return str
            }
        }
        return ""
    }
}
