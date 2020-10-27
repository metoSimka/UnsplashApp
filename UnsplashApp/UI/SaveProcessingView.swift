//
//  SaveProcessingView.swift
//  UnsplashApp
//
//  Created by metoSimka on 27.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import Foundation
import UIKit

class SaveProcessingView: UIView {
    
    public var contentView: UIView?
    
    private var label: UILabel?
    
    public func updateLabel(text: String) {
        label?.text = text
    }
    
    public func addSelf(to superView: UIView) {
        let contentView = UIView()
        contentView.clipsToBounds = true
        superView.addSubview(contentView)
        self.contentView = contentView
        contentView.layer.cornerRadius = 8
        contentView.backgroundColor = .white
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        contentView.centerYAnchor.constraint(equalTo: superView.centerYAnchor).isActive = true
        contentView.widthAnchor.constraint(equalToConstant: 152).isActive = true
        contentView.heightAnchor.constraint(equalToConstant: 112).isActive = true
        
        let label = UILabel()
        self.label = label
        label.font = UIFont(name: "SFProText-Regular", size: 16)
        label.textColor = .darkGray
        label.text = "Saving..."
        label.contentMode = .center
        contentView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24).isActive = true
        label.centerXAnchor.constraint(equalTo: superView.centerXAnchor).isActive = true
        
        let spinner = UIActivityIndicatorView()
        contentView.addSubview(spinner)
        
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16).isActive = true
        spinner.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
        spinner.startAnimating()
        spinner.isHidden = false
        spinner.style = .gray
    }
}
