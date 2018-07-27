//
//  MasterViewController.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/25/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UIViewController, NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    //MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var loadingBarBackgroundHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var loadingBarWidthConstraint: NSLayoutConstraint!
    
    //MARK: - Variables
    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil
    
    var allPosts = [Post]()
    
    var currentSearch = "" {
        didSet {
            if currentSearch != "" {
                filterDataWithText(currentSearch)
            } else {
                showAllPosts()
            }
        }
    }
    
    var currentDataToShow = [Post]() {
        didSet {
            tableView.reloadData()
        }
    }
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        refreshDataShown()
        showAllPosts()
        
        getPosts()
    }
    
    //MARK: - API call
    func getPosts() {
        APIManager.sharedInstance.getData { [weak self] currentProgress in
            guard let strongSelf = self else { return }
            if currentProgress == 1.0 {
                UIView.animate(withDuration: 0.2, animations: {
                    strongSelf.loadingBarWidthConstraint.constant = strongSelf.view.frame.width
                    strongSelf.loadingBarBackgroundHeightConstraint.constant = 0.0
                    strongSelf.view.layoutIfNeeded()
                })
                strongSelf.insertObjectsToDatabase()
            } else {
                if strongSelf.loadingBarBackgroundHeightConstraint.constant == 0.0 {
                    UIView.animate(withDuration: 0.2, animations: {
                        strongSelf.loadingBarBackgroundHeightConstraint.constant = 6.0
                        strongSelf.view.layoutIfNeeded()
                    })
                }
                let newProgress = strongSelf.view.frame.width * currentProgress
                if newProgress > strongSelf.loadingBarWidthConstraint.constant {
                    UIView.animate(withDuration: 0.2, animations: {
                        strongSelf.loadingBarWidthConstraint.constant = newProgress
                        strongSelf.view.layoutIfNeeded()
                    })
                }
            }
        }
    }
    
    //MARK: - Insertion
    func insertObjectsToDatabase() {
        let context = self.fetchedResultsController.managedObjectContext
        
        let newUsers = APIManager.sharedInstance.users!.map { currentUser -> User in
            let newUser = User(context: context)
            newUser.id = currentUser["id"] as? Int32 ?? 0
            newUser.email = currentUser["email"] as? String ?? ""
            return newUser
        }
        
        let newAlbums = APIManager.sharedInstance.albums!.map { currentAlbum -> Album in
            let newAlbum = Album(context: context)
            newAlbum.id = currentAlbum["id"] as? Int32 ?? 0
            newAlbum.title = currentAlbum["title"] as? String ?? ""
            
            if let userId = currentAlbum["userId"] as? Int32 {
                newAlbum.user = newUsers.first(where: { $0.id == userId })
            }
            
            return newAlbum
        }
        
        APIManager.sharedInstance.photos!.forEach { currentPhoto in
            let newPhoto = Photo(context: context)
            newPhoto.id = currentPhoto["id"] as? Int32 ?? 0
            newPhoto.title = currentPhoto["title"] as? String ?? ""
            newPhoto.url = currentPhoto["url"] as? String ?? ""
            newPhoto.thumbnailUrl = currentPhoto["thumbnailUrl"] as? String ?? ""
            
            if let albumId = currentPhoto["albumId"] as? Int32 {
                newPhoto.album = newAlbums.first(where: { $0.id == albumId })
            }
        }
        
        
        APIManager.sharedInstance.posts!.forEach { currentPost in
            if let id = currentPost["id"] as? Int32, let title = currentPost["title"] as? String, let body = currentPost["body"] as? String {
                if !allPosts.contains(where: { $0.id == id }) {
                    let newPost = Post(context: context)
                    
                    newPost.id = id
                    newPost.title = title
                    newPost.body = body
                    
                    if let userId = currentPost["userId"] as? Int32 {
                        newPost.user = newUsers.first(where: { $0.id == userId })
                    }
                }
            }
        }
        
        do {
            try context.save()
        } catch {
            let nserror = error as NSError
            print("Could not save to database, error: \(nserror), \(nserror.userInfo)")
        }
    }

    //MARK: - Segues
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let post = currentDataToShow[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = post
            }
        }
    }

    //MARK: - TableView DataSource / Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentDataToShow.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MasterViewTableViewCell
        let post = currentDataToShow[indexPath.row]
        configureCell(cell, withPost: post)
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
            
            currentDataToShow.remove(at: indexPath.row)
                
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                print("Could not delete item from database, error: \(nserror), \(nserror.userInfo)")
            }
        }
    }

    func configureCell(_ cell: MasterViewTableViewCell, withPost post: Post) {
        cell.setupView(withPost: post)
    }
    
    func showAllPosts() {
        currentDataToShow = allPosts
    }
    
    func refreshDataShown() {
        let context = self.fetchedResultsController.managedObjectContext
        
        let request: NSFetchRequest<Post> = Post.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            allPosts = try context.fetch(request)
        } catch {
            print("Could not retrieve posts")
        }
    }
    
    //MARK: - SearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearch = searchText
    }

    //MARK: - Logic
    func filterDataWithText(_ text: String) {
        currentDataToShow = allPosts.filter {
            guard let title = $0.title, let email = $0.user?.email else { return false }
            return title.lowercased().contains(text.lowercased()) || email.lowercased().contains(text.lowercased())
        }
    }
    
    //MARK: - Fetched results controller
    var _fetchedResultsController: NSFetchedResultsController<Post>? = nil
    var fetchedResultsController: NSFetchedResultsController<Post> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        self.managedObjectContext!.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: "Master")
        aFetchedResultsController.delegate = self
        _fetchedResultsController = aFetchedResultsController
        
        do {
            try _fetchedResultsController!.performFetch()
        } catch {
            let nserror = error as NSError
            print("Could not perform database fetch, error: \(nserror), \(nserror.userInfo)")
        }
        
        return _fetchedResultsController!
    }
     
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        refreshDataShown()
        showAllPosts()
     }
}

