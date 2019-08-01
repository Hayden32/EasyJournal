//
//  JournalController.swift
//  Journal
//
//  Created by Hayden Hastings on 7/31/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit
import CloudKit

class JournalController {
    
    // MARK: - Properties
    var journals: [Journal] = []
    let cloudkitManager = CloudKitManager()
    static let journalController = JournalController()
    
    // MARK: - Create
    func createJournal(image: UIImage, title: String, journalText: String, completion: @escaping (Error?) -> Void) {
        
        guard let data = image.jpegData(compressionQuality: 0.5) else { return }
        
        let journal = Journal(photoData: data, title: title, journalText: journalText)
        
        let record = CKRecord(journal: journal)
        cloudkitManager.privateDatabase.save(record) { (_, error) in
            
            if let error = error {
                print("There was a error saving to CK. JournalController: createJournal()")
                completion(error)
            } else {
                print("Record successfully saved to CK")
                self.journals.append(journal)
                completion(nil)
            }
        }
    }
    
    // MARK: - Delete
    func deleteJournal(withRecordID recordID: CKRecord.ID, completion: @escaping (CKRecord.ID?, Error?) -> Void) {
        cloudkitManager.privateDatabase.delete(withRecordID: recordID) { (recordID, error) in
            if let error = error {
                print("There was an error deleting from CloudKit. \(error.localizedDescription)")
                completion(recordID, error)
            }
        }
    }
    
    // MARK: - Update
    func update(journal: Journal) {
        
        let record = CKRecord(journal: journal)
        
        cloudkitManager.modifyRecords([record], perRecordCompletion: nil) { (records, error) in
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Fetch from iCloud
    func fetchJournalsFromCloudKit(completion: @escaping () -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "Journal", predicate: predicate)
        
        cloudkitManager.privateDatabase.perform(query, inZoneWith: nil) { (records, error) in
            guard let records = records else { return }
            let journals = records.compactMap({ Journal(record: $0)})
            self.journals = journals
            completion()
        }
    }
    
    let formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.doesRelativeDateFormatting = false
        
        return dateFormatter
    }()
    
    //  MARK: - Fetch Journals by months
    func filterJournalsBy(month: String) -> [Journal] {
        
        var filteredJournals: [Journal] = []
        
        for journal in self.journals {
            let timestampString =  journal.timeStamp.returnMonthOfTimestamp()
            if timestampString.contains(month) {
                filteredJournals.append(journal)
            }
        }
        
        let sortedJournals = filteredJournals.sorted(by: { $0.timeStamp > $1.timeStamp } )
        return sortedJournals
    }
}

extension Date {
    
    func returnMonthOfTimestamp() -> String {
        
        let formatter: DateFormatter = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            dateFormatter.doesRelativeDateFormatting = false
            
            return dateFormatter
        }()
        
        let month = formatter.string(from: self)
        return month
    }
}

