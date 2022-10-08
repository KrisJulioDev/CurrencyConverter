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
    
    let title = "Wallet"
    
    @Published var coins: [Coin] = []
    @Published var totalMoney: String = "$1,000"
    @Published var error: WalletServiceError?
    
    init(walletService: WalletService, conversionService: ConversionService) {
        self.walletService = walletService
        self.conversionService = conversionService
        self.fetchCoins()
    }
    
    private func fetchCoins() {
        do {
            coins.append(contentsOf: try walletService.fetchWallet())
        } catch(let error) {
            if let error = error as? WalletServiceError {
                self.error = error
            }
        }
    }
    
    func getConvertedValue(of coin: Coin) -> AnyPublisher<String, Error> {
        let conversion = Conversion(fromAmount: coin.amount, fromCurrency: coin.currency, toCurrency: "USD")
        
        return conversionService.convert(conversion: conversion)
            .compactMap { "$\($0.amount)"}
            .eraseToAnyPublisher()
    }
}
