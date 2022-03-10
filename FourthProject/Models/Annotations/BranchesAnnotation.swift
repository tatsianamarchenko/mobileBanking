//
//  BranchesAnnotation.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 2.03.22.
//

import MapKit

public class BranchesPinAnnotation: NSObject, MKAnnotation {
	@objc dynamic public var coordinate: CLLocationCoordinate2D
	public let title: String?
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
