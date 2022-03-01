//
//  BranchesModel.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 1.03.22.
//

import Foundation

struct Branch: Codable {
	let data: DataClass

	enum CodingKeys: String, CodingKey {
		case data = "Data"
	}
}

struct DataClass: Codable {
	let branch: [BranchElement]

	enum CodingKeys: String, CodingKey {
		case branch = "Branch"
	}
}

struct BranchElement: Codable {
	let branchID, name, cbu, accountNumber: String
	let equeue, wifi: Int
	let accessibilities: AccessibilitiesElement
	let address: AddressElement
	let information: Information
	let services: Services

	enum CodingKeys: String, CodingKey {
		case branchID = "branchId"
		case name
		case cbu = "CBU"
		case accountNumber, equeue, wifi
		case accessibilities = "Accessibilities"
		case address = "Address"
		case information = "Information"
		case services = "Services"
	}
}

struct AccessibilitiesElement: Codable {
	let accessibility: Accessibility

	enum CodingKeys: String, CodingKey {
		case accessibility = "Accessibility"
	}
}

struct Accessibility: Codable {
	let type, accessibilityDescription: String

	enum CodingKeys: String, CodingKey {
		case type
		case accessibilityDescription = "description"
	}
}

struct AddressElement: Codable {
	let streetName, buildingNumber, department, postCode: String
	let townName, countrySubDivision, country, addressLine: String
	let addressDescription: String
	let geoLocation: GeoLocationInfo

	enum CodingKeys: String, CodingKey {
		case streetName, buildingNumber, department, postCode, townName, countrySubDivision, country, addressLine
		case addressDescription = "description"
		case geoLocation = "GeoLocation"
	}
}

struct GeoLocationInfo: Codable {
	let geographicCoordinates: GeographicCoordinatesInfo

	enum CodingKeys: String, CodingKey {
		case geographicCoordinates = "GeographicCoordinates"
	}
}

struct GeographicCoordinatesInfo: Codable {
	let latitude, longitude: String
}

struct Information: Codable {
	let segment: Segment
	let availability: AvailabilityInfo
	let contactDetails: Contacts

	enum CodingKeys: String, CodingKey {
		case segment
		case availability = "Availability"
		case contactDetails = "ContactDetails"
	}
}

struct AvailabilityInfo: Codable {
	let access24Hours, isRestricted, sameAsOrganization: Int
	let availabilityDescription: String
	let standardAvailability: StandardAvailabilityInfo
	let nonStandardAvailability: [NonStandardAvailability]

	enum CodingKeys: String, CodingKey {
		case access24Hours, isRestricted, sameAsOrganization
		case availabilityDescription = "description"
		case standardAvailability = "StandardAvailability"
		case nonStandardAvailability = "NonStandardAvailability"
	}
}

struct NonStandardAvailability: Codable {
	let name, fromDate, toDate, nonStandardAvailabilityDescription: String
	let day: NonStandardAvailabilityDay

	enum CodingKeys: String, CodingKey {
		case name, fromDate, toDate
		case nonStandardAvailabilityDescription = "description"
		case day = "Day"
	}
}

struct NonStandardAvailabilityDay: Codable {
	let dayCode, openingTime, closingTime: String
	let dayBreak: BreakTime

	enum CodingKeys: String, CodingKey {
		case dayCode, openingTime, closingTime
		case dayBreak = "Break"
	}
}

struct BreakTime: Codable {
	let breakFromTime, breakToTime: String
}

struct StandardAvailabilityInfo: Codable {
	let day: [DayElement]

	enum CodingKeys: String, CodingKey {
		case day = "Day"
	}
}

struct DayElement: Codable {
	let dayCode: Int
	let openingTime, closingTime: String
	let dayBreak: Break

	enum CodingKeys: String, CodingKey {
		case dayCode, openingTime, closingTime
		case dayBreak = "Break"
	}
}

struct Contacts: Codable {
	let name, phoneNumber, mobileNumber, faxNumber: String
	let emailAddress, other: String
	let socialNetworks: [SocialNetwork]

	enum CodingKeys: String, CodingKey {
		case name, phoneNumber, mobileNumber, faxNumber, emailAddress, other
		case socialNetworks = "SocialNetworks"
	}
}

struct SocialNetwork: Codable {
	let networkName: String
	let url: String
	let socialNetworkDescription: String

	enum CodingKeys: String, CodingKey {
		case networkName, url
		case socialNetworkDescription = "description"
	}
}

enum Segment: String, Codable {
	case business = "Business"
	case individual = "Individual"
}

struct Services: Codable {
	let service: ServiceInfo

	enum CodingKeys: String, CodingKey {
		case service = "Service"
	}
}

