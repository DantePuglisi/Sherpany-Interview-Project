//
//  APIManager.swift
//  Sherpany Interview Project
//
//  Created by Dante Puglisi on 7/26/18.
//  Copyright © 2018 Dante Puglisi. All rights reserved.
//

import Alamofire

class APIManager {
    static let sharedInstance = APIManager()
    
    var group: DispatchGroup?
    var currentProgress: CGFloat = 0.0
    
    var posts: [[String: AnyObject]]?
    var users: [[String: AnyObject]]?
    var photos: [[String: AnyObject]]?
    var albums: [[String: AnyObject]]?
    
    func getData(completion: @escaping (_ progress: CGFloat) -> Void) {
        group = DispatchGroup()
        guard let group = group else { return }
        
        group.enter()
        getPosts(completion: { response in
            self.posts = response
            self.currentProgress += 0.25
            completion(self.currentProgress)
            group.leave()
        })
        
        group.enter()
        getUsers(completion: { response in
            self.users = response
            self.currentProgress += 0.25
            completion(self.currentProgress)
            group.leave()
        })
        
        group.enter()
        getPhotos(completion: { response in
            self.photos = response
            self.currentProgress += 0.25
            completion(self.currentProgress)
            group.leave()
        })
        
        group.enter()
        getAlbums(completion: { response in
            self.albums = response
            self.currentProgress += 0.25
            completion(self.currentProgress)
            group.leave()
        })
        
        group.notify(queue: .main) {
            print("Finished downloading data")
            completion(1.0)
        }
    }
    
    fileprivate func getPosts(completion: @escaping (_ posts: [[String: AnyObject]]?) -> Void) {
        Alamofire.request("http://jsonplaceholder.typicode.com/posts/").responseJSON { response in
            if let json = response.result.value as? [[String: AnyObject]] {
                completion(json)
            } else {
                completion(nil)
            }
        }
    }
    
    fileprivate func getUsers(completion: @escaping (_ posts: [[String: AnyObject]]?) -> Void) {
        Alamofire.request("http://jsonplaceholder.typicode.com/users/").responseJSON { response in
            if let json = response.result.value as? [[String: AnyObject]] {
                completion(json)
            } else {
                completion(nil)
            }
        }
    }
    
    fileprivate func getPhotos(completion: @escaping (_ posts: [[String: AnyObject]]?) -> Void) {
        Alamofire.request("http://jsonplaceholder.typicode.com/photos/").responseJSON { response in
            if let json = response.result.value as? [[String: AnyObject]] {
                completion(json)
            } else {
                completion(nil)
            }
        }
        
        // I wanted to display the real current progress but typicode.com doesn't send `Content-Length` so it's not possible
        
        /*Alamofire.request("http://jsonplaceholder.typicode.com/photos/")
            .downloadProgress { currentProgress in
                print("currentProgress: \(currentProgress.fractionCompleted)")
            }
            .responseJSON { response in
                if let json = response.result.value as? [[String: AnyObject]] {
                    completion(json)
                } else {
                    completion(nil)
                }
        }*/
    }
    
    fileprivate func getAlbums(completion: @escaping (_ posts: [[String: AnyObject]]?) -> Void) {
        Alamofire.request("http://jsonplaceholder.typicode.com/albums/").responseJSON { response in
            if let json = response.result.value as? [[String: AnyObject]] {
                completion(json)
            } else {
                completion(nil)
            }
        }
    }
}
