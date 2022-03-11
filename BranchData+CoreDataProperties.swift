//
//  BranchData+CoreDataProperties.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 11.03.22.
//
//

import Foundation
import CoreData


extension BranchData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BranchData> {
        return NSFetchRequest<BranchData>(entityName: "BranchData")
    }

    @NSManaged public var branchData: Data?

}

extension BranchData : Identifiable {

}
