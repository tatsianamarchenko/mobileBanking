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
	let cityType: CityType?
	let city: String?
	let addressType: AddressType?
	let address, house: String?
	let installPlace: InstallPlace?
	let locationNameDesc, workTime, timeLong, gpsX: String?
	let gpsY: String?
	let currency: Currencys?
	let infType: InfType?
	let cashInExist, cashIn, typeCashIn, infPrinter: CashIn?
	let regionPlatej, popolneniePlatej, infStatus: CashIn?
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

enum AddressType: String, Codable {
	case empty = " "
	case бР = "б-р"
	case др = "др."
	case мкр = "мкр."
	case мкрН = "мкр-н"
	case пер = "пер."
	case пл = "пл."
	case пос = "пос."
	case пр = "пр."
	case ст = "ст."
	case тер = "тер."
	case тракт = "тракт"
	case ул = "ул."
	case ш = "ш."
	case шоссе = "шоссе"
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

enum CashIn: String, Codable {
	case да = "да"
	case нет = "нет"
}

enum CityType: String, Codable {
	case cityTypeГп = "гп"
	case cityTypeРп = "рп"
	case empty = " "
	case аг = "аг."
	case г = "г."
	case гп = "гп."
	case д = "д."
	case кп = "кп."
	case п = "п."
	case пгт = "пгт."
	case рН = "р-н"
	case рп = "рп."
	case сС = "с/с"
}

enum Currencys: String, Codable {
	case byn = "BYN"
	case bynEurRubUsd = "BYN,EUR,RUB,USD"
	case empty = " "
}

enum InfType: String, Codable {
	case внешний = "Внешний"
	case внутренний = "Внутренний"
}

enum InstallPlace: String, Codable {
	case empty = " "
	case аэропорт = "Аэропорт"
	case больница = "Больница"
	case военнаяБаза = "Военная база"
	case гастроном = "Гастроном"
	case гостиница = "Гостиница"
	case магазинРозничнойТорговли = "Магазин розничной торговли"
	case медицинскийЦентр = "Медицинский центр"
	case наУлице = "На улице"
	case остановкаАвтобусаПоезда = "Остановка автобуса/поезда"
	case офисноеЗдание = "Офисное здание"
	case прачечная = "Прачечная"
	case прочее = "Прочее"
	case пунктОбменаВалют = "Пункт обмена валют"
	case спортивныйКомплекс = "Спортивный комплекс"
	case супермаркет = "Супермаркет"
	case торговыйЦентр = "Торговый центр"
	case университет = "Университет"
	case финансовоеУчреждение = "Финансовое учреждение"
}

typealias Welcome = [InfoBox]
