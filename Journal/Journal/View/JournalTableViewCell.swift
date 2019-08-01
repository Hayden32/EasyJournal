//
//  JournalTableViewCell.swift
//  Journal
//
//  Created by Hayden Hastings on 8/1/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit

class JournalTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var journalImageView: UIImageView!
    
    var journal: Journal? {
        didSet {
            guard let journal = journal else { return }
            updateWithJournal(journal: journal)
        }
    }
    
    func updateWithJournal(journal: Journal) {
        titleLabel.text = journal.title
        journalImageView.image = journal.photo
    }

}
