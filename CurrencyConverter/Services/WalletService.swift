//
//  WalletService.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
 
import Foundation

enum WalletServiceError: Error {
    case fileNotFound
    case decodingFail
    
    var reason: String {
        switch self {
        case .fileNotFound:
            return "File not found"
        case .decodingFail:
            return "Decoding failed"
        }
    }
}

protocol WalletServiceProtocol {
    func fetchWallet() throws -> [Coin]
}

class WalletService: WalletServiceProtocol {
    func fetchWallet() throws -> [Coin] {
        guard let jsonFile = Bundle.main.url(forResource: "wallet",
                                             withExtension: "json")
        else {
            throw WalletServiceError.fileNotFound
        }
        
        do {
            let data = try Data(contentsOf: jsonFile)
            let wallet = try JSONDecoder().decode(Wallet.self, from: data)
            return wallet.coins
        } catch {
            throw WalletServiceError.decodingFail
        }
    }
}
