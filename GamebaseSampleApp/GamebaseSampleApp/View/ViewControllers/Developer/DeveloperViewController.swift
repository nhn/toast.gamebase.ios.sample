//
//  DeveloperViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/21.
//

import Foundation
import QuickTableViewController
import RxSwift
import RxCocoa
import MBProgressHUD

final class DeveloperViewController: QuickTableViewController {
    private lazy var viewModel: DeveloperViewModel = {
        DeveloperViewModel(viewController: self)
    }()
    private let inputRequestTemporaryWithdrawal = PublishRelay<Void>()
    private let inputCancelTemporaryWithdrawal = PublishRelay<Void>()
    private let inputActivatedPurchases = PublishRelay<Void>()
    private let inputItemListOfNotConsumed = PublishRelay<Void>()
    private let inputRestorePurchase = PublishRelay<Void>()
    private let inputQueryTokenInfo = PublishRelay<Void>()
    private let inputPushConfiguration = PublishRelay<Void>()
    private let inputSendLog = PublishRelay<SendLogInfo>()
    private let inputQueryTerms = PublishRelay<Void>()
    private let inputTermsConfiguration = PublishRelay<Void>()
    private let inputUpdateTerms = PublishRelay<Void>()
    private let inputImageNoticeConfiguration = PublishRelay<Void>()
    private let inputWebViewConfiguration = PublishRelay<Void>()
    private let inputRequestContactURL = PublishRelay<Void>()
    private let inputContactConfiguration = PublishRelay<Void>()
    private var disposeBag = DisposeBag()
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        if #available(iOS 13.0, *) {
            self.tableView = UITableView(frame: .zero, style: .insetGrouped)
        } else {
            self.tableView = UITableView(frame: .zero, style: .grouped)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupContents()
        self.bind()
    }
}

