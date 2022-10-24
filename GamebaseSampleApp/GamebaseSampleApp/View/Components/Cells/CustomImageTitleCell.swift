//
//  CustomImageTitleCell.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/07/21.
//

import UIKit

final class CustomImageTitleCell: UITableViewCell {
    static let nibName = "CustomImageTitleCell"
    static let cellID = "\(nibName)ID"
    var lineSpacing: CGFloat = 0.0
    
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.clear

        selectedBackgroundView = backgroundView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()   
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: lineSpacing, right: 0))
    }
    
    func bind(title: String, iconImageName: String) {
        self.titleLabel.text = title
        self.iconImageView.image = UIImage(named: iconImageName)
    }
}
