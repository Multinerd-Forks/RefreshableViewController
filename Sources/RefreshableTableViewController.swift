//
//  RefreshableTableViewController.swift
//  TREX
//
//  Created by Daniel Clelland on 30/08/17.
//  Copyright © 2017 Daniel Clelland. All rights reserved.
//

import UIKit
import PromiseKit

// MARK: Refreshable table view controller

public class RefreshableTableViewController<T>: UITableViewController {
    
    // MARK: Initializers
    
    public convenience init(style: UITableViewStyle, request: @autoclosure @escaping (Void) -> Promise<T>) {
        self.init(style: style)
        self.request = request
    }
    
    public convenience init(style: UITableViewStyle, response: T) {
        self.init(style: style)
        self.state = .success(response: response)
    }
    
    // MARK: Public state
    
    public final var request: ((Void) -> Promise<T>)? {
        didSet {
            refresh()
        }
    }
    
    public final var state: RefreshableState<T> = .ready {
        didSet {
            refreshState()
        }
    }
    
    // MARK: Overrides
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if request != nil {
            tableView.refreshControl = UIRefreshControl()
            tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
            refresh()
        } else {
            refreshState()
        }
    }
    
    // MARK: Refresh
    
    public final func refresh() {
        guard let request = request else {
            return
        }
        
        self.state = .loading
        
        request().then { response in
            self.state = .success(response: response)
        }.always {
            self.refreshControl?.endRefreshing()
        }.catch { error in
            self.state = .failure(error: error)
        }
    }
    
    public func refreshState() {
        // This should be overridden in subclasses
    }
    
}
