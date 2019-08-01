//
//  JournalEditingViewController.swift
//  Journal
//
//  Created by Hayden Hastings on 8/1/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit

class JournalEditingViewController: UIViewController {
    
    @IBOutlet weak var journalImageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var journalTextView: UITextView!
    
    var journal: Journal?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let journal = journal {
            updateViews(journal: journal)
        }
    }
    
    func updateViews(journal: Journal) {
        
        self.journal = journal
        titleTextField.text = journal.title
        journalImageView.image = journal.photo
        journalTextView.text = journal.journalText
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toJournalEditingVC" {
            guard let destinationViewController = segue.destination as? JournalDetailViewController else { return }
            destinationViewController.journal = self.journal
        }
    }
}

