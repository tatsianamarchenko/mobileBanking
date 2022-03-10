//
//  ATMPin.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import MapKit

public class ATMsPinAnnotation: NSObject, MKAnnotation {
	@objc dynamic public var coordinate: CLLocationCoordinate2D
	public let title: String?
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
