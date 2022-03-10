//
//  InfoboxAnnatation+CoreDataProperties.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 10.03.22.
//
//

import Foundation
import CoreData


extension InfoboxAnnatation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InfoboxAnnatation> {
        return NSFetchRequest<InfoboxAnnatation>(entityName: "InfoboxAnnatation")
    }

    @NSManaged public var infoboxitem: [InfoboxsPinAnnotation]?

}

extension InfoboxAnnatation : Identifiable {

}
