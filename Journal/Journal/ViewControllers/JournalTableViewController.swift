//
//  JournalTableViewController.swift
//  Journal
//
//  Created by Hayden Hastings on 8/1/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit

class JournalTableViewController: UITableViewController {

    let monthsInYear = ["December", "November", "October", "September", "August", "July", "June", "May", "April", "March", "February", "January"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        JournalController.journalController.fetchJournalsFromCloudKit {
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return monthsInYear.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let filteredJournals = JournalController.journalController.filterJournalsBy(month: monthsInYear[section])
        
        return filteredJournals.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "JournalCell", for: indexPath) as? JournalTableViewCell else { return UITableViewCell() }
        
        let filteredJournals = JournalController.journalController.filterJournalsBy(month: monthsInYear[indexPath.section])
        
        let journal = filteredJournals[indexPath.row]
        
        cell.updateWithJournal(journal: journal)

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let filteredJournals = JournalController.journalController.filterJournalsBy(month: monthsInYear[section])
        
        if filteredJournals.count > 0 {
            
            return monthsInYear[section]
        } else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        returnedView.backgroundColor = UIColor(red: 21 / 255.0, green: 30 / 255.0, blue: 46 / 255.0, alpha: 100)
        
        let label = UILabel(frame: CGRect(x: 10, y: 0, width: view.frame.size.width, height: 30))
        label.text = self.monthsInYear[section]
        label.textColor = .white
        returnedView.addSubview(label)
        return returnedView
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let filteredJournals = JournalController.journalController.filterJournalsBy(month: monthsInYear[indexPath.section])
            let journal = filteredJournals[indexPath.row]
            guard let recordID = journal.cloudKitRecordID else { return }
            JournalController.journalController.deleteJournal(withRecordID: recordID, completion: { (_, error) in
                if let error = error {
                    print("Could not delete recordID in CloudKit. \(error.localizedDescription)")
                }
            })
            
            guard let index = JournalController.journalController.journals.firstIndex(of: journal) else { return }
            
            JournalController.journalController.journals.remove(at: index)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
  
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toJournalVC" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let journalDetailVC = segue.destination as? JournalEditingViewController else { return }
            let filteredJournals = JournalController.journalController.filterJournalsBy(month: monthsInYear[indexPath.section])
            let journal = filteredJournals[indexPath.row]
            journalDetailVC.journal = journal
        }
    }
}
