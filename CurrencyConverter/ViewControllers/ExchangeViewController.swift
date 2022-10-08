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
    
    let fromButton = UIButton()
    var fromLabel = UILabel()
    let toButton = UIButton()
    var toLabel = UILabel()
    
    lazy var inputAmountField: UITextField  = {
        return UIFactory.createTextField(size: 30, color: .appOrange)
    }()
    
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var inputFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
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
         
        let container = UIFactory.createContainer()
        view.addSubview(container)
        
        container.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(15)
            make.top.equalTo(titleLabel.snp.bottom).offset(15)
            make.height.equalTo(120)
        }
        
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
        fromButton.addTarget(self, action: #selector(changeCurrency(button:)), for: .touchUpInside)
        container.addSubview(fromButton)
        
        fromButton.snp.makeConstraints { make in
            make.left.equalTo(from.snp.right).offset(5)
            make.centerY.equalTo(from.snp.centerY)
        }
        
        fromLabel = UIFactory.createLabel(text: "", size: 13, color: .gray)
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
        toButton.addTarget(self, action: #selector(changeCurrency(button:)), for: .touchUpInside)
        
        container.addSubview(toButton)
        
        toButton.snp.makeConstraints { make in
            make.left.equalTo(to.snp.right).offset(5)
            make.centerY.equalTo(to.snp.centerY)
        }
        
        toLabel = UIFactory.createLabel(text: "", size: 13, color: .gray)
        container.addSubview(toLabel)
        toLabel.snp.makeConstraints { make in
            make.left.equalTo(toButton.snp.left)
            make.top.equalTo(toButton.snp.bottom).offset(-10)
        }
        
        let textFieldContainer = UIFactory.createContainer()
        textFieldContainer.clipsToBounds = true
        view.addSubview(textFieldContainer)
        textFieldContainer.snp.makeConstraints { make in
            make.top.equalTo(container.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(15)
        }
        
        let amountContainer = UIView()
        amountContainer.backgroundColor = .black.withAlphaComponent(0.2)
        amountContainer.translatesAutoresizingMaskIntoConstraints = false
        textFieldContainer.addSubview(amountContainer)
        amountContainer.snp.makeConstraints { make in
            make.top.left.bottom.equalToSuperview().inset(1)
        }
        
        let amountLabel = UIFactory.createLabel(text: "Amount", size: 20, color: .gray, type: .medium)
        amountContainer.addSubview(amountLabel)
        amountLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(10) }
         
        inputAmountField.keyboardType = .numberPad
        inputAmountField.textAlignment = .right
        textFieldContainer.addSubview(inputAmountField)
        inputAmountField.snp.makeConstraints { make in
            make.left.equalTo(amountContainer.snp.left).offset(10)
            make.top.right.bottom.equalToSuperview().inset(10)
        }
        
        inputAmountField.becomeFirstResponder()
        
        setObservers()
    }
    
    func setObservers() {
        viewModel.$fromCurrency
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in
                self?.fromButton.setTitle($0.currency, for: .normal)
                self?.fromLabel.text = $0.name
            }
            .store(in: &cancellables)
        
        viewModel.$toCurrency
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .sink { [weak self] in
                self?.toButton.setTitle($0.currency, for: .normal)
                self?.toLabel.text = $0.name
            }
            .store(in: &cancellables)
        
        NotificationCenter.default
            .publisher(for: UITextField.textDidChangeNotification, object: inputAmountField)
            .sink(receiveValue: { [weak self] result in
                guard let self = self else {
                    return
                }
                
                if let textField = result.object as? UITextField {
                    if let field = textField.text {
                        let symbol = self.viewModel.fromCurrency?.symbol ?? ""
                        let cleanNumbers = field
                            /// remove commas
                            .replacingOccurrences(of: self.inputFormatter.groupingSeparator, with: "")
                            /// remove symbol
                            .replacingOccurrences(of: symbol, with: "")
                        
                        if let numberWithoutGroupingSeparator = self.inputFormatter.number(from: cleanNumbers),
                           let formattedText = self.inputFormatter.string(from: numberWithoutGroupingSeparator) {
                            self.inputAmountField.text = symbol + formattedText
                        }
                    }
                }
            })
            .store(in: &cancellables)
    }
    
    @objc func changeCurrency(button: UIButton) {
        let currencyList = CurrencySelectionViewController(currencies: viewModel.currencies)
        currencyList.didSelect = { [weak self] selected in
            if button == self?.fromButton {
                self?.viewModel.fromCurrency = selected
            } else {
                self?.viewModel.toCurrency = selected
            }
        }
        inputAmountField.text = ""
        navigationController?.pushViewController(currencyList, animated: true)
    }
}
