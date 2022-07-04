//
//  BranchesModel.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 1.03.22.
//

import Foundation

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

// MARK: - Branch
struct BranchElement: Codable, General {
	var coor: GeographicCoordinates?
	let itemID, type, cbu, accountNumber: String
	let equeue, wifi: Int
	var address: AddressBranch
	let information: InformationBranch
	let services: ServicesBranch

	enum CodingKeys: String, CodingKey {
		case itemID = "branchId"
		case type = "name"
		case cbu = "CBU"
		case accountNumber, equeue, wifi
		case address = "Address"
		case information = "Information"
		case services = "Services"
	}
}

// MARK: - Accessibilities
struct AccessibilitiesBranch: Codable {
	let accessibility: AccessibilityBranch

	enum CodingKeys: String, CodingKey {
		case accessibility = "Accessibility"
	}
}

// MARK: - Accessibility
struct AccessibilityBranch: Codable {
	let type, accessibilityDescription: String

	enum CodingKeys: String, CodingKey {
		case type
		case accessibilityDescription = "description"
	}
}

// MARK: - Address
struct AddressBranch: Codable {
	let streetName, buildingNumber, townName, countrySubDivision, country, addressDescription, addressLine: String
	var geolocation: Geolocation

	enum CodingKeys: String, CodingKey {
		case streetName, buildingNumber, townName, countrySubDivision, country, addressLine
		case addressDescription = "description"
		case geolocation = "GeoLocation"
	}
}

// MARK: - Information
struct InformationBranch: Codable {
	let segment: String
	let availability: AvailabilityBranch
	let contactDetails: ContactDetailsBranch

	enum CodingKeys: String, CodingKey {
		case segment
		case availability = "Availability"
		case contactDetails = "ContactDetails"
	}
}

// MARK: - Availability
struct AvailabilityBranch: Codable {
	let access24Hours, isRestricted, sameAsOrganization: Int
	let availabilityDescription: String
	let standardAvailability: StandardAvailabilityBranch

	enum CodingKeys: String, CodingKey {
		case access24Hours, isRestricted, sameAsOrganization
		case availabilityDescription = "description"
		case standardAvailability = "StandardAvailability"
	}
}

// MARK: - StandardAvailability
struct StandardAvailabilityBranch: Codable {
	let day: [DayBranch]

	enum CodingKeys: String, CodingKey {
		case day = "Day"
	}
}

// MARK: - Day
struct DayBranch: Codable {
	let dayCode: Int
	let openingTime, closingTime: String
	let dayBreak: BreakBranch

	enum CodingKeys: String, CodingKey {
		case dayCode, openingTime, closingTime
		case dayBreak = "Break"
	}
}

// MARK: - Break
struct BreakBranch: Codable {
	let breakFromTime, breakToTime: String
}

// MARK: - ContactDetails
struct ContactDetailsBranch: Codable {
	let name, phoneNumber, mobileNumber, faxNumber: String
	let emailAddress, other: String
	let socialNetworks: [SocialNetworkBranch]

	enum CodingKeys: String, CodingKey {
		case name, phoneNumber, mobileNumber, faxNumber, emailAddress, other
		case socialNetworks = "SocialNetworks"
	}
}

// MARK: - SocialNetwork
struct SocialNetworkBranch: Codable {
	let networkName: String
	let url: String
	let socialNetworkDescription: String

	enum CodingKeys: String, CodingKey {
		case networkName, url
		case socialNetworkDescription = "description"
	}
}

// MARK: - Services
struct ServicesBranch: Codable {
	let service: [ServiceBranch]
	let currencyExchange: [CurrencyExchangeBranch]

	enum CodingKeys: String, CodingKey {
		case service = "Service"
		case currencyExchange = "CurrencyExchange"
	}
}

// MARK: - CurrencyExchange
struct CurrencyExchangeBranch: Codable {
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

// MARK: - Service
struct ServiceBranch: Codable {
	let serviceID: String
	let type: String?
	let name: String
	let segment: String
	let url: String
	let currentStatus: String
	let dateTime: String
	let serviceDescription: String

	enum CodingKeys: String, CodingKey {
		case serviceID = "serviceId"
		case type, name, segment, url, currentStatus, dateTime
		case serviceDescription = "description"
	}
}
