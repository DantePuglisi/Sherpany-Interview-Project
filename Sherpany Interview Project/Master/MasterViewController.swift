//
//  MasterViewController.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/25/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController, NSFetchedResultsControllerDelegate {

    var detailViewController: DetailViewController? = nil
    var managedObjectContext: NSManagedObjectContext? = nil


    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = editButtonItem

        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        self.title = "Posts"
        
    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
        APIManager.sharedInstance.getData { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.eraseDatabase()
            strongSelf.insertObjectsToDatabase()
        }
    }
    
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
                let newPost = Post(context: context)
                
                newPost.id = id
                newPost.title = title
                newPost.body = body
                
                if let userId = currentPost["userId"] as? Int32 {
                    newPost.user = newUsers.first(where: { $0.id == userId })
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
    
    func eraseDatabase() {
        let context = self.fetchedResultsController.managedObjectContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Post")
        
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            tableView.reloadData()
        } catch {
            print("Could not erase database")
        }
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MasterViewTableViewCell
        let post = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withPost: post)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let context = fetchedResultsController.managedObjectContext
            context.delete(fetchedResultsController.object(at: indexPath))
                
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

    // MARK: - Fetched results controller

    var fetchedResultsController: NSFetchedResultsController<Post> {
        if _fetchedResultsController != nil {
            return _fetchedResultsController!
        }
        
        let fetchRequest: NSFetchRequest<Post> = Post.fetchRequest()
        
        fetchRequest.fetchBatchSize = 20
        
        let sortDescriptor = NSSortDescriptor(key: "id", ascending: true)
        
        fetchRequest.sortDescriptors = [sortDescriptor]
        
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
    var _fetchedResultsController: NSFetchedResultsController<Post>? = nil

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
            case .insert:
                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
            case .delete:
                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
            default:
                return
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                configureCell(tableView.cellForRow(at: indexPath!) as! MasterViewTableViewCell, withPost: anObject as! Post)
            case .move:
                configureCell(tableView.cellForRow(at: indexPath!) as! MasterViewTableViewCell, withPost: anObject as! Post)
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

