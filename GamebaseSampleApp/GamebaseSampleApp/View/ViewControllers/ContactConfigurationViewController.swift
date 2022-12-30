//
//  ContactConfigurationViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/07.
//

import Foundation
import RxCocoa
import RxSwift

final class ContactConfigurationViewController: UIViewController {
    static private let storyboardID = "ContactConfiguration"
    static let segueID = "seg\(storyboardID)"
    static let navigationBarTitle = "고객센터 상세 설정"
    
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var openContactButton: UIButton!
    
    private lazy var viewModel: ContactConfigurationViewModel = {
        ContactConfigurationViewModel(viewController: self)
    }()
    private let inputPrepareData = PublishRelay<Void>()
    private let inputOpenContact = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = ContactConfigurationViewController.navigationBarTitle
        self.setupTableView()
        self.bind()
        self.inputPrepareData.accept(())
    }
}

extension ContactConfigurationViewController {
    private func setupTableView() {
        self.viewModel.contactConfigurationItemList
            .bind(to:tableView.rx.items(cellIdentifier: "ContactConfigurationTableViewCellID")) { _, item, cell in
                if #available(iOS 14.0, *) {
                    var content = cell.defaultContentConfiguration()
                    content.text = item.title
                    content.secondaryText = item.subTitle
                    cell.contentConfiguration = content
                } else {
                    cell.textLabel?.text = item.title
                    cell.detailTextLabel?.text = item.subTitle
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func bind() {
        let input = ContactConfigurationViewModel.Input(prepareData: inputPrepareData,
                                                        openContact: inputOpenContact)
        let output = self.viewModel.transform(input: input)
        
        Observable
            .zip(tableView.rx.modelSelected(ContactConfigurationCellItem.self), tableView.rx.itemSelected)
            .bind { [weak self] (item, indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: true)
                item.handler()
            }
            .disposed(by: disposeBag)
        
        self.openContactButton.rx.tap
            .subscribe(with: self) { owner, _ in
                owner.inputOpenContact.accept(())
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)        
    }
}
