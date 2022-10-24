//
//  CustomTapActionCell.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/09/20.
//

import Foundation
import QuickTableViewController

final class CustomTapActionCell: TapActionCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpAppearance()
    }
    
    private func setUpAppearance() {
        textLabel?.numberOfLines = 0
        textLabel?.textAlignment = .left
        textLabel?.textColor = .black
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        textLabel?.textColor = .black
    }
}
