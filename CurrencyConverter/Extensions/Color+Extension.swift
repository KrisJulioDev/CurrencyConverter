//
//  Color+Extension.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit 
 
extension UIColor {
    static var appOrange: UIColor = {
        return UIColor(named: "buttonColor") ?? .orange
    }()
    
    static var appDarkblue: UIColor = {
        return UIColor(named: "backgroundColor") ?? .orange
    }()
}
