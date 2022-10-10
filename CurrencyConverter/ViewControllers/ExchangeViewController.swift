//
//  ExchangeViewController.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import UIKit
import Combine

class ExchangeViewController: UIViewController {
    let viewModel: ExchangeViewModel
    
    /// Header view
    lazy var header: ExchangeHeader = {
        return ExchangeHeader(delegate: self)
    }()
    
    lazy var inputAmountField: UITextField  = {
        return UIFactory.createTextField(size: 30, color: .gray)
    }()
    
    lazy var exchangeButton: UIButton = {
        let button = UIFactory.createActionButton(title: CONFIRM)
        button.addTarget(self, action: #selector(confirmExchange), for: .touchUpInside)
        return button
    }()
    
    lazy var promoInformation: UILabel = {
        return UIFactory.createLabel(text: "", size: 12, color: .gray, type: .number)
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    init(viewModel: ExchangeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplay()
    }
    
    func setupDisplay() { 
        view.backgroundColor = .appDarkblue
        
        let titleLabel = UIFactory.createLabel(text: EXCHANGE, size: 25, color: .lightGray)
        view.addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
        }
         
        view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.left.right.equalToSuperview().inset(15)
            make.height.equalTo(120)
        }
        
        view.addSubview(promoInformation)
        promoInformation.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(2)
            make.right.equalToSuperview().inset(15)
        }
         
        let textFieldContainer = UIFactory.createContainer()
        textFieldContainer.clipsToBounds = true
        view.addSubview(textFieldContainer)
        textFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(promoInformation.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(15)
        }
        