struct ServiceInfo: Codable {
	let the0, the1, the2, the3: The0
	let the4, the5, the6, the7: The0
	let the8, the9, the10, the11: The0
	let the12, the13, the14, the15: The0
	let the16, the17, the18, the19: The0
	let the20, the21, the22, the23: The0
	let the24, the25, the26, the27: The0
	let the28, the29, the30, the31: The0
	let the32, the33, the34, the35: The0
	let the36, the37, the38, the39: The0
	let the40, the41, the42, the43: The0
	let the44, the45, the46, the47: The0
	let the48, the49, the50, the51: The0
	let the52, the53, the54, the55: The0
	let the56, the57, the58, the59: The0
	let the60, the61, the62, the63: The0
	let the64, the65, the66, the67: The0
	let the68, the69, the70, the71: The0
	let the72, the73, the74, the75: The0
	let the76, the77, the78, the79: The0
	let the80, the81, the82, the83: The0
	let the84, the85, the86, the87: The0
	let the88, the89, the90, the91: The0
	let the92, the93, the94, the95: The0
	let the96, the97, the98, the99: The0
	let the100, the101, the102, the103: The0
	let currencyExchange: [CurrencyExchange]

	enum CodingKeys: String, CodingKey {
		case the0 = "0"
		case the1 = "1"
		case the2 = "2"
		case the3 = "3"
		case the4 = "4"
		case the5 = "5"
		case the6 = "6"
		case the7 = "7"
		case the8 = "8"
		case the9 = "9"
		case the10 = "10"
		case the11 = "11"
		case the12 = "12"
		case the13 = "13"
		case the14 = "14"
		case the15 = "15"
		case the16 = "16"
		case the17 = "17"
		case the18 = "18"
		case the19 = "19"
		case the20 = "20"
		case the21 = "21"
		case the22 = "22"
		case the23 = "23"
		case the24 = "24"
		case the25 = "25"
		case the26 = "26"
		case the27 = "27"
		case the28 = "28"
		case the29 = "29"
		case the30 = "30"
		case the31 = "31"
		case the32 = "32"
		case the33 = "33"
		case the34 = "34"
		case the35 = "35"
		case the36 = "36"
		case the37 = "37"
		case the38 = "38"
		case the39 = "39"
		case the40 = "40"
		case the41 = "41"
		case the42 = "42"
		case the43 = "43"
		case the44 = "44"
		case the45 = "45"
		case the46 = "46"
		case the47 = "47"
		case the48 = "48"
		case the49 = "49"
		case the50 = "50"
		case the51 = "51"
		case the52 = "52"
		case the53 = "53"
		case the54 = "54"
		case the55 = "55"
		case the56 = "56"
		case the57 = "57"
		case the58 = "58"
		case the59 = "59"
		case the60 = "60"
		case the61 = "61"
		case the62 = "62"
		case the63 = "63"
		case the64 = "64"
		case the65 = "65"
		case the66 = "66"
		case the67 = "67"
		case the68 = "68"
		case the69 = "69"
		case the70 = "70"
		case the71 = "71"
		case the72 = "72"
		case the73 = "73"
		case the74 = "74"
		case the75 = "75"
		case the76 = "76"
		case the77 = "77"
		case the78 = "78"
		case the79 = "79"
		case the80 = "80"
		case the81 = "81"
		case the82 = "82"
		case the83 = "83"
		case the84 = "84"
		case the85 = "85"
		case the86 = "86"
		case the87 = "87"
		case the88 = "88"
		case the89 = "89"
		case the90 = "90"
		case the91 = "91"
		case the92 = "92"
		case the93 = "93"
		case the94 = "94"
		case the95 = "95"
		case the96 = "96"
		case the97 = "97"
		case the98 = "98"
		case the99 = "99"
		case the100 = "100"
		case the101 = "101"
		case the102 = "102"
		case the103 = "103"
		case currencyExchange = "CurrencyExchange"
	}
}

struct CurrencyExchange: Codable {
	let exchangeTypeStaticType: ExchangeTypeStaticType
	let sourceCurrency, targetCurrency, exchangeRate: String
	let direction: Direction
	let scaleCurrency: String
	let dateTime: Date

	enum CodingKeys: String, CodingKey {
		case exchangeTypeStaticType = "ExchangeTypeStaticType"
		case sourceCurrency, targetCurrency, exchangeRate, direction, scaleCurrency, dateTime
	}
}

enum Direction: String, Codable {
	case buy = "buy"
	case sell = "sell"
}

enum ExchangeTypeStaticType: String, Codable {
	case cashless = "Cashless"
}

struct The0: Codable {
	let serviceID: String
	let type: TypeInfo?
	let name: String
	let segment: Segment
	let url: String
	let currentStatus: CurrentStatusInfo
	let dateTime: Date
	let the0Description: String

	enum CodingKeys: String, CodingKey {
		case serviceID = "serviceId"
		case type, name, segment, url, currentStatus, dateTime
		case the0Description = "description"
	}
}

enum CurrentStatusInfo: String, Codable {
	case active = "Active"
	case inactive = "Inactive"
}

enum TypeInfo: String, Codable {
	case card = "Card"
	case currencyExchange = "CurrencyExchange"
	case deposit = "Deposit"
	case jewel = "Jewel"
	case loan = "Loan"
	case other = "Other"
	case transfer = "Transfer"
}
