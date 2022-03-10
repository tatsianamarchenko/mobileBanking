//
//  ATMAnnatation+CoreDataProperties.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 10.03.22.
//
//

import Foundation
import CoreData


extension ATMAnnatation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ATMAnnatation> {
        return NSFetchRequest<ATMAnnatation>(entityName: "ATMAnnatation")
    }

    @NSManaged public var atmitems: [ATMsPinAnnotation]?

}

extension ATMAnnatation : Identifiable {

}
