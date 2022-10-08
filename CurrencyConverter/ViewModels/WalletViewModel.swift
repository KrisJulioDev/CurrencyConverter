//
//  WalletViewModel.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import Combine

class WalletViewModel {
    let walletService: WalletService
    let conversionService: ConversionService 
    
    @Published var currencies: [Currency] = []
    @Published var displayableCurrency: [Currency] = []
    @Published var totalMoney: Double = 0
    @Published var error: CurrencyServiceError?
    
    /// hash-map to store values of all currencies, we can use to sum up user's wallet into USD
    @Published var USDWallet: [String: Double] = [:]
    
    /// this can be change depends on user's preference, but for now we set it to USD
    private let globalCurrency = "USD"
    
    init(walletService: WalletService, conversionService: ConversionService) {
        self.walletService = walletService
        self.conversionService = conversionService
        self.fetchCurrencies()
    }
    
    private func fetchCurrencies() {
        do {
            let wallet: Wallet = try walletService.fetchCurrencies()
            let displayable = wallet.currencies.filter { $0.amount > 0 }
            displayableCurrency.append(contentsOf: displayable)
            currencies.append(contentsOf:wallet.currencies)
        } catch(let error) {
            if let error = error as? CurrencyServiceError {
                self.error = error
            }
        }
    }
    
    func updateTotalBalance(originalCurrency: String, amount: Double) {
        USDWallet[originalCurrency] = amount
        totalMoney = USDWallet.values.reduce(0) { $0 + $1 }
    }
    
    func getConvertedValue(of currency: Currency) -> AnyPublisher<Double, Error> {
        let conversion = Conversion(fromAmount: currency.amount,
                                    fromCurrency: currency.currency,
                                    toCurrency: globalCurrency)
        
        return conversionService
            .convert(conversion: conversion)
            .map { Double($0.amount) ?? 0 }
            .eraseToAnyPublisher()
    }
}
