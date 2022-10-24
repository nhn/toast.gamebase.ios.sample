//
//  ReceiptListViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/18.
//

import UIKit
import RxSwift
import RxCocoa
import MBProgressHUD

class ReceiptListViewController: UIViewController {
    static let storyboardID = "ReceiptList"
    var viewType: ReceiptListViewType = .activatedPurchases
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var emptyLabel: UILabel!
    
    private let viewModel = ReceiptListViewModel()
    private let inputGetReceiptList = PublishRelay<ReceiptListViewType>()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = viewType.rawValue
        self.setupContents()
        self.setupTableView()
        self.bind()
        self.inputGetReceiptList.accept(viewType)
    }
}

// MARK: - setup
extension ReceiptListViewController {
    private func setupContents() {
        switch viewType {
        case .itemListOfNotConsumed:
            self.emptyLabel.text = "미소비 목록이 없습니다."
        case .activatedPurchases:
            self.emptyLabel.text = "구독 목록이 없습니다."
        }
    }
    private func setupTableView() {
        self.viewModel.receiptItemList
            .bind(to:tableView.rx.items(cellIdentifier: "ReceiptListTableViewCellID")) { _, element, cell in
                if #available(iOS 14.0, *) {
                    var content = cell.defaultContentConfiguration()
                    content.text = element
                    cell.contentConfiguration = content
                } else {
                    cell.textLabel?.text = element
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        let input = ReceiptListViewModel.Input(getReceiptItemList: inputGetReceiptList)
        let output = viewModel.transform(input: input)
        
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
            .emit { alertInfo in
                UIViewController.showAlert(alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}
