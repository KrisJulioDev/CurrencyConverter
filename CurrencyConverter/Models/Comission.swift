//
//  Comission.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/9/22.
//

import Foundation

// MARK: - Promo
struct Comission: Codable {
    let commisionRate: Double
    let amountMinInCurrency: String
    let promos: [PromoElement]
}

// MARK: - PromoElement
struct PromoElement: Codable {
    let type: String
    let value: Int
    let currency: String?
}

