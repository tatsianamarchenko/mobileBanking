//
//  BranchesModel.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 1.03.22.
//

import Foundation

// MARK: - Branch
struct Branch: Codable {
	var data: DataClass

	enum CodingKeys: String, CodingKey {
		case data = "Data"
	}
}

// MARK: - DataClass
struct DataClass: Codable {
	var branch: [BranchElement]

	enum CodingKeys: String, CodingKey {
		case branch = "Branch"
	}
}

// MARK: - BranchElement
struct BranchElement: Codable, General {
	var coor: GeographicCoordinates?
	
  let branchID, name: String
  let cbu, accountNumber: String?
  let equeue, wifi: Int
  let accessibilities: AccessibilitiesInfo
  let address: AddressInfo
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

// MARK: - AccessibilitiesInfo
struct AccessibilitiesInfo: Codable {
	let accessibility: Accessibility

	enum CodingKeys: String, CodingKey {
		case accessibility = "Accessibility"
	}
}

// MARK: - Accessibility
struct Accessibility: Codable {
	let type: TypeUnion
	let accessibilityDescription: String

	enum CodingKeys: String, CodingKey {
		case type
		case accessibilityDescription = "description"
	}
}

enum TypeUnion: Codable {
	case integer(Int)
	case string(String)

	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if let x = try? container.decode(Int.self) {
			self = .integer(x)
			return
		}
		if let x = try? container.decode(String.self) {
			self = .string(x)
			return
		}
		throw DecodingError.typeMismatch(TypeUnion.self,
										 DecodingError.Context(codingPath: decoder.codingPath,
															   debugDescription: "Wrong type for TypeUnion"))
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
		case .integer(let x):
			try container.encode(x)
		case .string(let x):
			try container.encode(x)
		}
	}
}

// MARK: - AddressInfo
struct AddressInfo: Codable {
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

// MARK: - GeoLocationInfo
struct GeoLocationInfo: Codable {
	let geographicCoordinates: GeographicCoordinatesInfo

	enum CodingKeys: String, CodingKey {
		case geographicCoordinates = "GeographicCoordinates"
	}
}

// MARK: - GeographicCoordinates
struct GeographicCoordinatesInfo: Codable {
	let latitude, longitude: String
}

// MARK: - Information
struct Information: Codable {
	let segment: String
	let availability: AvailabilityInfo
	let contactDetails: ContactDetailsInfo

	enum CodingKeys: String, CodingKey {
		case segment
		case availability = "Availability"
		case contactDetails = "ContactDetails"
	}
}

// MARK: - AvailabilityInfo
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

// MARK: - NonStandardAvailability
struct NonStandardAvailability: Codable {
	let name: String
	let fromDate, toDate: String
	let nonStandardAvailabilityDescription: String
	let day: NonStandardAvailabilityDay

	enum CodingKeys: String, CodingKey {
		case name, fromDate, toDate
		case nonStandardAvailabilityDescription = "description"
		case day = "Day"
	}
}

// MARK: - NonStandardAvailabilityDay
struct NonStandardAvailabilityDay: Codable {
	let dayCode, openingTime, closingTime: String
	let dayBreak: BreakInfo

	enum CodingKeys: String, CodingKey {
		case dayCode, openingTime, closingTime
		case dayBreak = "Break"
	}
}

// MARK: - BreakInfo
struct BreakInfo: Codable {
	let breakFromTime, breakToTime: String
}

// MARK: - StandardAvailability
struct StandardAvailabilityInfo: Codable {
	let day: [DayElement]

	enum CodingKeys: String, CodingKey {
		case day = "Day"
	}
}

// MARK: - DayElement
struct DayElement: Codable {
	let dayCode: Int
	let openingTime, closingTime: String
	let dayBreak: BreakInfo

	enum CodingKeys: String, CodingKey {
		case dayCode, openingTime, closingTime
		case dayBreak = "Break"
	}
}

// MARK: - ContactDetailsInfo
struct ContactDetailsInfo: Codable {
	let name, phoneNumber, mobileNumber, faxNumber: String
	let emailAddress, other: String
	let socialNetworks: [SocialNetwork]

	enum CodingKeys: String, CodingKey {
		case name, phoneNumber, mobileNumber, faxNumber, emailAddress, other
		case socialNetworks = "SocialNetworks"
	}
}

// MARK: - SocialNetwork
struct SocialNetwork: Codable {
	let networkName: String
	let url: String
	let socialNetworkDescription: String

	enum CodingKeys: String, CodingKey {
		case networkName, url
		case socialNetworkDescription = "description"
	}
}

// MARK: - Services
struct Services: Codable {
	let service: ServiceInfo

	enum CodingKeys: String, CodingKey {
		case service = "Service"
	}
}

// MARK: - Service
struct ServiceInfo: Codable {
	let currencyExchange: [CurrencyExchange]

	enum CodingKeys: String, CodingKey {
		case currencyExchange = "CurrencyExchange"
	}
}

// MARK: - CurrencyExchange
struct CurrencyExchange: Codable {
	let exchangeTypeStaticType: String
	let sourceCurrency, targetCurrency, exchangeRate: String
	let direction: String
	let scaleCurrency: String
	let dateTime: String

	enum CodingKeys: String, CodingKey {
		case exchangeTypeStaticType = "ExchangeTypeStaticType"
		case sourceCurrency, targetCurrency, exchangeRate, direction, scaleCurrency, dateTime
	}
}
// MARK: - The0
struct The0: Codable {
	let serviceID: String
	let type: String?
	let name: String
	let segment: String
	let url: String
	let currentStatus: String
	let dateTime: Date
	let the0Description: String

	enum CodingKeys: String, CodingKey {
		case serviceID = "serviceId"
		case type, name, segment, url, currentStatus, dateTime
		case the0Description = "description"
	}
}
