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
    
    lazy var totalLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirMedium(size: 25)
        label.textColor = .lightGray
        label.text = "Total Balance"
        return label
    }()
    
    lazy var totalAmount: UILabel = {
        let label = UILabel()
        label.font = UIFont.avenirBold(size: 40)
        label.textColor = .white
        return label
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor(named: "backgroundColor")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    init(viewModel: WalletViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        
        setupDisplay()
        setupObservers()
    }
     
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WalletViewController {
    func setupDisplay() {
        navigationController?.title = viewModel.title
        view.backgroundColor = UIColor(named: "backgroundColor")
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        
        stackView
            .snp
            .makeConstraints{ make in
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
                make.left.right.equalToSuperview().offset(15)
            }
        
        stackView.addArrangedSubview(totalLabel)
        stackView.addArrangedSubview(totalAmount)
          
        totalAmount.text = viewModel.totalMoney
        
        view.addSubview(tableView)
        tableView.register(CoinTableViewCell.self, forCellReuseIdentifier: CoinTableViewCell.identifier)
        tableView.snp.makeConstraints{ make in
            make.top.equalTo(stackView.snp.bottom).offset(25)
            make.left.bottom.right.equalToSuperview().inset(10)
        }
        
    }
    
    func setupObservers() {
        viewModel.$coins
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
}

extension WalletViewController: UITableViewDelegate {}

extension WalletViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.coins.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CoinTableViewCell.identifier,
                                                 for: indexPath) as? CoinTableViewCell
        
        let coin = viewModel.coins[indexPath.row]
        cell?.configure(coin: coin, viewModel: viewModel)
        return cell ?? UITableViewCell()
    }
}
