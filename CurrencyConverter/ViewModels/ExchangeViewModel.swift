//
//  ExchangeViewModel.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import Combine

class ExchangeViewModel {
    enum PromoType: Equatable {
        case freeTransaction(Int)
        case minAmount(Int)
        case interval(Int)
        case none
    }
    
    let userWallet: UserWallet
    let walletService: WalletService
    let comissionService: ComissionService
    let conversionService: ConversionService
    
    var cancellables: Set<AnyCancellable> = []
    var conversionCancellable: Set<AnyCancellable> = []
    
    @Published var observableError: Error?
    
    @Published var currencies: [Currency] = []
    @Published var comission: Comission?
    
    /// observe this values to fetch the exchange conversion and display it to the user
    @Published var fromCurrency: Currency?
    @Published var toCurrency: Currency?
      
    @Published var fromValue: Double = 0
    @Published var toValue: Double = 0
    
    /// display commision rate or current promo
    @Published var promoType: PromoType = .none
    @Published var conversionDisplay: String = ""
    
    /// converted value from BUY currency to PROMO required currency for promo checking
    /// currently in EURO -> commision_rules.json
    @Published var comissionInReqdCurrency: Double = 0
    
    /// we require currencies to have at least 2 data, otherwise there's no sense to show to the Exchange UI
    init(wallet: UserWallet,
         walletService: WalletService,
         conversionService: ConversionService,
         comissionService: ComissionService) {
        
        self.userWallet = wallet
        self.walletService = walletService
        self.conversionService = conversionService
        self.comissionService = comissionService
         
        fetchCurrencies()
        
        /// fetch all rules for promo
        fetchPromos()
        
        /// set all the bindings to viewmodel as well
        setObservables()
    }
    
    private func fetchCurrencies() {
        do {
            let wallet: Wallet = try walletService.fetchServiceData()
             
            /// store all currencies fetched for display
            currencies.append(contentsOf:wallet.currencies)
            
            /// set first currency by default as From
            fromCurrency = currencies[0]
            toCurrency = currencies[1]
        } catch(let error) {
            if let error = error as? DecodingServiceError {
                self.observableError = error
            }
        }
    }
    
    func fetchPromos() {
        do {
            let comission: Comission = try comissionService.fetchServiceData()
            self.comission = comission
            updateAvailablePromo()
        } catch(let error) {
            observableError = error
        }
    }
    
    //MARK: Bindings
    func setObservables() {
        $fromValue
            .removeDuplicates()
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] value in
                guard
                    let self = self,
                    let fromCurrency = self.fromCurrency,
                    let toCurrency = self.toCurrency
                else { return }
                
                let fromSymbol = fromCurrency.currency
                let toSymbol = toCurrency.currency
                
                /// fetch conversion everytime the value changes with debounce of 0.5 seconds to prevent spam requests
                let conversion = Conversion(fromAmount: value, fromCurrency: fromSymbol, toCurrency: toSymbol)
                self.fetchConversion(conversion)
                
