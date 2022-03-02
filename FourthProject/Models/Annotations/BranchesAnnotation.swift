//
//  BranchesAnnotation.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 2.03.22.
//

import MapKit

class BranchesPinAnnotation: NSObject, MKAnnotation {
  @objc dynamic var coordinate: CLLocationCoordinate2D
  let title: String?
  let atm: BranchElement
  init(title: String,
	   branch: BranchElement,
	   coordinate: CLLocationCoordinate2D) {
	self.coordinate = coordinate
	self.title = title
	self.atm = branch
	super.init()
  }
}
