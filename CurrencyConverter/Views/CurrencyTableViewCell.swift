//
//  CurrencyTableViewCell.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit

class CurrencyTableViewCell: UITableViewCell {
    static let identifier = "currency_cell_identifier"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach{ $0.removeFromSuperview() }
    }
    
    func configure(currency: Currency) {
        contentView.backgroundColor = .gray.withAlphaComponent(0.05)
        backgroundColor = .clear
        
        let symbol = UIFactory.createLabel(text: currency.currency, size: 18, color: .gray)
        contentView.addSubview(symbol)
        symbol.snp.makeConstraints({ $0.top.left.bottom.equalToSuperview().inset(15) })
        
        let name = UIFactory.createLabel(text: currency.name, size: 18, color: .gray)
        contentView.addSubview(name)
        name.snp.makeConstraints({ $0.top.right.bottom.equalToSuperview().inset(15) })
        
        let divider = UIView()
        divider.backgroundColor = .black
        contentView.addSubview(divider)
        divider.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.right.bottom.equalToSuperview()
        }
    }
}
