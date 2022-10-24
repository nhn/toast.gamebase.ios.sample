//
//  SideMenuNavigationController.swift
//  GamebaseSampleApp
//
//  Created by NHN on 2022/06/30.
//

import Foundation
import SideMenu

protocol CustomSideMenuNavigationControllerDelegate {
    func menuSelected(_ menu: SideMenuItem)
}

final class CustomSideMenuNavigationController: SideMenuNavigationController, CustomSideMenuNavigationControllerDelegate {
    
    var selectedMenu: SideMenuItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.presentationStyle = .menuSlideIn
        
        let rootVC: SideMenuViewController = self.viewControllers.first! as! SideMenuViewController
        rootVC.delegate = self
    }
    
    func menuSelected(_ menu: SideMenuItem) {
        self.selectedMenu = menu
        self.dismiss(animated: true, completion: nil)
    }
}
