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
  var atm: [ATM]

    enum CodingKeys: String, CodingKey {
        case atm = "ATM"
    }
}

// MARK: - ATM
struct ATM: Codable, General {
	var coor: GeographicCoordinates?
    let atmID: String
    let type: TypeEnum
    let baseCurrency, currency: Currency
    let cards: [Card]
    let currentStatus: CurrentStatus
    let address: Address
    let services: [Service]
    let availability: Availability
    let contactDetails: ContactDetails
    let accessibilities: Accessibilities?

    enum CodingKeys: String, CodingKey {
        case atmID = "atmId"
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
    let streetName, buildingNumber, townName: String
    let countrySubDivision: CountrySubDivision
    let country: Country
    let addressLine: String
    let addressDescription: AddressDescription
    let geolocation: Geolocation

    enum CodingKeys: String, CodingKey {
        case streetName, buildingNumber, townName, countrySubDivision, country, addressLine
        case addressDescription = "description"
        case geolocation = "Geolocation"
    }
}

enum AddressDescription: String, Codable {
    case внешний = "Внешний"
    case внутренний = "Внутренний"
    case уличный = "Уличный"
}

enum Country: String, Codable {
    case by = "BY"
}

enum CountrySubDivision: String, Codable {
    case брестская = "Брестская"
    case витебская = "Витебская"
    case гомельская = "Гомельская"
    case гродненская = "Гродненская"
    case минск = "Минск"
    case минская = "Минская"
    case могилевская = "Могилевская"
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
    let openingTime: OpeningTime
    let closingTime: ClosingTime
    let dayBreak: Break

    enum CodingKeys: String, CodingKey {
        case dayCode, openingTime, closingTime
        case dayBreak = "Break"
    }
}

enum ClosingTime: String, Codable {
    case the1300 = "13:00"
    case the1500 = "15:00"
    case the1545 = "15:45"
    case the1600 = "16:00"
    case the1615 = "16:15"
    case the1700 = "17:00"
    case the1730 = "17:30"
    case the1800 = "18:00"
    case the1900 = "19:00"
    case the2000 = "20:00"
    case the2100 = "21:00"
    case the2200 = "22:00"
    case the2300 = "23:00"
    case the2359 = "23:59"
    case the2400 = "24:00"
}

// MARK: - Break
struct Break: Codable {
    let breakFromTime: BreakFromTime
    let breakToTime: BreakToTime
}

enum BreakFromTime: String, Codable {
    case the0000 = "00:00"
    case the0200 = "02:00"
    case the0400 = "04:00"
    case the1100 = "11:00"
    case the1230 = "12:30"
    case the1345 = "13:45"
    case the1400 = "14:00"
    case the1500 = "15:00"
}

enum BreakToTime: String, Codable {
    case the0000 = "00:00"
    case the0700 = "07:00"
    case the0830 = "08:30"
    case the0900 = "09:00"
    case the1200 = "12:00"
    case the1315 = "13:15"
    case the1500 = "15:00"
    case the1700 = "17:00"
}

enum OpeningTime: String, Codable {
    case the0000 = "00:00"
    case the0430 = "04:30"
    case the0500 = "05:00"
    case the0600 = "06:00"
    case the0630 = "06:30"
    case the0700 = "07:00"
    case the0800 = "08:00"
    case the0830 = "08:30"
    case the0900 = "09:00"
    case the1000 = "10:00"
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

enum CurrentStatus: String, Codable {
    case off = "Off"
    case on = "On"
}

enum TypeEnum: String, Codable {
    case atm = "ATM"
}
