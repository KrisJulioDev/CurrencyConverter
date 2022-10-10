//
//  WalletViewModel.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import Combine


class WalletViewModel {
    let userWallet: UserWallet
    let walletService: WalletService
    let conversionService: ConversionService 
    
    @Published var currencies: [Currency] = [] 
    @Published var totalMoney: Double = 0
    @Published var error: DecodingServiceError?
     
    private var cancellables: Set<AnyCancellable> = []
    
    init(userWallet: UserWallet, walletService: WalletService, conversionService: ConversionService) {
        self.userWallet = userWallet
        self.walletService = walletService
        self.conversionService = conversionService
        self.fetchCurrencies()
    }
    
    private func fetchCurrencies() {
        do {
            let wallet: Wallet = try walletService.fetchServiceData()
            let balance = wallet.currencies.filter { $0.amount > 0 }
            
            /// save all user's currencies
            saveToIntlWallet(userCurrency: balance)
            
            /// store all currencies fetched for display
            currencies.append(contentsOf:wallet.currencies)
        } catch(let error) {
            if let error = error as? DecodingServiceError {
                self.error = error
            }
        }
    }
    
    func saveToIntlWallet(userCurrency: [Currency]) {
        userCurrency.forEach { currency in
            userWallet.international.append(currency)
        }
        
        /// observe changes to user's international wallet to convert it all to USD and display as Total in USD
        userWallet.$international
            .subscribe(on: DispatchQueue.global())
            .sink(receiveValue: { [weak self] currencies in
                currencies.forEach { [weak self] currency in
                    self?.userWallet.dollars = [:]
                    guard let self = self else { return }
                    self.getConvertedValue(of: currency)
                        .replaceError(with: 0)
                        .sink(receiveValue: { [weak self] value in
                            self?.saveToDollarWallet(currencySymbol: currency.currency, amount: value)
                        })
                        .store(in: &self.cancellables)
                }
             })
            .store(in: &cancellables)
    }
    
    func saveToDollarWallet(currencySymbol: String, amount: Double) {
        /// symbol can be USD, PHP, CAD, EUD but currency amount will always be in USD
        userWallet.dollars[currencySymbol] = amount
    }
    
    func getConvertedValue(of currency: Currency) -> AnyPublisher<Double, Error> {
        let conversion = Conversion(fromAmount: currency.amount,
                                    fromCurrency: currency.currency,
                                    toCurrency: GLOBAL_CURRENCY)
        
        return conversionService
            .getConversion(conversion: conversion)
            .map { Double($0.amount) ?? 0 }
            .eraseToAnyPublisher()
    }
}
