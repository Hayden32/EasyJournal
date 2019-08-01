//
//  CloudKitSyncable.swift
//  Journal
//
//  Created by Hayden Hastings on 7/31/19.
//  Copyright © 2019 Hayden Hastings. All rights reserved.
//

import Foundation
import CloudKit

protocol CloudKitSyncable {
    
    init?(record: CKRecord)
    
    var cloudKitRecordID: CKRecord.ID? { get set }
    var recordType: String { get }
}

extension CloudKitSyncable {
    
    var isSynced: Bool {
        return cloudKitRecordID != nil
    }
    
    var cloudKitReference: CKRecord.Reference? {
        
        guard let recordID = cloudKitRecordID else { return nil }
        
        return CKRecord.Reference(recordID: recordID, action: .deleteSelf)
    }
}
