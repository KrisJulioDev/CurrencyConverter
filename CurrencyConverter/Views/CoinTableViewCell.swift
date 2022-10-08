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
        cancellables = Set<AnyCancellable>()
    }
    
    func configure(coin: Currency, viewModel: WalletViewModel) {
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        
        /// UI Stuff, it's ideal to not use hardcoded values, for this test I think its fine to have it here
        /// and focus more on the  complex parts
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
            $0.top.left.equalToSuperview().offset(10)
        }
        
        let name = UILabel()
        name.font = UIFont.avenirMedium(size: 15)
        name.textColor = .lightGray
        name.text = coin.name
        parentView.addSubview(name)
        
        name.snp.makeConstraints {
            $0.top.equalTo(currencySign.snp.bottom)
            $0.left.bottom.equalToSuperview().inset(10)
        }
           
        let value = UILabel()
        value.font = UIFont.avenirMedium(size: 25)
        value.textColor = .white
        value.text = coin.displayableAmount
        parentView.addSubview(value)
        
        value.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(10)
            $0.left.greaterThanOrEqualTo(currencySign.snp.left)
        }
        
        let convertedToUSD = UILabel()
        convertedToUSD.font = UIFont.avenirMedium(size: 15)
        convertedToUSD.textColor = .lightGray
        parentView.addSubview(convertedToUSD)
        
        convertedToUSD.snp.makeConstraints {
            $0.top.equalTo(value.snp.bottom)
            $0.right.bottom.equalToSuperview().inset(10)
        }
        
        /// we fetch converted value upon cell configuration
        /// in the event that it is reused before the request ends
        /// we reinit cancellables to cancel request
        viewModel.getConvertedValue(of: coin)
            .receive(on: DispatchQueue.main)
            .replaceError(with: 0)
            .sink(receiveValue: { value in
                /// Dont need to display USD converted to USD
                let stringValue = Formatter.currency(val: value, symbol: "$")
                convertedToUSD.text = coin.currency == "USD" ? "" : stringValue
                viewModel.updateTotalBalance(originalCurrency: coin.currency,
                                             amount: value)
            })
            .store(in: &cancellables)
        
    }
}
