//
//  ProductsViewController.swift
//  ShopSearchExampleApp
//
//  Created by Ricardo Koch on 4/7/16.
//  Copyright © 2016 Ricardo Koch. All rights reserved.
//

import UIKit
import ShopSearch

class ProductsViewController: UIViewController {

	
	@IBOutlet weak var mainLabel: UILabel!
	
    var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

		self.title = "Products"

        // Create the search results controller and store a reference to it.
        let tableResults:SearchResultsViewController? = self.instantiateViewController("SearchResultsVC")
        if let controller = tableResults {
            self.searchController = UISearchController(searchResultsController: controller)
        }
        
        // Use the current view controller to update the search results.
        self.searchController?.searchResultsUpdater = self
		self.searchController?.searchBar.delegate = self
        
        // Install the search bar.
        self.view.addSubview(self.searchController!.searchBar)
        
        // It is usually good to set the presentation context.
        self.definesPresentationContext = true
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    

}

extension ProductsViewController: UISearchControllerDelegate {

    @objc(didDismissSearchController:) func didDismissSearchController(_ searchController: UISearchController) {
		
    }
}

extension ProductsViewController: UISearchResultsUpdating {
	
	
    func updateSearchResults(for searchController: UISearchController) {
        
		if searchController.searchBar.text?.characters.count ?? 0 > 0 {
			mainLabel.text = "Tap search to load your results!"
		} else {
			mainLabel.text = "Search for products using the search bar..."
		}
    }
}

extension ProductsViewController: UISearchBarDelegate {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		
		mainLabel.text = "Loading your products..."
		ShopSearch.shared().search(keywords: searchBar.text ?? "") { (products, success) -> (Void) in
			
			if success {
				let controller = self.searchController?.searchResultsController as? SearchResultsViewController
				controller?.results = products
				controller?.tableView.reloadData()
			}
			else {
				let alert = UIAlertController(title: "Error", message: "Failed to fetch products from ShopSearch", preferredStyle: .alert)
				self.present(alert, animated: true, completion: nil)
				alert.addAction(UIAlertAction(title: "Close", style: .default, handler: {
					(action) in
					alert.dismiss(animated: true, completion: nil)
				}))
			}
		}
	}
	
	
}


