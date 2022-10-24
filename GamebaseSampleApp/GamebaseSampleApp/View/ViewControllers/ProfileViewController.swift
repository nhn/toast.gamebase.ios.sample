//
//  ProfileViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/01.
//

import Foundation
import UIKit
import SnapKit

final class ProfileViewController: UIViewController {
    private let viewModel = ProfileViewModel()
    
    @IBOutlet private weak var imageView: UIImageView!
    
    private let scrollView: UIScrollView = {
        let view = UIScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let stackView: UIStackView = {
        let view = UIStackView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.spacing = 20
        view.axis = .vertical
        view.alignment = .fill
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        setupContents()
    }
}

// MARK: - setup
extension ProfileViewController {
    private func setupLayout() {
        imageView.layer.cornerRadius = imageView.bounds.size.width / 2.0
        
        addProfileShadowView()
        
        view.addSubview(scrollView)
        scrollView.addSubview(stackView)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(30)
            make.right.left.bottom.equalToSuperview().inset(20)
        }
        
        stackView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
    }
    
    private func addProfileShadowView() {
        let shadowView = UIView()
        shadowView.layer.shadowColor = UIColor.gray.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 5, height: 5)
        shadowView.layer.shadowOpacity = 0.7
        shadowView.layer.shadowRadius = 5.0
        
        view.addSubview(shadowView)
        shadowView.addSubview(imageView)
    }
    
    private func setupContents() {
        let profile = viewModel.getProfile()
        
        stackView.addArrangedSubviews([
            ProfileDetailView(title: "Gamebase UserID", content: profile.userID ?? ""),
            ProfileDetailView(title: "Gamebase AccessToken", content: profile.accessToken ?? ""),
            ProfileDetailView(title: "Last LoggedIn Provider", content: profile.lastLoggedInProvider ?? ""),
            ProfileDetailView(title: "Auth Mapping List", contents: profile.authMappingList ?? [])
        ])
    }
}
