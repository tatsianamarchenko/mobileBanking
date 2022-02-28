//
//  ATMPin.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import MapKit
import SwiftUI

class MapPinAnnotation: NSObject, MKAnnotation {
  @objc dynamic var coordinate: CLLocationCoordinate2D
  let title: String?
  let atm: ATM
  
  init(title: String,
       atm: ATM,
       coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    self.title = title
    self.atm = atm
    super.init()
  }
}
