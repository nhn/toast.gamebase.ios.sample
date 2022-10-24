//
//  ProfileDetailView.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/28.
//

import UIKit

final class ProfileDetailView: UIView {
    static private let nibName = "ProfileDetailView"
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        loadXib()
    }
    
    init(title: String, content: String) {
        super.init(frame: .zero)
        loadXib()
        setupContents(title: title, contents: [content])
    }
    
    init(title: String, contents: [String]) {
        super.init(frame: .zero)
        loadXib()
        setupContents(title: title, contents: contents)
    }
}

// MARK: - setup
extension ProfileDetailView {
    private func loadXib() {
        guard let view = Bundle.main.loadNibNamed(ProfileDetailView.nibName, owner: self, options: nil)?.first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        addSubview(view)
    }
    
    private func setupContents(title: String, contents: [String]) {
        titleLabel.text = title

        let labels = contents.map({ (content: String) -> UILabel in
            let label = UILabel()
            label.text = content
            label.numberOfLines = 2
            if #available(iOS 13.0, *) {
                label.textColor = .secondaryLabel
            } else {
                label.textColor = .darkGray
            }
            return label
        })
        
        stackView.addArrangedSubviews(labels)
    }
}
