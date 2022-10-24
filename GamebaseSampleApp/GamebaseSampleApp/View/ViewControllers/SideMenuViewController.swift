//
//  SideMenuViewController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/06/30.
//

import Foundation
import UIKit

final class SideMenuViewController: UITableViewController {
    @IBOutlet private var sideMenuTableView: UITableView!
    
    var delegate: CustomSideMenuNavigationControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sideMenuTableView.delegate = self
        sideMenuTableView.dataSource = self
    
        registerTableViewCells()
    }
    
    private func registerTableViewCells() {
        let cell = UINib(nibName: CustomImageTitleCell.nibName, bundle: nil)
        
        sideMenuTableView.register(cell, forCellReuseIdentifier: CustomImageTitleCell.cellID)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SideMenuViewController {
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CustomImageTitleCell.cellID, for: indexPath) as? CustomImageTitleCell else {
            return UITableViewCell()
        }
        
        cell.bind(title: SideMenuItem[indexPath.row].rawValue, iconImageName: SideMenuItem[indexPath.row].icon)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SideMenuItem.allCases.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMenu = SideMenuItem[indexPath.row]
        delegate?.menuSelected(selectedMenu)
    }
}
