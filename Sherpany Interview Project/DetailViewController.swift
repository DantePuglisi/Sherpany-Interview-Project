//
//  DetailViewController.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/25/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    
    //MARK: - Variables
    var detailItem: Post?
    
    //MARK: - Lifecycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    //MARK: - UI
    func configureView() {
        if let detailItem = detailItem {
            placeholderLabel.alpha = 0.0
            if let title = detailItem.title {
                titleLabel.text = title
                titleLabel.alpha = 1.0
            }
            if let body = detailItem.body {
                bodyLabel.text = body
                bodyLabel.alpha = 1.0
            }
        } else {
            placeholderLabel.alpha = 1.0
            titleLabel.alpha = 0.0
            bodyLabel.alpha = 0.0
        }
    }

}

