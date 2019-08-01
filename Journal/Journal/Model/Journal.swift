//
//  Journal.swift
//  Journal
//
//  Created by Hayden Hastings on 7/31/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import UIKit
import CloudKit

class Journal: CloudKitSyncable, Equatable {

    static let kType = "Jouranl"
    static let kPhotoData = "photoData"
    static let kTitle = "title"
    static let kTimeStamp = "timeStamp"
    static let kJournaltext = "journalText"
    
    var photoData: Data?
    var title: String
    var journalText: String
    var timeStamp: Date
    var cloudKitRecordID: CKRecord.ID?
    
    init(photoData: Data?, title: String, journalText: String, timeStamp: Date = Date()) {
        self.photoData = photoData
        self.title = title
        self.journalText = journalText
        self.timeStamp = timeStamp
    }
    
    var photo: UIImage? {
        guard let photoData = self.photoData else { return nil }
        return UIImage(data: photoData)
    }
    
    // MARK: - CloudKitSyncable
    
    var recordType: String {
        return Journal.kType
    }
    
    // Takes in a CKRecord and turns in into a model Object.
    convenience required init?(record: CKRecord) {
        guard let title = record[Journal.kTitle] as? String,
            let journalText = record[Journal.kJournaltext] as? String,
            let timeStamp = record[Journal.kTimeStamp] as? Date,
            let photoAsset = record[Journal.kPhotoData] as? CKAsset
            else { return nil }
        let photoData = try? Data(contentsOf: photoAsset.fileURL!)
        self.init(photoData: photoData, title: title, journalText: journalText, timeStamp: timeStamp)
        
        cloudKitRecordID = record.recordID
    }
    
    fileprivate var temporaryPhotoURL: URL {
        let temporaryDictionary = NSTemporaryDirectory()
        let temporaryDictionaryURL = URL(fileURLWithPath: temporaryDictionary)
        let fileURL = temporaryDictionaryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
        
        try? photoData?.write(to: fileURL, options: .atomic)
        return fileURL
    }
    
}

// Turns model into a CKRecord and saves it in cloudKit
extension CKRecord {
    
    convenience init(journal: Journal) {
        
        let recordID = journal.cloudKitRecordID ?? CKRecord.ID(recordName: UUID().uuidString)
        self.init(recordType: "Journal", recordID: recordID)
        self.setValue(journal.title, forKey: Journal.kTitle)
        self.setValue(journal.journalText, forKey: Journal.kJournaltext)
        self[Journal.kTimeStamp] = journal.timeStamp as CKRecordValue?
        self.setValue(CKAsset(fileURL: journal.temporaryPhotoURL), forKey: Journal.kPhotoData)
    }
}

func ==(lhs: Journal, rhs: Journal) -> Bool {
    return lhs === rhs
}

