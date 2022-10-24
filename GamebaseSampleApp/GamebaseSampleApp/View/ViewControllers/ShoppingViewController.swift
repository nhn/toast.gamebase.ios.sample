//
//  StoreViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/24.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

final class ShoppingViewController: UIViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyLabel: UILabel!
    
    private lazy var viewModel: ShoppingViewModel = {
        ShoppingViewModel(viewController: self)
    }()
    private let inputPrepareShopping = PublishRelay<Void>()
    private let inputGetPurchasableItemList = PublishRelay<Void>()
    private let inputTryToPurchase = PublishRelay<String>()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.bind()
        self.inputPrepareShopping.accept(())
    }
}

// MARK: - setup
extension ShoppingViewController {
    private func setupTableView() {
        registerTableViewCells()
        
        viewModel.purchasableItemList
            .bind(to: tableView.rx.items(cellIdentifier: ShoppingTableViewCell.cellID, cellType: ShoppingTableViewCell.self)) { _, cellModel, cell in
                cell.bind(cellModel: cellModel)
            }
            .disposed(by: disposeBag)
    }
    
    private func registerTableViewCells() {
        let shoppingTableViewCell = UINib(nibName: ShoppingTableViewCell.nibName, bundle: nil)
        tableView.register(shoppingTableViewCell, forCellReuseIdentifier: ShoppingTableViewCell.cellID)
    }
    
    private func bind() {        
        let input = ShoppingViewModel.Input(prepareShopping: inputPrepareShopping,
                                            getPurchasableItemList: inputGetPurchasableItemList,
                                            tryToPurchase: inputTryToPurchase)
    
        let output = viewModel.transform(input: input)
        
        Observable
            .zip(tableView.rx.modelSelected(ShoppingCellModel.self), tableView.rx.itemSelected)
            .bind { [weak self] (item, indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                self?.inputTryToPurchase.accept(item.productId)
            }
            .disposed(by: disposeBag)
        
        output.isLoading
            .emit { [weak self] isLoading in
                guard let self = self else { return }
                MBProgressHUD.showProgress(isLoading, to: self.view, animated: true)
            }
        .disposed(by: disposeBag)
                
        output.showEmptyView
            .emit { [weak self] _ in
                self?.emptyLabel.isHidden = false
                self?.tableView.isHidden = true
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit {
                UIViewController.showAlert(alertInfo: $0)
            }
            .disposed(by: disposeBag)
    }
}
