//
//  StoreTableViewCell.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/08/24.
//

import UIKit

final class ShoppingTableViewCell: UITableViewCell {
    static let nibName = "ShoppingTableViewCell"
    static let cellID = "\(nibName)ID"

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var subTitleLabel: UILabel!
    @IBOutlet private weak var priceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func bind(cellModel: ShoppingCellModel) {
        titleLabel.text = cellModel.title
        subTitleLabel.text = cellModel.description
        priceLabel.text = cellModel.price
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.priceLabel.layer.cornerRadius = 10
        self.priceLabel.layer.masksToBounds = true
    }
}
