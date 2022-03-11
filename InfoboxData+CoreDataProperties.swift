//
//  InfoboxData+CoreDataProperties.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 11.03.22.
//
//

import Foundation
import CoreData


extension InfoboxData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<InfoboxData> {
        return NSFetchRequest<InfoboxData>(entityName: "InfoboxData")
    }

    @NSManaged public var infoboxData: Data?

}

extension InfoboxData : Identifiable {

}
