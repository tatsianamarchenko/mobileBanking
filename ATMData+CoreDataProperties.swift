//
//  ATMData+CoreDataProperties.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 11.03.22.
//
//

import Foundation
import CoreData


extension ATMData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ATMData> {
        return NSFetchRequest<ATMData>(entityName: "ATMData")
    }

    @NSManaged public var atmData: Data?

}

extension ATMData : Identifiable {

}
