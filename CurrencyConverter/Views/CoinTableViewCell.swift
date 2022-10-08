//
//  CoinTableViewCell.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit
import SnapKit
import Combine

class CoinTableViewCell: UITableViewCell {
    static let identifier = "coin_cell_identifier"
    private var cancellables: Set<AnyCancellable> = []
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentView.subviews.forEach{ $0.removeFromSuperview() }
    }
    
    func configure(coin: Coin, viewModel: WalletViewModel) {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        let parentView = UIView()
        parentView.backgroundColor = .white.withAlphaComponent(0.05)
        parentView.layer.borderWidth = 1
        parentView.layer.borderColor = UIColor.gray.withAlphaComponent(0.2).cgColor
        parentView.layer.cornerRadius = 10
        
        contentView.addSubview(parentView)
        parentView.snp.makeConstraints { $0.edges.equalToSuperview().inset(5) }
         
        let currencySign = UILabel()
        currencySign.font = UIFont.avenirMedium(size: 25)
        currencySign.textColor = .white
        currencySign.text = coin.currency
        parentView.addSubview(currencySign)
        
        currencySign.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(5)
        }
        
        let name = UILabel()
        name.font = UIFont.avenirMedium(size: 15)
        name.textColor = .lightGray
        name.text = "\(coin.name)"
        parentView.addSubview(name)
        
        name.snp.makeConstraints {
            $0.top.equalTo(currencySign.snp.bottom)
            $0.left.bottom.equalToSuperview().inset(5)
        }
           
        let value = UILabel()
        value.font = UIFont.avenirMedium(size: 25)
        value.textColor = .white
        value.text = coin.displayableAmount
        parentView.addSubview(value)
        
        value.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(5)
            $0.left.greaterThanOrEqualTo(currencySign.snp.left)
        }
        
        let convertedToUSD = UILabel()
        convertedToUSD.font = UIFont.avenirMedium(size: 15)
        convertedToUSD.textColor = .lightGray
        parentView.addSubview(convertedToUSD)
        
        convertedToUSD.snp.makeConstraints {
            $0.top.equalTo(value.snp.bottom)
            $0.right.bottom.equalToSuperview().inset(5)
        }
        
        viewModel.getConvertedValue(of: coin)
            .receive(on: DispatchQueue.main)
            .replaceError(with: "")
            .sink(receiveValue: { value in
                convertedToUSD.text = value
            })
            .store(in: &cancellables)
        
    }
}
