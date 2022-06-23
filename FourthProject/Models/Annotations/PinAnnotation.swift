//
//  BranchesAnnotation.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 2.03.22.
//

import MapKit

public class PinAnnotation<T: Codable> : NSObject, MKAnnotation{
	@objc dynamic public var coordinate: CLLocationCoordinate2D
	public let title: String?
	let item: T
	init(title: String,
		 item: T,
		 coordinate: CLLocationCoordinate2D) {
		self.coordinate = coordinate
		self.title = title
		self.item = item
		super.init()
	}
}
