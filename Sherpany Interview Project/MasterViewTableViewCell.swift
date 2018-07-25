//
//  MasterViewTableViewCell.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/25/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit

class MasterViewTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    func setupView(withPost postReceived: Post) {
        if let title = postReceived.title {
            titleLabel.text = title
        }
        
        if let email = postReceived.user?.email {
            subtitleLabel.text = email
        }
    }
    
}
