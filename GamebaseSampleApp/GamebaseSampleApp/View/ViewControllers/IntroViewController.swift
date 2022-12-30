//
//  IntroViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/05.
//

import Foundation
import UIKit
import RxSwift
import RxRelay

final class IntroViewController: UIViewController {
    static private let storyboardID = "Intro"
    static let segueID = "seg\(storyboardID)"
    
    private let viewModel = IntroViewModel.shared
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.bind()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isNavigationBarHidden = false
        disposeBag = DisposeBag()
    }
}

// MARK: - setup
extension IntroViewController {
    private func bind() {
        viewModel.viewController = self
        let prepareToPlay = PublishRelay<Void>()
        
        let input = IntroViewModel.Input(prepareToPlay: prepareToPlay)
        let output = viewModel.transform(input: input)

        output.isAppPermissionAgreed
            .emit(with: self) { owner, isAgreed in
                guard isAgreed == true else {
                    owner.performSegue(withIdentifier: AppPermissionViewController.segueID, sender: nil)
                    return
                }
                
                prepareToPlay.accept(())
            }
            .disposed(by: disposeBag)
                
        output.routeToChildView
            .emit(with: self) { owner, segueID in
                owner.performSegue(withIdentifier: segueID, sender: nil)
            }
            .disposed(by: disposeBag)
        
        output.showAlert
            .emit(with: self) { owner, alertInfo in
                UIViewController.showAlert(above: owner, alertInfo: alertInfo)
            }
            .disposed(by: disposeBag)
    }

}
