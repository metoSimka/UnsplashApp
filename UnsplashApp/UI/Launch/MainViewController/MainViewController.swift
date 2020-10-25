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
        self.navigationController?.modalPresentationStyle = .fullScreen
        self.navigationController?.hidesBottomBarWhenPushed = true
        let vc = SearchViewController(nibName: "SearchViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: false)
//        self.present(vc, animated: false, completion: nil)
//        openAuthorizationViewController()
    }
}