        let amountContainer = UIView()
        amountContainer.backgroundColor = .black.withAlphaComponent(0.2)
        amountContainer.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainer.addSubview(amountContainer)
        amountContainer.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(1)
            make.width.equalTo(100)
        }
        
        let amountLabel = UIFactory.createLabel(text: "Amount", size: 20, color: .gray, type: .medium)
        amountContainer.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { $0.centerX.centerY.equalToSuperview() }
         
        // set by default to 0
        inputAmountField.keyboardType = .numberPad
        inputAmountField.textAlignment = .left
        inputAmountField.minimumFontSize = 5
        inputAmountField.clipsToBounds = true
        inputAmountField.delegate = self
        textFieldContainer.addSubview(inputAmountField)
        inputAmountField.snp.makeConstraints { make in
            make.left.equalTo(amountContainer.snp.right).offset(10)
            make.top.right.bottom.equalToSuperview().inset(10)
        }
        
        inputAmountField.becomeFirstResponder()
         
        view.addSubview(exchangeButton)
        exchangeButton.snp.makeConstraints { make in
            make.top.equalTo(textFieldContainer.snp.bottom).offset(10)
            make.left.equalTo(textFieldContainer.snp.left)
            make.right.equalTo(textFieldContainer.snp.right)
            make.height.equalTo(40)
        }
        
        setObservers()
    }
    
    //MARK: Bindings
    func setObservers() {
        viewModel.$fromCurrency
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in
                guard let self = self else { return }
                
                self.header.fromButton.setTitle($0.currency, for: .normal)
                self.header.fromLabel.text = $0.name
                
                let balance = String(format: "%.2f", self.viewModel.currentBalance()).currencyFormatting()
                self.header.availableBalance.text = "Balance: \(balance)"
            }
            .store(in: &cancellables)
        
        viewModel.$toCurrency
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in
                self?.header.toButton.setTitle($0.currency, for: .normal)
                self?.header.toLabel.text = $0.name
            }
            .store(in: &cancellables)
        
        viewModel.$toValue
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                let string = String(value)
                let symbol = self.viewModel.toCurrency?.symbol ?? ""
                let (formatted, _) = self.viewModel.formattedValue(symbol: symbol, field: string)
                
                /// set the same display of amount to header sell label
                let positiveDisplay = "+ " + formatted
                self.header.buyValueLabel.text = value == 0 ? "- - - -" : positiveDisplay
            }
            .store(in: &cancellables)
        
        viewModel.$conversionDisplay
            .receive(on: DispatchQueue.main)
            .compactMap{ $0 }
            .assign(to: \.text, on: promoInformation)
            .store(in: &cancellables)
         
        viewModel.$observableError
            .receive(on: DispatchQueue.main)
            .sink{ [weak self] errorReceived in
                if let error = errorReceived as? ExchangeError {
                    let alert = UIFactory.createAlert(title: error.title, message: error.message) { _ in
                        self?.navigationController?.popViewController(animated: true)
                    }
                    
                    self?.navigationController?.present(alert, animated: true)
                }
            }
            .store(in: &cancellables)
        
        Publishers.CombineLatest(viewModel.$fromValue, viewModel.$toValue)
            .receive(on: DispatchQueue.main)
            .compactMap { $0 > 0 && $1 > 0 }
            .sink(receiveValue: { isComplete in
                self.exchangeButton.isEnabled = isComplete
                self.exchangeButton.alpha = isComplete ? 1 : 0.4
            })
            .store(in: &cancellables)
 
    }
    
    @objc func confirmExchange() {
        if let error = viewModel.errorOnExchange() {
            let alert = UIFactory.createAlert(title: error.title, message: error.message)
            navigationController?.present(alert, animated: true)
        } else {
            showCompleteDisplay()
            viewModel.proceedExchange()
        }
    }
    
    func showCompleteDisplay() {
        guard let fromCurrency = viewModel.fromCurrency?.currency,
              let toCurrency = viewModel.toCurrency?.currency
        else {
            return
        }
        inputAmountField.resignFirstResponder()
        
        let deductedAmount = String(format: "%.2f", viewModel.fromValue)
        let convertedFrom = Converted(amount: deductedAmount,
                                      currency: fromCurrency)
        
        
        let convertedAmount = String(format: "%.2f", viewModel.toValue)
        let convertedTo = Converted(amount: convertedAmount,
                                    currency: toCurrency)
        let comission = viewModel.exchangeCost()
        
        let completedView = CompleteTransactionView(convertedFrom: convertedFrom,
                                                    convertedTo: convertedTo,
                                                    commision: comission)
        completedView.tapAction = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        
        view.addSubview(completedView)
        completedView.snp.makeConstraints { make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}

extension ExchangeViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
         
        if textField == inputAmountField {
            /// Update Amount Input field with currency format
            textField.text = viewModel.formattedInput(text: textField.text ?? "",
                                                      replacement: string,
                                                      range: range)
            
            if let fromCurrency = viewModel.fromCurrency {
                let symbol = fromCurrency.symbol
                let (_, value) = viewModel.formattedValue(symbol: symbol, field: textField.text ?? "")
                self.viewModel.inputChanged(value.doubleValue)
                
                /// set the same display of amount to header sell label
                /// show negative display for BUY
                let negativeDisplay = "- \(self.inputAmountField.text ?? "")"
                self.header.sellValueLabel.text = value.doubleValue == 0 ? "- - - -"
                                                  : negativeDisplay
            }
            
            return false
        } else {
            return true
        }
    }
}

extension ExchangeViewController: ExchangeHeaderDelegate {
    func changedSellCurrency() {
        showCurrencySelection(currencies: viewModel.userWallet.international) { [weak self] selected in
            self?.viewModel.fromCurrency = selected
        }
    }
    
    func changedBuyCurrency() {
        showCurrencySelection(currencies: viewModel.currencies) { [weak self] selected in
            self?.viewModel.toCurrency = selected
        }
    }
    
    private func showCurrencySelection(currencies: [Currency], didSelect: @escaping ((Currency) -> Void)) {
        let currencyList = CurrencySelectionViewController(currencies: currencies)
        currencyList.didSelect = didSelect
        navigationController?.pushViewController(currencyList, animated: true)
        clearValues()
    }
    
    private func clearValues() {
        inputAmountField.text = ""
        header.sellValueLabel.text = ""
        header.buyValueLabel.text = ""
    }
}
