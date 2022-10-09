//
//  Errors.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//
import Foundation
  
enum APIError: LocalizedError {
  /// Invalid request, e.g. invalid URL
  case invalidRequestError(String)
}

enum CurrencyServiceError: Error {
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

enum ExchangeError: Error {
    case insufficientBalance
    case somethingIsWrong
    
    var title: String {
        switch self {
        case .insufficientBalance:
            return "Exchange failed"
        case .somethingIsWrong:
            return "Something is wrong"
        }
    }
    
    var message: String {
        switch self {
        case .insufficientBalance:
            return "You don't have enough balance to exchange."
        case .somethingIsWrong:
            return "Please try again later."
        }
    }
    
}
