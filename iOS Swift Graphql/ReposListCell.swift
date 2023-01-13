//
//  ReposListCell.swift
//  iOS Swift Graphql
//
//  Created by Damir Aushenov on 13/1/23.
//

import UIKit


protocol ReposListCellDelegate: class {
    func starTapped(for cell: ReposListCell)
}

class ReposListCell: UITableViewCell {
    
    @IBOutlet weak var repoName: UILabel!
    @IBOutlet weak var starCount: UILabel!
    @IBOutlet weak var starButton: UIButton!
    
    weak var delegate: ReposListCellDelegate?
    
    var repositoryDetail: RepositoryDetail! {
        didSet {
            repoName.text = repositoryDetail.nameWithOwner
            starCount.text = "\(repositoryDetail.stargazers.totalCount)"
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        starButton.addTarget(self, action: #selector(starTapped), for: .touchUpInside)
    }
    
    @objc func starTapped() {
        delegate?.starTapped(for: self)
    }
}
