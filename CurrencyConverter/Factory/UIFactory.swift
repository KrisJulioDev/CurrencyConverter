//
//  UIFactory.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit

struct UIFactory {
    enum LabelType {
        case regular
        case medium
        case bold
        case number
    }
    
    static func createLabel(text: String, size: CGFloat, color: UIColor, type: LabelType = .regular) -> UILabel {
        let label = UILabel()
        
        switch type {
        case .regular:
            label.font = UIFont.avenir(size: size)
        case .medium:
            label.font = UIFont.avenirMedium(size: size)
        case .bold:
            label.font = UIFont.avenirBold(size: size)
        case .number:
            label.font = UIFont.gillSemibold(size: size)
        }
        
        label.textColor = color
        label.text = text
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    
    static func createContainer() -> UIView {
        let panel = UIView()
        panel.backgroundColor = .black.withAlphaComponent(0.15)
        panel.translatesAutoresizingMaskIntoConstraints = false
        panel.layer.cornerRadius = 10
        panel.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        panel.layer.borderWidth = 1
        return panel
    }
    
    static func createTextField(size: CGFloat, color: UIColor = .gray) -> UITextField {
        let textField = UITextField()
        textField.font = UIFont.avenirBold(size: size)
        textField.textColor = color
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }
    
    static func createAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        return alert
    }
}
