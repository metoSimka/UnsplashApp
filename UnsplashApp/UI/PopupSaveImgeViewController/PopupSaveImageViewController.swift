//
//  PopupSaveImageViewController.swift
//  UnsplashApp
//
//  Created by metoSimka on 27.10.2020.
//  Copyright © 2020 metoSimka. All rights reserved.
//

import UIKit

protocol PopupSaveImageViewControllerDelegate: class {
    func saveWithQuality(quality: Quality)
    func PopupSaveImageViewControllerClosed()
}

class PopupSaveImageViewController: UIViewController {
    
    weak var delegate: PopupSaveImageViewControllerDelegate?
    
    private var quality: Quality = .thumbnail

    @IBOutlet var qualityButtons: [UIButton]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateQualityButtons()
    }
    
    @IBAction func qualityChoosed(_ sender: UIButton) {
        guard let newQuality = Quality(rawValue: sender.tag) else {
            return
        }
        self.quality = newQuality
        updateQualityButtons()
    }
    
    @IBAction func tapBackground(_ sender: UITapGestureRecognizer) {
        close()
    }
    
    @IBAction func save(_ sender: UIButton) {
        self.delegate?.saveWithQuality(quality: self.quality)
        close()
    }
    
    private func close() {
        self.dismiss(animated: true) {
            self.delegate?.PopupSaveImageViewControllerClosed()
        }
    }
    
    private func updateQualityButtons() {
        let qualityRaw = quality.rawValue
        var qualityButton: UIButton?
        for button in qualityButtons {
            if button.tag == qualityRaw {
                qualityButton = button
            }
        }
        guard let button = qualityButton else {
            return
        }
        deselectAllButtons()
        selectButton(button)
    }
    
    private func deselectAllButtons() {
        for button in qualityButtons {
            unselectButton(button)
        }
    }
    
    private func selectButton(_ button: UIButton) {
        button.backgroundColor = .darkGray
        button.setTitleColor(.white, for: .normal)
    }
    
    private func unselectButton(_ button: UIButton) {
        button.backgroundColor = .white
        button.setTitleColor(.darkGray, for: .normal)
    }
}
