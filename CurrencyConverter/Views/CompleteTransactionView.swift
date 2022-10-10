//
//  CompleteTransactionView.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/10/22.
//

import UIKit

class CompleteTransactionView: UIView {
    private let convertedFrom: Converted
    private let convertedTo: Converted
    private let commision: Double
    var tapAction: (() -> Void)?
    
    init(convertedFrom: Converted, convertedTo: Converted, commision: Double) {
        self.convertedFrom = convertedFrom
        self.convertedTo = convertedTo
        self.commision = commision
        
        super.init(frame: .zero)
        setDisplay()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDisplay() {
        backgroundColor = .black.withAlphaComponent(0.4)
        let container = UIFactory.createContainer()
        container.backgroundColor = .appDarkblue
        container.clipsToBounds = true
        
        addSubview(container)
        container.snp.makeConstraints{ make in
            make.height.equalToSuperview().multipliedBy(0.5)
            make.width.equalToSuperview().multipliedBy(0.85)
            make.center.equalToSuperview()
        }
        
        let blackView = UIView()
        blackView.backgroundColor = .black.withAlphaComponent(0.8)
        container.addSubview(blackView)
        blackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(60)
        }
        
        let title = UIFactory.createLabel(text: CURRENCY_CONVERTED, size: 26, color: .white, type: .bold)
        title.textAlignment = .center
        container.addSubview(title)
        title.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview().inset(15)
        }
        
        let commisionCost = "\(String(format: "%.2f", commision)) \(convertedFrom.currency)"
        let deductToWallet = UIFactory.createLabel(text: CONVERTED_MSG, size: 18, color: .gray)
        deductToWallet.textAlignment = .left
        container.addSubview(deductToWallet)
        deductToWallet.snp.makeConstraints { make in
            make.top.equalTo(title.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
        }
        
        let deducted = UIFactory.createLabel(text: convertedFrom.amount + " " +  convertedFrom.currency,
                                             size: 32,
                                             color: .white,
                                             type: .number)
        deducted.textAlignment = .center
        container.addSubview(deducted)
        deducted.snp.makeConstraints { make in
            make.top.equalTo(deductToWallet.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        let addedToWallet = UIFactory.createLabel(text: CONVERTED_TO, size: 18, color: .gray)
        addedToWallet.textAlignment = .left
        container.addSubview(addedToWallet)
        addedToWallet.snp.makeConstraints { make in
            make.top.equalTo(deducted.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
        }
        
        let added = UIFactory.createLabel(text: convertedTo.amount + " " + convertedTo.currency,
                                          size: 32,
                                          color: .green,
                                          type: .number)
        added.textAlignment = .center
        container.addSubview(added)
        added.snp.makeConstraints { make in
            make.top.equalTo(addedToWallet.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
         
        let comissionLabel = UIFactory.createLabel(text: COMISSION_FEE + " " + commisionCost,
                                                   size: 18,
                                                   color: .white,
                                                   type: .medium)
        comissionLabel.textAlignment = .left
        container.addSubview(comissionLabel)
        comissionLabel.snp.makeConstraints { make in
            make.top.equalTo(added.snp.bottom).offset(25)
            make.centerX.equalToSuperview()
        }
        
        
        let button = UIFactory.createActionButton(title: BACKTOWALLET)
        button.addTarget(self, action: #selector(didTapAction), for: .touchUpInside)
        button.isEnabled = true
        container.addSubview(button)
        button.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview().inset(15)
            make.height.equalTo(40)
        }
    }
    
    @objc func didTapAction() {
        tapAction?()
    }
}
