//
//  DetailViewController.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/25/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UICollectionViewDataSource {

    //MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var detailItem: Post?
    var detailAlbums: [Album]?
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(UINib(nibName: "DetailAlbumCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        configureView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        collectionViewHeightConstraint.constant = collectionView.frame.height
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
            collectionView.alpha = 0.0
        }
    }
    
    //MARK: - CollectionView DataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! DetailAlbumCollectionViewCell
        
        return cell
    }

}

