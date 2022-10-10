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

enum DecodingServiceError: Error {
   case fileNotFound
   case decodingFail
   
    var title: String {
        return "System Error"
    }
    
   var reason: String {
       switch self {
       case .fileNotFound:
           return "Please try again later"
       case .decodingFail:
           return "There's something wrong with the server. Try again later"
       }
   }
}

enum ExchangeError: Error {
    case insufficientBalance
    case somethingIsWrong
    case serviceNotAvailable
    var title: String {
        switch self {
        case .insufficientBalance:
            return "Exchange failed"
        case .somethingIsWrong:
            return "Something is wrong"
        case .serviceNotAvailable:
            return "Service is not available"
        }
    }
    
    var message: String {
        switch self {
        case .insufficientBalance:
            return "You don't have enough balance to exchange."
        case .somethingIsWrong:
            return "Please try again later."
        case .serviceNotAvailable:
            return "Please try again or contact our support team"
        }
    }
    
}
