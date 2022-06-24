//
//  BankomatsModel.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import Foundation

struct ATMResponse: Codable {
    var data: DataInfo

    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}
// MARK: - DataClass
struct DataInfo: Codable {
  var atm: [AtmElement]

    enum CodingKeys: String, CodingKey {
        case atm = "ATM"
    }
}

// MARK: - ATM
struct AtmElement: Codable, General {
	var coor: GeographicCoordinates?
    let itemID: String
    let type: String
    let baseCurrency, currency: Currency
    let cards: [Card]
    let currentStatus: String
    let address: Address
    let services: [Service]
    let availability: Availability
    let contactDetails: ContactDetails
    let accessibilities: Accessibilities?

    enum CodingKeys: String, CodingKey {
        case itemID = "atmId"
        case type, baseCurrency, currency, cards, currentStatus
        case address = "Address"
        case services = "Services"
        case availability = "Availability"
        case contactDetails = "ContactDetails"
        case accessibilities = "Accessibilities"
    }
}

// MARK: - Accessibilities
struct Accessibilities: Codable {
    let accessibility: [Service]

    enum CodingKeys: String, CodingKey {
        case accessibility = "Accessibility"
    }
}

// MARK: - Service
struct Service: Codable {
    let serviceType: ServiceType
    let serviceDescription: ServiceDescription

    enum CodingKeys: String, CodingKey {
        case serviceType
        case serviceDescription = "description"
    }
}

enum ServiceDescription: String, Codable {
    case cashByCode = "CashByCode"
    case cashByCodeINF = "CashByCode, INF"
    case empty = ""
    case толькоПоКарточкамБанковРезидентов = "Только по карточкам банков-резидентов"
    case толькоПоКарточкамОАОАСББеларусбанк = "Только по карточкам ОАО \"АСБ Беларусбанк\""
}

enum ServiceType: String, Codable {
    case audioCashMachine = "AudioCashMachine"
    case balance = "Balance"
    case billPayments = "BillPayments"
    case braille = "Braille"
    case cashIn = "CashIn"
    case cashWithdrawal = "CashWithdrawal"
    case miniStatement = "MiniStatement"
    case other = "Other"
    case pinActivation = "PINActivation"
    case pinChange = "PINChange"
    case pinUnblock = "PINUnblock"
}

// MARK: - Address
struct Address: Codable {
    let streetName, buildingNumber, townName, countrySubDivision, country, addressLine, addressDescription: String
    var geolocation: Geolocation

    enum CodingKeys: String, CodingKey {
        case streetName, buildingNumber, townName, countrySubDivision, country, addressLine
        case addressDescription = "description"
        case geolocation = "Geolocation"
    }
}

// MARK: - Geolocation
struct Geolocation: Codable {
    let geographicCoordinates: GeographicCoordinates

    enum CodingKeys: String, CodingKey {
        case geographicCoordinates = "GeographicCoordinates"
    }
}

// MARK: - GeographicCoordinates
struct GeographicCoordinates: Codable, Comparable {
  static func < (lhs: GeographicCoordinates, rhs: GeographicCoordinates) -> Bool {
	lhs.latitude > rhs.latitude && lhs.longitude > rhs.longitude
  }

    let latitude, longitude: String
}

// MARK: - Availability
struct Availability: Codable {
    let access24Hours, isRestricted, sameAsOrganization: Bool
    let standardAvailability: StandardAvailability

    enum CodingKeys: String, CodingKey {
        case access24Hours, isRestricted, sameAsOrganization
        case standardAvailability = "StandardAvailability"
    }
}

// MARK: - StandardAvailability
struct StandardAvailability: Codable {
    let day: [Day]

    enum CodingKeys: String, CodingKey {
        case day = "Day"
    }
}

// MARK: - Day
struct Day: Codable {
    let dayCode: String
    let openingTime: String
    let closingTime: String
    let dayBreak: Break

    enum CodingKeys: String, CodingKey {
        case dayCode, openingTime, closingTime
        case dayBreak = "Break"
    }
}

// MARK: - Break
struct Break: Codable {
    let breakFromTime: String
    let breakToTime: String
}

enum Currency: String, Codable {
    case byn = "BYN"
    case bynUsd = "BYN/USD"
}

enum Card: String, Codable {
    case belkart = "BELKART"
    case mir = "MIR"
    case unionPay = "UnionPay"
    case visa = "VISA"
}

// MARK: - ContactDetails
struct ContactDetails: Codable {
    let phoneNumber: String
}
