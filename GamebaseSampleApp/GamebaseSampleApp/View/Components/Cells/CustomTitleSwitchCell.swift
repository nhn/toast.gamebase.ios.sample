//
//  CustomTitleSwitchCell.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/25.
//

import UIKit

final class CustomTitleSwitchCell: UITableViewCell {
    static let nibName = "CustomTitleSwitchCell"
    static let cellID = "\(nibName)ID"
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var switchButton: UISwitch!
    private var handler: ((Bool) -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    func bind(info: CustomTitleSwitchModel) {
        self.titleLabel.text = info.title
        self.switchButton.isOn = info.isOn
        self.handler = info.handler
    }
    
    @IBAction func toggle(_ sender: Any) {
        handler?(switchButton.isOn)
    }
}
