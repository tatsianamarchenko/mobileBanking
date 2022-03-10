//
//  InfoboxAnnotation.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 2.03.22.
//

import MapKit

public class InfoboxsPinAnnotation: NSObject, MKAnnotation {
	@objc dynamic public var coordinate: CLLocationCoordinate2D
	public let title: String?
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
