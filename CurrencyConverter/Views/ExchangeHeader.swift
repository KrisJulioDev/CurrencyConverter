//
//  ExchangeHeader.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/9/22.
//

import UIKit

@objc
protocol ExchangeHeaderDelegate {
    func changedSellCurrency()
    func changedBuyCurrency()
}

class ExchangeHeader: UIView {
    var delegate: ExchangeHeaderDelegate
    
    let fromButton = UIButton()
    let toButton = UIButton()
    
    var fromLabel = UIFactory.createLabel(text: "", size: 13, color: .gray)
    var toLabel = UIFactory.createLabel(text: "", size: 13, color: .gray)
    
    let sellValueLabel = UIFactory.createLabel(text: "", size: 24, color: .red, type: .number)
    let buyValueLabel = UIFactory.createLabel(text: "", size: 24, color: .green, type: .number)
    
    init(delegate: ExchangeHeaderDelegate) {
        self.delegate = delegate
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        let container = UIFactory.createContainer()
        addSubview(container)
        
        container.snp.makeConstraints{ $0.edges.equalToSuperview() }
        
        // Conversion of currencies display
        let anchorDivider = UIView()
        anchorDivider.backgroundColor = .clear
        anchorDivider.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(anchorDivider)
        
        anchorDivider.snp.makeConstraints { make in
            make.centerY.left.right.equalToSuperview()
            make.height.equalTo(3)
        }
        
        let from = UIFactory.createLabel(text: SELL, size: 22, color: .gray)
        container.addSubview(from)
        
        from.snp.makeConstraints { make in
            make.bottom.equalTo(anchorDivider.snp.top).offset(-12)
            make.left.equalToSuperview().inset(15)
            make.width.equalTo(60)
        }
        
        let to = UIFactory.createLabel(text: BUY, size: 22, color: .gray)
        container.addSubview(to)
        
        to.snp.makeConstraints { make in
            make.top.equalTo(anchorDivider.snp.bottom).offset(7)
            make.left.equalToSuperview().inset(15)
            make.width.equalTo(60)
        }
        
        fromButton.titleLabel?.font = UIFont.avenirMedium(size: 22)
        fromButton.backgroundColor = .clear
        fromButton.setTitleColor(.appOrange, for: .normal)
        fromButton.setTitleColor(.gray, for: .highlighted)
        fromButton.layer.cornerRadius = 5
        fromButton.translatesAutoresizingMaskIntoConstraints = false
        fromButton.addTarget(delegate, action: #selector(delegate.changedSellCurrency), for: .touchUpInside)
        container.addSubview(fromButton)
        
        fromButton.snp.makeConstraints { make in
            make.left.equalTo(from.snp.right).offset(5)
            make.centerY.equalTo(from.snp.centerY)
        }
         
        container.addSubview(fromLabel)
        fromLabel.snp.makeConstraints { make in
            make.left.equalTo(fromButton.snp.left)
            make.top.equalTo(fromButton.snp.bottom).offset(-10)
        }
        
        // we display second currency from the data for to: value
        toButton.setTitleColor(.appOrange, for: .normal)
        toButton.setTitleColor(.gray, for: .highlighted)
        toButton.titleLabel?.font = UIFont.avenirMedium(size: 22)
        toButton.backgroundColor = .clear
        toButton.layer.cornerRadius = 5
        toButton.translatesAutoresizingMaskIntoConstraints = false
        toButton.addTarget(delegate, action: #selector(delegate.changedBuyCurrency), for: .touchUpInside)
        
        container.addSubview(toButton)
        
        toButton.snp.makeConstraints { make in
            make.left.equalTo(to.snp.right).offset(5)
            make.centerY.equalTo(to.snp.centerY)
        }
         
        container.addSubview(toLabel)
        toLabel.snp.makeConstraints { make in
            make.left.equalTo(toButton.snp.left)
            make.top.equalTo(toButton.snp.bottom).offset(-10)
        }
        
        //MARK: Dynamic value of currency
        container.addSubview(sellValueLabel)
        sellValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(fromButton.snp.centerY)
            make.left.greaterThanOrEqualTo(fromButton.snp.right).offset(5)
            make.right.equalToSuperview().inset(15)
        }
        
        container.addSubview(buyValueLabel)
        buyValueLabel.snp.makeConstraints { make in
            make.centerY.equalTo(toButton.snp.centerY)
            make.left.greaterThanOrEqualTo(toButton.snp.right).offset(5)
            make.right.equalToSuperview().inset(15)
        }
    }
}