                /// fetch comission rate at the same time as it needs for balance checking
                self.updateComission()
            })
            .store(in: &cancellables)
        
        $promoType
            .subscribe(on: DispatchQueue.global())
            .receive(on: DispatchQueue.main)
            .sink { [weak self] type in
                guard
                    let self = self,
                    let fromCurrency = self.fromCurrency
                else { return }
                
                var str = ""
                switch type {
                case .freeTransaction(let num):
                    let remaining = num - self.userWallet.transactionsFulfilled
                    str = "You are eligible for free transaction fee \(remaining)/\(num)"
                case .minAmount(let amount):
                    str = "Free transaction fee for amount higher than \(amount) \(self.comission?.amountMinInCurrency ?? "")"
                case .interval(let interval):
                    str = "Free charge every \(interval) transactions"
                default:
                    let cost = String(format: "%.2f", self.exchangeCost())
                    let fee = cost + " \(fromCurrency.currency)"
                    let percentage = (self.comission?.commisionRate ?? 0) * 100
                    str = "Comission fee for this transaction: " + fee + " (\(String(format: "%.2f", percentage))%)"
                }
                
                self.conversionDisplay = str
            }.store(in: &cancellables)
    }
    
    func inputChanged(_ value: Double) {
        fromValue = value
        
        /// always reset toValue everytime fromValue changed to prevent exchanging outdated values
        toValue = 0
    }
    
    //MARK: Business logic
    func currentBalance() -> Double {
        guard let fromCurrency = fromCurrency else { return 0 }
        
        if let currencyInWallet = userWallet.currencyInWallet(symbol: fromCurrency.currency) {
            return currencyInWallet.amount
        }
        return 0
    }
    
    func totalExchangeCost() -> Double {
        return fromValue + (fromValue * estimateCommision())
    }
    
    func exchangeCost() -> Double {
        return fromValue * estimateCommision()
    }
    
    func errorOnExchange() -> ExchangeError?  {
        var com: Double = 0
        
        /// include commision if theres no eligible promo
        if promoType == .none {
            com = comissionInReqdCurrency * (comission?.commisionRate ?? 0)
        }
        
        if let fromCurrency = fromCurrency,
           userWallet.hasBalance(amount: fromValue + com, currency: fromCurrency) == false {
            return .insufficientBalance
        }
        return nil
    }
    
    func updateComission() {
        guard let comission = comission,
              let fromCurrency = fromCurrency
        else {
            return
        }
        let conversion = Conversion(fromAmount: fromValue,
                                    fromCurrency: fromCurrency.currency,
                                    toCurrency: comission.amountMinInCurrency)
        
        /// this will update commision rate value
        fetchCommisionConversion(conversion)
    }
    
    /// fetch commision of the transaction
    func estimateCommision() -> Double {
        guard let comission = comission else { return 0 }
        return promoType == PromoType.none ? comission.commisionRate : 0
    }
    
    func updateAvailablePromo() {
        guard let comission = comission else { return }
         
        var promoType: PromoType = .none
        
        /// check promo if the user is eligible for free transactions
        comission.promos.forEach { promo in
            if userWallet.transactionsFulfilled < promo.freeTransaction {
                promoType = .freeTransaction(promo.freeTransaction)
                return
            }
             
            if userWallet.transactionsFulfilled > 0 &&
                /// add + 1, fulfilled + this transaction check
                (userWallet.transactionsFulfilled + 1) % promo.intervals == 0 {
                promoType = .interval(promo.intervals)
                return
            }
             
            if comissionInReqdCurrency >= Double(promo.amountMin) {
                promoType = .minAmount(promo.amountMin)
                return
            }
        }
        
        self.promoType = promoType
    }
    
    func proceedExchange() {
        guard
            let fromCurrency = fromCurrency,
            let toCurrency = toCurrency
        else {
            return
        }
        
        /// Update data in wallet with new deducted value
        if let currencyInWallet = userWallet.currencyInWallet(symbol: fromCurrency.currency) {
            let newAmount = currencyInWallet.amount - totalExchangeCost()
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
        
        /// get track of transactions fulfilled to be use for comission checking
        userWallet.transactionsFulfilled += 1
    }
    
    //MARK: Display Formatting
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
    
    /// formatted string display for Amount textfield input
    func formattedInput(text: String,
                        replacement: String,
                        range: NSRange) -> String? {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.currencySymbol = ""
        
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
    
    //MARK: API Requests
    /// Conversion API call to fetch currency to currency exchange rate
    private func fetchConversion(_ conversion: Conversion) {
        conversionCancellable.removeAll()
        conversionService.getConversion(conversion: conversion)
            .map { $0.amount }
            .subscribe(on: DispatchQueue.global())
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] stringAmount in
                    if let double = Double(stringAmount) {
                        self?.toValue = double
                    }
            })
            .store(in: &conversionCancellable)
    }
    
    private func fetchCommisionConversion(_ conversion: Conversion) {
        conversionService.getConversion(conversion: conversion)
            .map { $0.amount }
            .subscribe(on: DispatchQueue.global())
            .sink(receiveCompletion: { _ in },
                  receiveValue: { [weak self] stringAmount in
                    if let double = Double(stringAmount) {
                        self?.comissionInReqdCurrency = double
                        self?.updateAvailablePromo()
                    }
            })
            .store(in: &cancellables)
    }
}
    

