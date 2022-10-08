//
//  WalletViewController.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import UIKit
import SnapKit
import Combine

class WalletViewController: UIViewController {
    private var cancellables: Set<AnyCancellable> = []
    let viewModel: WalletViewModel
     
    lazy var totalAmount: UILabel = {
        return UIFactory.createLabel(text: TOTAL_BALANCE,
                                   size: 40,
                                   color: .appOrange,
                                   type: .bold)
    }()
    
    lazy var convertButton: UIButton = {
        let button = UIButton()
        button.setTitle(EXCHANGE_CURRENCY, for: .normal)
        button.titleLabel?.font = UIFont.avenirMedium(size: 20)
        button.backgroundColor = .appOrange
        button.setTitleColor(.appDarkblue, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(exchangeDidTap), for: .touchUpInside)
        return button
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .appDarkblue
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CoinTableViewCell.self,
                           forCellReuseIdentifier: CoinTableViewCell.identifier)
        return tableView
    }()
    
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplay()
        setupObservers()
    }
}

extension WalletViewController {
    func setupDisplay() {
        view.backgroundColor = .appDarkblue
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        stackView.snp.makeConstraints{ make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview().inset(15)
        }
        
        let totalLabel = UIFactory.createLabel(text: TOTAL_BALANCE,
                                             size: 25,
                                             color: .lightGray,
                                             type: .medium)
         
        let tableTitle = UIFactory.createLabel(text: WALLET,
                                             size: 25,
                                             color: .lightGray,
                                             type: .medium)
        

        stackView.addArrangedSubview(totalLabel)
        stackView.addArrangedSubview(totalAmount)
        
        view.addSubview(tableTitle)
        view.addSubview(tableView)
        
        let divider = UIView()
        divider.backgroundColor = .black.withAlphaComponent(0.5)
        divider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(divider)
        
        divider.snp.makeConstraints { make in
            make.top.equalTo(totalAmount.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(4)
        }
        
        tableTitle.snp.makeConstraints{ make in
            make.top.equalTo(divider.snp.bottom).offset(10)
            make.left.equalToSuperview().inset(10)
        }
        
        tableView.snp.makeConstraints{ make in
            make.top.equalTo(tableTitle.snp.bottom).offset(10)
            make.left.right.equalToSuperview().inset(10)
        }
        
        view.addSubview(convertButton)
        convertButton.snp.makeConstraints{ make in
            make.height.equalTo(40)
            make.left.right.equalToSuperview().inset(25)
            make.top.equalTo(tableView.snp.bottom).offset(10)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(10)
        }
    }
    
    func setupObservers() {
        viewModel.$displayableCurrency
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        
        viewModel.$totalMoney
            .receive(on: DispatchQueue.main)
            .compactMap { Formatter.currency(val: $0, symbol: "$")}
            .assign(to: \.text, on: totalAmount)
            .store(in: &cancellables)
    }

    @objc func exchangeDidTap() {
        let viewModel = ExchangeViewModel(currencies: viewModel.currencies)
        let exchangeViewController = ExchangeViewController(viewModel: viewModel)
        navigationController?.pushViewController(exchangeViewController, animated: true)
    }
}

// MARK: Datasource
extension WalletViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.displayableCurrency.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinTableViewCell.identifier,
                                                 for: indexPath) as? CoinTableViewCell
        
        let coin = viewModel.displayableCurrency[indexPath.row]
        cell?.configure(coin: coin, viewModel: viewModel)
        return cell ?? UITableViewCell()
    }
}
