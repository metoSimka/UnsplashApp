//
//  MainViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 23.09.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        openAuthorizationViewController()
    }
    
    private func openAuthorizationViewController() {
        let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
        let navVC = UINavigationController.init(rootViewController: vc)
        navVC.modalPresentationStyle = .fullScreen
        navVC.hidesBottomBarWhenPushed = true
        navVC.setNavigationBarHidden(true, animated: false)
        self.present(navVC, animated: false, completion: nil)
    }
}
