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
  let locationName: String
  let workTime: String
  let currency: String
  let isCash: String

  init(title: String,
       locationName: String,
       workTime: String,
       currency: String,
       isCash: String,
       coordinate: CLLocationCoordinate2D) {
    self.coordinate = coordinate
    self.title = title
    self.locationName = locationName
    self.workTime = workTime
    self.currency = currency
    self.isCash = isCash
    super.init()
  }
}
