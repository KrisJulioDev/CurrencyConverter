//
//  CurrencySelectionViewController.swift
//  CurrencyConverter
//
//  Created by Kris Julio on 10/8/22.
//

import Foundation
import UIKit

class CurrencySelectionViewController: UIViewController {
    let currencies: [Currency]
    var didSelect: ((Currency) -> Void)?
     
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .appDarkblue
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.alwaysBounceVertical = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(CurrencyTableViewCell.self,
                           forCellReuseIdentifier: CurrencyTableViewCell.identifier)
        return tableView
    }()
    
    init(currencies: [Currency]) {
        self.currencies = currencies
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
     
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDisplay()
    }
}

extension CurrencySelectionViewController {
    func setupDisplay() {
        view.backgroundColor = .appDarkblue
        navigationController?.title = "Select Currency"
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

// MARK: Datasource | Delegate
extension CurrencySelectionViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currencies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyTableViewCell.identifier,
                                                 for: indexPath) as? CurrencyTableViewCell
        
        let currency = currencies[indexPath.row]
        cell?.configure(currency: currency)
        return cell ?? UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let currency = currencies[indexPath.row]
        didSelect?(currency)
        navigationController?.popViewController(animated: true)
    }
}
