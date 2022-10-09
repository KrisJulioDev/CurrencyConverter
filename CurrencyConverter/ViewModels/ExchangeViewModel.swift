//
//  ExchangeViewModel.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import Combine

class ExchangeViewModel {
    let conversionService: ConversionService
    let userWallet: UserWallet
    
    var cancellables: Set<AnyCancellable> = []
    
    /// use this when displaying the list of currencies we can only exchange
    var balancedCurrencies: [Currency] = []
    @Published var currencies: [Currency] = [] {
        didSet {
            balancedCurrencies = currencies.filter({ $0.amount > 0 })
        }
    }
    
    @Published var error: CurrencyServiceError?
    
    /// observe this values to fetch the exchange conversion and display it to the user
    @Published var fromCurrency: Currency
    @Published var toCurrency: Currency
    
    @Published var fromValue: Double = 0
    @Published var toValue: Double = 0
    @Published var conversionDisplay: String?
     
    /// we require currencies to have at least 2 data, otherwise there's no sense to show to the Exchange UI
    init(currencies: [Currency], wallet: UserWallet, conversionService: ConversionService) {
        self.userWallet = wallet
        self.currencies = currencies
        self.balancedCurrencies = currencies.filter({ $0.amount > 0 })
        self.conversionService = conversionService
        
        /// set first currency by default as From
        self.fromCurrency = currencies[0]
        self.toCurrency = currencies[1]
        
        /// set all the bindings to viewmodel as well
        setObservables()
    }
    
    func setObservables() {
        $fromValue
            .removeDuplicates()
            .sink(receiveValue: { [weak self] value in
                guard let self = self else { return }
                
                let fromSymbol = self.fromCurrency.currency
                let toSymbol = self.toCurrency.currency
                 
                /// fetch conversion everytime the value changes with debounce of 0.5 seconds to prevent spam requests
                let conversion = Conversion(fromAmount: value, fromCurrency: fromSymbol, toCurrency: toSymbol)
                self.fetchConversion(conversion)
            })
            .store(in: &cancellables)
    } 
    
    func inputChanged(_ value: Double) {
        fromValue = value
        
        /// always reset toValue everytime fromValue changed to prevent exchanging outdated values
        toValue = 0
    }
    
    func errorOnExchange() -> ExchangeError?  {
        if userWallet.hasBalance(amount: fromValue, currency: fromCurrency) == false {
            return .insufficientBalance
        }
        return nil
    }
    
    func proceedExchange() {
        /// Update data in wallet with new deducted value
        if let currencyInWallet = userWallet.currencyInWallet(symbol: fromCurrency.currency) {
            let newAmount = currencyInWallet.amount - fromValue
            let newValue = Currency(currency: fromCurrency.currency,
                                    amount: newAmount,
                                    symbol: fromCurrency.symbol,
                                    locale: fromCurrency.locale,
                                    name: fromCurrency.name) 
            userWallet.addToWallet(newValue)
        }
        
        /// Update existing currency in wallet if user have it
        if let currencyInWallet = userWallet.currencyInWallet(symbol: toCurrency.currency) {
            let newAmount = currencyInWallet.amount + toValue
            let newValue = Currency(currency: toCurrency.currency,
                                    amount: newAmount,
                                    symbol: toCurrency.symbol,
                                    locale: toCurrency.locale,
                                    name: toCurrency.name)
            userWallet.addToWallet(newValue)
        } else {
            /// Otherwise just add it in wallet
            let newValue = Currency(currency: toCurrency.currency,
                                    amount: toValue,
                                    symbol: toCurrency.symbol,
                                    locale: toCurrency.locale,
                                    name: toCurrency.name)
            userWallet.addToWallet(newValue)
        }
    }
    
    /// returns formatted string and number value of the field text
    func formattedValue(symbol: String, field: String) -> (String, NSNumber) {
        /// Currency formatter for label display
        let inputFormatter = NumberFormatter()
        inputFormatter.numberStyle = .decimal
        inputFormatter.maximumFractionDigits = 15
        inputFormatter.groupingSeparator = ","
        inputFormatter.decimalSeparator = "."
        
        let cleanNumbers = field
            /// remove commas
            .replacingOccurrences(of: inputFormatter.groupingSeparator, with: "")
            /// remove symbol
            .replacingOccurrences(of: symbol, with: "")
        
        if let numberWithoutGroupingSeparator = inputFormatter.number(from: cleanNumbers),
           let formattedText = inputFormatter.string(from: numberWithoutGroupingSeparator) {
            return (formattedText,  NSNumber(floatLiteral: Double(cleanNumbers) ?? 0))
        }
        
        return ("", 0)
    }
    
    func formattedInput(text: String,
                        replacement: String,
                        range: NSRange) -> String? {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = Locale(identifier: fromCurrency.locale)
        
        let oldDigits = numberFormatter.number(from: text) ?? 0
        var digits = oldDigits.decimalValue

        if let digit = Decimal(string: replacement) {
            let newDigits: Decimal = digit / 100

            digits *= 10
            digits += newDigits
        }
        
        if range.length == 1 {
            digits /= 10
            var result = Decimal(integerLiteral: 0)
            NSDecimalRound(&result, &digits, 1, Decimal.RoundingMode.down)
            digits = result
        }
        
        return numberFormatter.string(from: digits as NSDecimalNumber)
    }
    
    private func fetchConversion(_ conversion: Conversion) {
        conversionService.getConversion(conversion: conversion).map { $0.amount }
            .subscribe(on: DispatchQueue.global())
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] stringAmount in
                    if let double = Double(stringAmount) {
                        self?.toValue = double
                    }
            })
            .store(in: &cancellables)
    }
}

