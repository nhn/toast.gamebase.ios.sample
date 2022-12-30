//
//  TermsConfigurationViewModel.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/10/05.
//

import Foundation
import RxSwift
import RxCocoa
import Gamebase

final class TermsConfigurationViewModel {
    private weak var viewController: UIViewController?
        
    private let showAlert = PublishRelay<AlertInfo>()
    private var disposeBag = DisposeBag()
    
    private let showTermsConfiguration = TCGBTermsConfiguration()
    private let updateTermsConfiguration = TCGBUpdateTermsConfiguration()
    
    init(viewController: UIViewController?) {
        self.viewController = viewController
    }
}

// MARK: - ViewModelType
extension TermsConfigurationViewModel: ViewModelType {
    struct Input {
        let showTermsView: PublishRelay<Void>
    }

    struct Output {
        let showAlert: Signal<AlertInfo>
    }

    func transform(input: Input) -> Output {
        input.showTermsView
            .subscribe(with: self) { owner, _ in
                owner.showTermsView()
            }
            .disposed(by: disposeBag)
        
        return Output(showAlert: showAlert.asSignal())
    }
}

extension TermsConfigurationViewModel {
    func setForceShow(_ forceShow: Bool) {
        showTermsConfiguration.forceShow = forceShow
    }
}

// MARK: - Business logic
extension TermsConfigurationViewModel {
    private func showTermsView() {
        GamebaseAsObservable.showTermsView(configuration: self.showTermsConfiguration, viewController: self.viewController)
            .subscribe(with: self) { owner, dataContainer in
                owner.showAlert.accept(AlertInfo(title: "약관 창 종료 (성공)",
                                                 message: "datContainer => \(dataContainer)"))
            } onError: { owner, error in
                owner.showAlert.accept(AlertInfo(title: "약관 창 종료 (실패)",
                                                 message: "error => \(error.localizedDescription)"))
            }
            .disposed(by: disposeBag)
    }
}
