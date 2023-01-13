//
//  ViewController.swift
//  iOS Swift Graphql
//
//  Created by Damir Aushenov on 12/1/23.
//

import UIKit



class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    let viewModel = ReposListViewModel()
    var repositoryDetails = [RepositoryDetail]()
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.register(UINib(nibName: "ReposListCell", bundle: nil), forCellReuseIdentifier: "ReposListCell")
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapRecognizer.delegate = self
        self.tableView.addGestureRecognizer(tapRecognizer)
        self.searchBar.delegate = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositoryDetails.count
    }
    
    @objc func hideKeyboard() {
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repo = repositoryDetails[indexPath.row]
       return reposListCell(for: repo)
    }
    
    private func reposListCell(for repos: RepositoryDetail) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(ReposListCell.self)!
        cell.repositoryDetail = repos
        cell.delegate = self
        return cell
    }
    
    func updateTableView(for newDetail: RepositoryDetail?) {
        if let repositoryDetail = newDetail {
            for (index, detail) in repositoryDetails.enumerated() {
                if detail.id == repositoryDetail.id {
                    self.repositoryDetails[index] = repositoryDetail
                    for visibleCell in tableView.visibleCells {
                        if (visibleCell as! ReposListCell).repositoryDetail.id == repositoryDetail.id {
                            (visibleCell as! ReposListCell).repositoryDetail = repositoryDetail
                        }
                    }
                }
            }
        }
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        viewModel.search(for: searchBar.text ?? "") { [unowned self] repositoryDetails in
            self.repositoryDetails = repositoryDetails
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.resignFirstResponder()
    }
}

extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension ViewController: ReposListCellDelegate {
    func starTapped(for cell: ReposListCell) {
        
        if !cell.repositoryDetail.viewerHasStarred {
            viewModel.addStar(for: cell.repositoryDetail.id) { [unowned self] repositoryDetail in
                self.updateTableView(for: repositoryDetail)
            }
        }
    }
}
