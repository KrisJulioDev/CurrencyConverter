//
//  UIFont.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit

extension UIFont {
    static func avenir(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNextCondensed-Regular", size: size)!
    }
    
    static func avenirMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNextCondensed-Medium", size: size)!
    }
    
    static func avenirBold(size: CGFloat) -> UIFont {
        return UIFont(name: "AvenirNextCondensed-Bold", size: size)!
    }
 
    static func gillSemibold(size: CGFloat) -> UIFont {
        return UIFont(name: "Futura-Medium", size: size)!
    }
}
