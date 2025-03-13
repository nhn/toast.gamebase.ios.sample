//
//  IdPMappingTableViewCell.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/22.
//

import UIKit

final class IdPMappingTableViewCell: UITableViewCell {
    static let nibName = "IdPMappingTableViewCell"
    static let cellID = "\(nibName)ID"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var iconImageView: UIImageView!
    @IBOutlet private weak var button: UIButton!
    private var handler: ((Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    private func setup() {
        self.selectionStyle = .none
        
        self.button.setTitle("연동됨", for: .selected)
        self.button.setBackgroundColor(.accentColor, for: .selected)
        
        self.button.setTitle("연동하기", for: .normal)
        self.button.setBackgroundColor(.lightLightGray, for: .normal)
        
        self.button.layer.cornerRadius = 10
        self.button.clipsToBounds = true
    }
    
    func bind(mappingInfo: IdPMappingInfo) {
        self.titleLabel.text = mappingInfo.idPType
        self.iconImageView.image = UIImage(named: mappingInfo.icon)

        self.handler = mappingInfo.handler

        if mappingInfo.alreadyMapped {
            self.button.isSelected = true
        } else {
            self.button.isSelected = false
        }
    }

    @IBAction func onClickButton(_ sender: Any) {
        handler?(self.button.isSelected)
    }
}
