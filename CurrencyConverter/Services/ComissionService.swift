//
//  ComissionService.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/9/22.
//

import Foundation

enum PromoType: Equatable {
    case freeTransaction(Int)
    case minAmount(Int)
    case interval(Int)
    case none
}

class ComissionService: DecodingServiceProtocol {
     
    func availablePromo(comission: Comission,
                        userWallet: UserWallet,
                        currencyInSelect: String?,
                        currencyAmount: Double) -> PromoType {
        var promoType: PromoType = .none
        
        /// check promo if the user is eligible for free transactions
        comission.promos.forEach { promo in
            if promo.type == "free_transaction" {
                if userWallet.transactionsFulfilled < promo.value {
                    promoType = .freeTransaction(promo.value)
                    return
                }
            }
            
            if promo.type == "intervals" {
                if userWallet.transactionsFulfilled > 0 &&
                    /// add + 1, fulfilled + this transaction check
                    (userWallet.transactionsFulfilled + 1) % promo.value == 0 {
                    promoType = .interval(promo.value)
                    return
                }
            }
            
            if promo.type == "amount_minimum", currencyInSelect == promo.currency {
                if currencyAmount >= Double(promo.value) {
                    promoType = .minAmount(promo.value)
                    return
                }
            }
        }
        
        return promoType
    }
    
    /// fetch comission from json, throw error serviceNotAvailable if fails
    func fetchServiceData<T: Codable>() throws -> T {
        guard let jsonFile = Bundle.main.url(forResource: "commision_rules",
                                             withExtension: "json")
        else {
            throw ExchangeError.serviceNotAvailable
        }
        
        do {
            let data = try Data(contentsOf: jsonFile)
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw ExchangeError.serviceNotAvailable
        }
    }
}
