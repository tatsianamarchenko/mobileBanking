//
//  SectionModel.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 25.06.22.
//

import Foundation

protocol General {
	var coor: GeographicCoordinates? {get set}
}

struct Section: General {
	var coor: GeographicCoordinates?
	var sectionName: String
	var rowData: [General]
}
