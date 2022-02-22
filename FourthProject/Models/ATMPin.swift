//
//  ATMPin.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import MapKit
class MapPin: NSObject, MKAnnotation {
   let title: String?
   let locationName: String
   let coordinate: CLLocationCoordinate2D

init(title: String, locationName: String, coordinate: CLLocationCoordinate2D) {
      self.title = title
      self.locationName = locationName
      self.coordinate = coordinate
   }
}
