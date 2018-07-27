//
//  AlbumDisplayViewController.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/27/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit

class AlbumDisplayViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var textBackgroundView: UIView! {
        didSet {
            let colorTop = UIColor(white: 0.0, alpha: 0.0).cgColor
            let colorBottom = UIColor(white: 0.0, alpha: 1.0).cgColor
            
            let gradient = CAGradientLayer()
            gradient.frame = textBackgroundView.bounds
            gradient.frame.size.width = UIScreen.main.bounds.width
            gradient.colors = [colorTop, colorBottom]
            gradient.locations = [0.0, 1.0]
            
            textBackgroundView.layer.addSublayer(gradient)
        }
    }
    @IBOutlet weak var textLabel: UILabel!
    
    var photos = [Photo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "AlbumDisplayCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "cell")
        
        collectionView.isPagingEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if photos.count >= 1 {
            textLabel.text = photos[0].title ?? ""
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! AlbumDisplayCollectionViewCell
        
        cell.setupCell(withURLString: photos[indexPath.row].url ?? "")
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIScreen.main.bounds.size
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(collectionView.contentOffset.x / collectionView.frame.size.width)
        if currentPage < photos.count {
            textLabel.text = photos[currentPage].title ?? ""
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        if let currentGradient = textBackgroundView.layer.sublayers![0] as? CAGradientLayer, currentGradient.frame.width != UIScreen.main.bounds.width {
            currentGradient.removeFromSuperlayer()
            let colorTop = UIColor(white: 0.0, alpha: 0.0).cgColor
            let colorBottom = UIColor(white: 0.0, alpha: 1.0).cgColor
            
            let gradient = CAGradientLayer()
            gradient.frame = textBackgroundView.bounds
            gradient.frame.size.width = UIScreen.main.bounds.width
            gradient.colors = [colorTop, colorBottom]
            gradient.locations = [0.0, 1.0]
            
            textBackgroundView.layer.addSublayer(gradient)
        }
        
        collectionView.collectionViewLayout.invalidateLayout()
    }
}
