//
//  InfoboxAnnotation.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 2.03.22.
//

import MapKit

class InfoboxsPinAnnotation: NSObject, MKAnnotation {
  @objc dynamic var coordinate: CLLocationCoordinate2D
  let title: String?
  let atm: InfoBox
  init(title: String,
	   infoBox: InfoBox,
	   coordinate: CLLocationCoordinate2D) {
	self.coordinate = coordinate
	self.title = title
	self.atm = infoBox
	super.init()
  }
}
