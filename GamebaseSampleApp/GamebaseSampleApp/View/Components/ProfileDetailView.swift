//
//  ProfileDetailView.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/28.
//

import UIKit
import Gamebase

final class ProfileDetailView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    private let detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .secondaryLabel
        label.numberOfLines = 2
        label.isUserInteractionEnabled = true
        return label
    }()

    private let copyButton: UIButton = {
        let imageSize = CGSize(width: 17, height: 17)
        let resizedImage = UIGraphicsImageRenderer(size: imageSize).image { _ in
            UIImage(named: "Icons/copy")?.draw(in: CGRect(origin: .zero, size: imageSize))
        }.withRenderingMode(.alwaysTemplate)

        var config = UIButton.Configuration.plain()
        config.image = resizedImage
        config.baseForegroundColor = .secondaryLabel
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 27),
            button.heightAnchor.constraint(equalToConstant: 27)
        ])
        return button
    }()

    init(title: String, content: String, showCopyButton: Bool = true) {
        super.init(frame: .zero)
        setupLayout(showCopyButton: showCopyButton)
        titleLabel.text = title
        detailLabel.text = content
        detailLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleDetailLabel)))
        if showCopyButton {
            copyButton.addTarget(self, action: #selector(copyContent), for: .touchUpInside)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout(showCopyButton: Bool) {
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(titleLabel)
        addSubview(detailLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),

            detailLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 7),
            detailLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            detailLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        if showCopyButton {
            detailLabel.setContentHuggingPriority(.required, for: .horizontal)
            addSubview(copyButton)
            NSLayoutConstraint.activate([
                detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor),
                copyButton.leadingAnchor.constraint(equalTo: detailLabel.trailingAnchor, constant: 4),
                copyButton.topAnchor.constraint(equalTo: detailLabel.topAnchor),
                copyButton.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor)
            ])
        } else {
            detailLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor).isActive = true
        }

        backgroundColor = .systemBackground
    }

    @objc private func copyContent() {
        UIPasteboard.general.string = detailLabel.text
        TCGBUtil.showToast(message: "\(titleLabel.text ?? "")을(를) 복사했습니다.", length: .short)
        
        UIView.animate(withDuration: 0.1, animations: {
            self.copyButton.alpha = 0.3
            self.copyButton.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.copyButton.alpha = 1.0
                self.copyButton.transform = .identity
            }
        }
    }

    @objc private func toggleDetailLabel() {
        detailLabel.numberOfLines = detailLabel.numberOfLines == 0 ? 2 : 0

        var ancestor: UIView? = superview
        while let view = ancestor, !(view is UIScrollView) {
            ancestor = view.superview
        }

        UIView.animate(withDuration: 0.3) {
            (ancestor ?? self.superview)?.layoutIfNeeded()
        }
    }
}
