//
//  BranchAnnatation+CoreDataProperties.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 10.03.22.
//
//

import Foundation
import CoreData


extension BranchAnnatation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BranchAnnatation> {
        return NSFetchRequest<BranchAnnatation>(entityName: "BranchAnnatation")
    }

    @NSManaged public var branchitems: [BranchesPinAnnotation]?

}

extension BranchAnnatation : Identifiable {

}
