//
//  Constants.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import Foundation
import UIKit
import CoreLocation

struct Constants {
	static let share = Constants()
	let screenSize = UIScreen.main.bounds
	let screenSizeWidth = UIScreen.main.bounds.width

	let navTitle = "Банкоматы"
	let urlATMsString = "https://belarusbank.by/open-banking/v1.0/atms"
	let urlInfoboxString = "https://belarusbank.by/api/infobox"
	let urlbBranchesString = "https://belarusbank.by/open-banking/v1.0/branches"

	let sideOffsetCell: CGFloat = (UIScreen.main.bounds.width - ((UIScreen.main.bounds.width/3)-40)*3)/3
	let cellOffset: CGFloat = 10
	let widthCell: CGFloat = (UIScreen.main.bounds.width/3)-(UIScreen.main.bounds.width/10)-3
	let heightCell: CGFloat = 250
	let cellHeight = 50
	let cellWidth = (UIScreen.main.bounds.width/3)-15
	let cellHeaderHeight: CGFloat = 100
	let cellHeaderWidth: CGFloat = (UIScreen.main.bounds.width-40)-80
	let sideOffset = 10
	let regionRadius: CLLocationDistance = 3000
}
