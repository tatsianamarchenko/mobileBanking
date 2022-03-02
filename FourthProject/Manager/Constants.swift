//
//  Constants.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import Foundation
import UIKit
import CoreLocation

let screenSize = UIScreen.main.bounds
let screenSizeWidth = UIScreen.main.bounds.width

let navTitle = "Банкоматы"
let urlATMsString = "https://belarusbank.by/open-banking/v1.0/atms"
let urlInfoboxString = "https://belarusbank.by/api/infobox"
let urlbBranchesString = "https://belarusbank.by/open-banking/v1.0/branches"

let sideOffsetCell: CGFloat = (screenSize.width - ((screenSize.width/3)-40)*3)/3
let cellOffset: CGFloat = 10
let widthCell: CGFloat = (screenSize.width/3)-(screenSize.width/10)-3
let heightCell: CGFloat = 250
let cellHeight = 50
let cellWidth = (screenSizeWidth/3)-15
let cellHeaderHeight: CGFloat = 100
let cellHeaderWidth: CGFloat = (screenSize.width-40)-80
let sideOffset = 10
let regionRadius: CLLocationDistance = 3000
