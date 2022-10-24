//
//  AppPermissionDetailView.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/07.
//

import UIKit
import SnapKit

final class AppPermissionDetailView: UIView {
    private let permissionInfo: AppPermissionInfo
    
    private lazy var bgCircleView: UIView = {
        let view = UIView(frame: .init(x: 0, y: 0, width: 60, height: 60))
        view.backgroundColor = .lightGray
        view.layer.opacity = 0.2
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = view.layer.bounds.width / 2
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: permissionInfo.imageName)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = self.permissionInfo.title
        label.font = UIFont.systemFont(ofSize: 15, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = permissionInfo.description
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.gray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    init(_ permissionInfo: AppPermissionInfo) {
        self.permissionInfo = permissionInfo
        super.init(frame: .zero)
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - setup
private extension AppPermissionDetailView {
    func setupLayout() {
        self.addSubview(bgCircleView)
        self.addSubview(imageView)
        self.addSubview(stackView)
        
        bgCircleView.snp.makeConstraints { make in
            make.left.equalTo(self.snp.left)
            make.centerY.equalTo(self)
            make.verticalEdges.equalTo(self)
            make.width.height.equalTo(60)
        }
        
        imageView.snp.makeConstraints { make in
            make.centerX.centerY.equalTo(bgCircleView)
            make.width.height.equalTo(bgCircleView).multipliedBy(0.5)
        }
        
        stackView.snp.makeConstraints { make in
            make.left.equalTo(bgCircleView.snp.right).offset(20)
            make.right.equalTo(self)
            make.verticalEdges.equalTo(self)
        }
        
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(descriptionLabel)
        
        descriptionLabel.snp.makeConstraints { make in
            make.width.equalTo(stackView)
        }
    }
}
