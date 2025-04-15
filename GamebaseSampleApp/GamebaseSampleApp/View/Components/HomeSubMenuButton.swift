//
//  HomeSubMenuButton.swift
//  GamebaseSampleApp
//
//  Created by NHN on 4/14/25.
//

import UIKit
import SnapKit

final class HomeSubMenuButton: UIButton {
    private let image: UIImage?
    private let text: String
    
    private lazy var labelImageView: UIImageView = {
        let imageView = UIImageView(image: self.image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.layer.shadowColor = UIColor.lightGray.cgColor
        imageView.layer.shadowOpacity = 0.7
        imageView.layer.shadowRadius = 1
        imageView.layer.shadowOffset = CGSize(width: 2, height: 2)
        return imageView
    }()
    
    private lazy var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.text = self.text
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12)
        return label
    }()
    
    init(image: UIImage?, text: String) {
        self.image = image
        self.text = text
        super.init(frame: .zero)
        self.setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        self.addSubview(self.labelImageView)
        self.addSubview(self.label)
        
        self.labelImageView.snp.makeConstraints { make in
            make.width.equalTo(self.snp.width).multipliedBy(0.6)
            make.height.equalTo(self.labelImageView.snp.width)
            make.centerX.equalTo(self)
            make.top.equalTo(self)
        }
        
        self.label.snp.makeConstraints { make in
            make.centerX.equalTo(self.labelImageView)
            make.top.equalTo(self.labelImageView.snp.bottom).offset(2)
            make.bottom.equalTo(self)
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
                self.alpha = self.isHighlighted ? 0.5 : 1
            }, completion: nil)
        }
    }
}