// MARK: - setup
extension DeveloperViewController {
    private func setupContents() {
        tableContents = [
            Section(title: "인증", rows: [
                TapActionRow<CustomTapActionCell>(text: "탈퇴 유예 요청", action: { [weak self] _ in
                    self?.inputRequestTemporaryWithdrawal.accept(())
                }),
                TapActionRow<CustomTapActionCell>(text: "탈퇴 유예 철회", action: { [weak self] _ in
                    self?.inputCancelTemporaryWithdrawal.accept(())
                }),
            ]),
            Section(title: "결제", rows: [
                NavigationRow(text: ReceiptListViewType.activatedPurchases.rawValue, detailText: .none, action: { [weak self] _ in
                    self?.inputActivatedPurchases.accept(())
                }),
                NavigationRow(text: ReceiptListViewType.itemListOfNotConsumed.rawValue, detailText: .none, action: { [weak self] _ in
                    self?.inputItemListOfNotConsumed.accept(())
                }),
                TapActionRow<CustomTapActionCell>(text: "구매 내역 복원", action: { [weak self] _ in
                    self?.inputRestorePurchase.accept(())
                })
            ]),
            Section(title: "푸시", rows: [
                TapActionRow<CustomTapActionCell>(text: "푸시 설정 조회", action: { [weak self] _ in
                    self?.inputQueryTokenInfo.accept(())
                }),
                NavigationRow(text: PushConfigurationViewController.navigationBarTitle, detailText: .none, action: { [weak self] _ in
                    self?.inputPushConfiguration.accept(())
                }),
            ]),
            Section(title: "Logger", rows: [
                TapActionRow<CustomTapActionCell>(text: "Logger 초기화", action: { [weak self] _ in
                    self?.viewModel.initialzeLogger()
                }),
                TapActionRow<CustomTapActionCell>(text: "DEBUG 로그 전송", action: { [weak self] _ in
                    self?.inputSendLog.accept(SendLogInfo(type: .debug, title: "DEBUG 로그 전송"))
                }),
                TapActionRow<CustomTapActionCell>(text: "INFO 로그 전송", action: { [weak self] _ in
                    self?.inputSendLog.accept(SendLogInfo(type: .info, title: "INFO 로그 전송"))
                }),
                TapActionRow<CustomTapActionCell>(text: "WARN 로그 전송", action: { [weak self] _ in
                    self?.inputSendLog.accept(SendLogInfo(type: .warn, title: "WARN 로그 전송"))
                }),
                TapActionRow<CustomTapActionCell>(text: "ERROR 로그 전송", action: { [weak self] _ in
                    self?.inputSendLog.accept(SendLogInfo(type: .error, title: "ERROR 로그 전송"))
                }),
                TapActionRow<CustomTapActionCell>(text: "FATAL 로그 전송", action: { [weak self] _ in
                    self?.inputSendLog.accept(SendLogInfo(type: .fatal, title: "FATAL 로그 전송"))
                }),
            ]),
            Section(title: "약관", rows: [
                TapActionRow<CustomTapActionCell>(text: "약관 정보 조회", action: { [weak self] _ in
                    self?.inputQueryTerms.accept(())
                }),
                NavigationRow(text: TermsConfigurationViewController.navigationBarTitle, detailText: .none, action: { [weak self] _ in
                    self?.inputTermsConfiguration.accept(())
                }),
                NavigationRow(text: UpdateTermsViewController.navigationBarTitle, detailText: .none, action: { [weak self] _ in
                    self?.inputUpdateTerms.accept(())
                })
            ]),
            Section(title: "이미지 공지", rows: [
                TapActionRow<CustomTapActionCell>(text: "이미지 공지 보기", action: { [weak self] _ in
                    self?.viewModel.showImageNotices()
                }),
                NavigationRow(text: ImageNoticeConfigurationViewController.navigationBarTitle, detailText: .none, action: { [weak self] _ in
                    self?.inputImageNoticeConfiguration.accept(())
                })
            ]),
            Section(title: "웹뷰", rows: [
                TapActionRow<CustomTapActionCell>(text: "웹뷰 열기", action: { [weak self] _ in
                    self?.viewModel.showWebView()
                }),
                TapActionRow<CustomTapActionCell>(text: "외부 브라우저 열기", action: { [weak self] _ in
                    self?.viewModel.openWebBrowser()
                }),
                NavigationRow(text: WebViewConfigurationViewController.navigationBarTitle, detailText: .none, action: { [weak self] _ in
                    self?.inputWebViewConfiguration.accept(())
                })
            ]),
            Section(title: "Alert", rows: [
                TapActionRow<CustomTapActionCell>(text: "Alert", action: { [weak self] _ in
                    self?.viewModel.showGamebaseAlert()
                }),
                TapActionRow<CustomTapActionCell>(text: "ActionSheet", action: { [weak self] _ in
                    self?.viewModel.showGamebaseActionSheet()
                }),
                TapActionRow<CustomTapActionCell>(text: "짧은 토스트 메시지", action: { [weak self] _ in
                    self?.viewModel.showGamebaseToastShort()
                }),
                TapActionRow<CustomTapActionCell>(text: "긴 토스트 메시지", action: { [weak self] _ in
                    self?.viewModel.showGamebaseToastLong()
                })
            ]),
            Section(title: "Analytics", rows: [
                TapActionRow<CustomTapActionCell>(text: "유저 레벨 정보 설정", action: { [weak self] _ in
                    self?.viewModel.setGameUserData()
                }),
                TapActionRow<CustomTapActionCell>(text: "유저 레벨업 정보 설정", action: { [weak self] _ in
                    self?.viewModel.traceLevelUpData()
                })
            ]),
            Section(title: "고객센터", rows: [
                TapActionRow<CustomTapActionCell>(text: "고객센터 URL 조회", action: { [weak self] _ in
                    self?.inputRequestContactURL.accept(())
                }),
                NavigationRow(text: ContactConfigurationViewController.navigationBarTitle, detailText: .none, action: { [weak self] _ in
                    self?.inputContactConfiguration.accept(())
                })
            ]),
            Section(title: "ETC", rows: [
                NavigationRow(text: "OS 버전", detailText: .value1(self.viewModel.osVersion())),
                
                TapActionRow<CustomTapActionCell>(text: "IDFA 조회", action: { [weak self] _ in
                    UIViewController.showAlert(title: "IDFA",
                                               message: self?.viewModel.getIDFA())
                }),
                TapActionRow<CustomTapActionCell>(text: "Device Language 조회", action: { [weak self] _ in
                    UIViewController.showAlert(title: "Device Language",
                                               message: self?.viewModel.getDeviceLanguage())
                }),
                TapActionRow<CustomTapActionCell>(text: "Device Country Code 조회", action: { [weak self] _ in
                    UIViewController.showAlert(title: "Device Country Code",
                                               message: self?.viewModel.getDeviceCountryCode())
                }),                
                TapActionRow<CustomTapActionCell>(text: "Display Language 조회", action: { [weak self] _ in
                    UIViewController.showAlert(title: "Display Language",
                                               message: self?.viewModel.getDisplayLanguage())
                }),
            ])
        ]
    }
    
    private func bind() {
        let input = DeveloperViewModel.Input(requestTemporaryWithdrawal: inputRequestTemporaryWithdrawal,
                                             cancelTemporaryWithdrawal: inputCancelTemporaryWithdrawal,
                                             activatedPurchases: inputActivatedPurchases,
                                             itemListOfNotConsumed: inputItemListOfNotConsumed,
                                             restorePurchase: inputRestorePurchase,
                                             queryTokenInfo: inputQueryTokenInfo,
                                             pushConfiguration: inputPushConfiguration,
                                             sendLog: inputSendLog,
                                             queryTerms: inputQueryTerms,
                                             termsConfiguration: inputTermsConfiguration,
                                             updateTerms: inputUpdateTerms,
                                             imageNoticeConfiguration: inputImageNoticeConfiguration,
                                             webViewConfiguration: inputWebViewConfiguration,
                                             requestContactURL: inputRequestContactURL,
                                             contactConfiguration: inputContactConfiguration)
        let output = self.viewModel.transform(input: input)
        
        output.isLoading
            .emit(with: self) { owner, isLoading in
                MBProgressHUD.showProgress(isLoading, to: owner.view, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.routeToChildView
            .emit(with: self) { owner, segID in
                owner.performSegue(withIdentifier: segID, sender: nil)
            }
            .disposed(by: disposeBag)
        
        output.routeToReceiptView
            .emit(with: self) { owner, type in
                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let receiptListViewController = storyBoard.instantiateViewController(withIdentifier: ReceiptListViewController.storyboardID) as! ReceiptListViewController
                receiptListViewController.viewType = type
                owner.navigationController?.pushViewController(receiptListViewController, animated: true)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }
}
