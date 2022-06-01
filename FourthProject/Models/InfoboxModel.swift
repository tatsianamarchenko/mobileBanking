//
//  InfoboxModel.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 1.03.22.
//

import Foundation

// MARK: - WelcomeElement
struct InfoBox: Codable, General {
	var coor: GeographicCoordinates?
	let infoID: Int?
	let area: Area?
	let cityType: String?
	let city: String?
	let addressType: String?
	let address, house: String?
	let installPlace: String?
	let locationNameDesc, workTime, timeLong, gpsX: String?
	let gpsY: String?
	let currency: String?
	let infType: String?
	let cashInExist, cashIn, typeCashIn, infPrinter: String?
	let regionPlatej, popolneniePlatej, infStatus: String?
	enum CodingKeys: String, CodingKey {
		case infoID = "info_id"
		case area
		case cityType = "city_type"
		case city
		case addressType = "address_type"
		case address, house
		case installPlace = "install_place"
		case locationNameDesc = "location_name_desc"
		case workTime = "work_time"
		case timeLong = "time_long"
		case gpsX = "gps_x"
		case gpsY = "gps_y"
		case currency
		case infType = "inf_type"
		case cashInExist = "cash_in_exist"
		case cashIn = "cash_in"
		case typeCashIn = "type_cash_in"
		case infPrinter = "inf_printer"
		case regionPlatej = "region_platej"
		case popolneniePlatej = "popolnenie_platej"
		case infStatus = "inf_status"
	}
}

enum Area: String, Codable {
	case брестская = "Брестская"
	case витебская = "Витебская"
	case гомельская = "Гомельская"
	case гродненская = "Гродненская"
	case минск = "Минск"
	case минская = "Минская"
	case могилевская = "Могилевская"
}
