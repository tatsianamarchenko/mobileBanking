//
//  DetailedCollectionCollectionViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import MapKit

protocol General {
	var coor: GeographicCoordinates? {get set}
}

struct Section: General {
	var coor: GeographicCoordinates?
	var sectionName: String
	var rowData: [General]
}

class DetailedCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {
	public var complitionATM: ((AtmElement?) -> Void)?
	public var complitionBranch: ((BranchElement?) -> Void)?
	public var complitionInfobox: ((InfoBoxElement?) -> Void)?
	var sectionATM = [Section]()
	var sectionBranch = [Section]()
	var sectionInfobox = [Section]()
	var sections = [Section]()
	var section = [[Section]]()

	private lazy var internetErrorAlert: UIAlertController = {
		let alert = UIAlertController(title: "No access to internet connection",
									  message: "приложение не работает без доступа к интернету.",
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Повторить ещё раз", style: .default, handler: { _ in
			self.reloadData()
		}))
		return alert
	}()

	private lazy var spiner: UIActivityIndicatorView = {
		var spiner = UIActivityIndicatorView(style: .large)
		return spiner
	}()

	private lazy var collectionView: UICollectionView = {
		let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
		layout.scrollDirection = .vertical
		var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.register(DetailedCollectionViewCell.self,
								forCellWithReuseIdentifier: DetailedCollectionViewCell.reuseIdentifier)
		collectionView.register(SectionHeaderView.self,
								forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
								withReuseIdentifier: SectionHeaderView.reuseId)
		collectionView.clipsToBounds = true
		return collectionView
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView.delegate = self
		collectionView.dataSource = self

		let saveImage = UIImage(systemName: "arrow.counterclockwise")
		let filterImage = UIImage(systemName: "square.3.stack.3d")
		guard let saveImage = saveImage else {
			return
		}
		guard let filterImage = filterImage else {
			return
		}

		let imageButton = UIBarButtonItem(image: saveImage,
										  style: .plain,
										  target: self,
										  action: #selector(reloadDataAction))

		let filterButton = UIBarButtonItem(image: filterImage,
										   style: .plain,
										   target: self,
										   action: #selector(presentFilterList))

		navigationItem.rightBarButtonItems = [imageButton, filterButton]
		view.addSubview(collectionView)
		makeConstraints()
		infoLoading()
	}

	@objc func reloadDataAction(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		let group = DispatchGroup()
		group.enter()
		sender.isEnabled = false
		if sender.isEnabled == false {
			DispatchQueue.global().async {
				self.reloadData()
			}
			group.leave()
		}
		group.notify(queue: .global()) {
			sender.isEnabled = true
		}
	}

	private func reloadData() {
		DispatchQueue.main.async {
			self.sections.removeAll()
		//	let apiService = APIService()
			let group = DispatchGroup()
			self.view.isUserInteractionEnabled = false
			self.addSpinner()
			group.enter()
			DataFetcherService().fetchATMs {
				//			}
				//			apiService.getJSON(urlString: Constants.share.urlATMsString,
				//							   runQueue: .global(),
				//							   complitionQueue: .main)
				(result: Result<ATMResponse, CustomError>) in
				switch result {
				case .success(let atms) :
					self.sectionATM.removeAll()
					let sectionItems = Dictionary(grouping: atms.data.atm.sorted {$0.itemID <
						$1.itemID},
												  by: { String($0.address.townName) })
					for index in 0..<sectionItems.count {
						self.section[0].append(Section(sectionName: Array(sectionItems.keys)[index],
													   rowData: Array(sectionItems.values)[index]))
					}
					group.leave()
				case .failure(let error) :
					self.addingToSectionsSingle(array: self.sectionATM)
				}
			}

			group.notify(queue: .main) {
				self.addingToSections()
				self.collectionView.reloadData()
				self.view.isUserInteractionEnabled = true
				self.spiner.stopAnimating()
				self.spiner.removeFromSuperview()
			}

			DispatchQueue.global(qos: .userInteractive).async {
//				apiService.getJSON(urlString: Constants.share.urlInfoboxString,
//								   runQueue: .global(),
//								   complitionQueue: .main)
				DataFetcherService().fetchInfoboxes { (result: Result<[InfoBoxElement], CustomError>) in
					switch result {
					case .success(let infobox) :
						self.sectionBranch.removeAll()
						let sectionItems = Dictionary(grouping: infobox.sorted {$0.itemID! < $1.itemID!},
													  by: {$0.city!})
						for index in 0..<sectionItems.count {
							self.sectionInfobox.append(Section(sectionName: Array(sectionItems.keys)[index],
															   rowData: Array(sectionItems.values)[index]))
							self.section[1].append(Section(sectionName: Array(sectionItems.keys)[index],
														   rowData: Array(sectionItems.values)[index]))
						}
					case .failure(let error) :
						self.addingToSectionsSingle(array: self.sectionBranch)
					}
//					apiService.getJSON(urlString: Constants.share.urlInfoboxString,
//									   runQueue: .global(),
//									   complitionQueue: .main)
					DataFetcherService().fetchInfoboxes { (result: Result<[InfoBoxElement], CustomError>) in
						switch result {
						case .success(let infobox) :
							self.sectionInfobox.removeAll()
							let sectionItems = Dictionary(grouping: infobox.sorted {$0.itemID! < $1.itemID!},
														  by: {$0.city!})
							for index in 0..<sectionItems.count {
								self.sectionInfobox.append(Section(sectionName: Array(sectionItems.keys)[index],
																   rowData: Array(sectionItems.values)[index]))
								self.section[2].append(Section(sectionName: Array(sectionItems.keys)[index],
															   rowData: Array(sectionItems.values)[index]))
							}
						case .failure(let error) :
							self.addingToSectionsSingle(array: self.sectionInfobox)
						}
					}
				}
			}
			self.addingToSections()
			self.collectionView.reloadData()
		}
	}

	@objc func presentFilterList(_ sender: UIBarButtonItem) {
		let filterVC = FilterViewController()
		filterVC.modalPresentationStyle = .popover
		let popOverVc = filterVC.popoverPresentationController
		popOverVc?.delegate = self
		popOverVc?.sourceView = self.collectionView
		popOverVc?.sourceRect = CGRect(x: view.frame.midX,
									   y: sender.accessibilityFrame.minY,
									   width: 0,
									   height: 0)
		filterVC.preferredContentSize = CGSize(width: 200, height: 150)
		self.present(filterVC, animated: true)
		filterVC.complition = { annotation in
			if let annotation = annotation {
				self.filter(index: annotation)
			}
		}
	}

	func filter(index: Int) {
		if 	filteredArray[index].isChecked == true {
			if index == 0 {
				addingToSectionsSingle(array: self.savedSectionATM)
				collectionView.reloadData()
			} else if index == 1 {
				addingToSectionsSingle(array: self.savedSectionInfobox)
				collectionView.reloadData()
			} else if index == 2 {
				addingToSectionsSingle(array: self.savedSectionBranch)
				collectionView.reloadData()
			}
		} else if filteredArray[index].isChecked == false {
			if index == 0 {
				sectionATM = [Section]()
				addingToSections()
				collectionView.reloadData()
			} else if index == 1 {
				sectionInfobox = [Section]()
				addingToSections()
				collectionView.reloadData()
			} else if index == 2 {
				sectionBranch = [Section]()
				sectionBranch.removeAll()
				addingToSections()
				collectionView.reloadData()
			}
		}
	}

	private func addSpinner() {
		view.addSubview(spiner)
		DispatchQueue.main.async {
			self.spiner.startAnimating()
			self.spiner.snp.makeConstraints { (make) -> Void in
				make.centerY.equalToSuperview()
				make.centerX.equalToSuperview()
			}
		}
	}

	func infoLoading() {
	//	let apiService = APIService()
		var errorString: String?
		let group = DispatchGroup()
		view.isUserInteractionEnabled = false
		section = [sectionATM, sectionInfobox, sectionBranch]
		addSpinner()
		group.enter()
		//	let minskCoordinates = GeographicCoordinates(latitude: "52.425163", longitude: "31.015039")
//		apiService.getJSON(urlString: Constants.share.urlATMsString,
//						   runQueue: .global(),
//						   complitionQueue: .main)
		DataFetcherService().fetchATMs { [self] (result: Result<ATMResponse, CustomError>) in
			switch result {
			case .success(var atms) :

				for i in 0..<atms.data.atm.count {
					atms.data.atm[i].coor = GeographicCoordinates(latitude: atms.data.atm[i].address.geolocation.geographicCoordinates.latitude,
																  longitude: atms.data.atm[i].address.geolocation.geographicCoordinates.longitude)
				}

				let sectionItems = Dictionary(grouping: atms.data.atm,
											  by: { String($0.address.townName) })
				for index in 0..<sectionItems.count {
					self.section[0].append(Section(coor: Array(sectionItems.values)[index].first?.coor,
												   sectionName: Array(sectionItems.keys)[index],
												   rowData: Array(sectionItems.values)[index]))	}
				//	print(section[0].first?.sectionName, 	print(section[0].first?.coor!) )
				section[0].sort { $0.sectionName > $1.sectionName }
				print(section[0].first?.sectionName)
				sectionATM = section[0]
				group.leave()
			case .failure(let error) :
				if	error == .errorGeneral {
					DispatchQueue.main.async {
						if errorString != nil {
							errorString?.append(" Банкоматы ")} else {
								errorString = ""
								errorString?.append(" Банкоматы ")}
					}
					group.leave()
				} else {
					present(self.internetErrorAlert, animated: true)
					group.leave()
				}
			}
		}

		group.enter()
//		apiService.getJSON(urlString: Constants.share.urlInfoboxString,
//						   runQueue: .global(),
//						   complitionQueue: .main)
		DataFetcherService().fetchInfoboxes { [self] (result: Result<[InfoBoxElement], CustomError>) in
			switch result {
			case .success(var infobox) :

				for i in 0..<infobox.count {
					infobox[i].coor = GeographicCoordinates(latitude: infobox[i].gpsX!, longitude: infobox[i].gpsY!)
				}

				let sectionItems = Dictionary(grouping: infobox, by: {$0.city!})
				for index in 0..<sectionItems.count {
					self.section[1].append(Section(coor: Array(sectionItems.values)[index].first?.coor,
												   sectionName: Array(sectionItems.keys)[index],
												   rowData: Array(sectionItems.values)[index]))
				}
				section[1].sort { $0.sectionName > $1.sectionName }
				sectionInfobox = section[1]
				group.leave()
			case .failure(let error) :
				if	error == .errorGeneral {
					DispatchQueue.main.async {
						if errorString != nil {
							errorString?.append(" Инфокиоски ")} else {
								errorString = ""
								errorString?.append(" Инфокиоски ")}
					}
					group.leave()
				} else {
					present(internetErrorAlert, animated: true)
					group.leave()
				}
			}
		}

		group.enter()
//		apiService.getJSON(urlString: Constants.share.urlbBranchesString,
//						   runQueue: .global(),
//						   complitionQueue: .main)
		DataFetcherService().fetchBranches { [self] (result: Result<Branch, CustomError>) in
			switch result {
			case .success(var branch) :

				for i in 0..<branch.data.branch.count {
					branch.data.branch[i].coor = GeographicCoordinates(latitude:
																		branch.data.branch[i].address.geolocation.geographicCoordinates.latitude,
																	   longitude: branch.data.branch[i].address.geolocation.geographicCoordinates.longitude)
				}
				let sectionItems = Dictionary(grouping: branch.data.branch, by: { String($0.address.townName) })
				for index in 0..<sectionItems.count {
					self.section[2].append(Section(coor: Array(sectionItems.values)[index].first?.coor,
												   sectionName: Array(sectionItems.keys)[index],
												   rowData: Array(sectionItems.values)[index]))
				}
				section[2].sort { $0.sectionName > $1.sectionName}
				sectionBranch = section[2]
				group.leave()
			case .failure(let error) :
				if	error == .errorGeneral {
					DispatchQueue.main.async {
						if errorString != nil {
							errorString?.append(" Отделения банка ")} else {
								errorString = ""
								errorString?.append(" Отделения банка ")}
					}
					group.leave()
				} else {
					present(internetErrorAlert, animated: true)
					group.leave()
				}
			}
		}

		group.notify(queue: .main) {
			if let errorString = errorString {
				DispatchQueue.main.async { [self] in
					let alert = createErrorAlert(errorString: errorString)
					present(alert, animated: true)
				}
			}
			self.finalView()
		}
	}

	func finalView() {
		self.view.isUserInteractionEnabled = true
		self.addingToSections()

		self.spiner.stopAnimating()
		self.spiner.removeFromSuperview()
		self.collectionView.reloadData()
	}

	private func addingToSections() {
		self.sections = [Section]()
		var arr = [Section]()
		section = [sectionATM, sectionInfobox, sectionBranch]
		arr.append(contentsOf: sectionATM)
		arr.append(contentsOf: sectionInfobox)
		arr.append(contentsOf: sectionBranch)
		let minskCoordinates = GeographicCoordinates(latitude: "52.425163", longitude: "31.015039")
		let a = Dictionary(grouping: arr,
						   by: {String($0.sectionName) })
		for i in 0..<a.keys.count {
			self.sections.append(Section(coor: Array(a.values)[i].first?.coor,
										 sectionName: Array(a.keys)[i],
										 rowData: Array(a.values)[i]))
		//	print(Array(a.values)[i].first?.coor)
		}
		sections.sort {
			var item1 = $0.rowData
			var item2 = $1.rowData
			return item1.sort { $0.coor! > $1.coor! } > item2.sort { $0.coor! > $1.coor! }
		}

		if !sectionATM.isEmpty {
			savedSectionATM = sectionATM}
		if !sectionBranch.isEmpty {
			savedSectionBranch = sectionBranch}
		if !sectionInfobox.isEmpty { savedSectionInfobox = sectionInfobox}
	}

	var savedSectionATM = [Section]()
	var savedSectionBranch =  [Section]()
	var savedSectionInfobox  =  [Section]()

	private func addingToSectionsSingle(array: [Section]) {
		let a = Dictionary(grouping: array,
						   by: {String($0.sectionName) })
		for i in 0..<a.keys.count {
			self.sections.append(Section(sectionName: Array(a.keys)[i], rowData: Array(a.values)[i]))
		}
	}

	private func makeConstraints() {
		collectionView.snp.makeConstraints { (make) -> Void in
			make.leading.trailing.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
	}

	private func createErrorAlert (errorString: String) -> UIAlertController {
		let alert = UIAlertController(title: "No access to internet connection",
									  message: "не удалось загрузить  \(errorString)",
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Повторить ещё раз", style: .default, handler: { _ in
			self.reloadData()
		}))
		return alert
	}
}

extension DetailedCollectionViewController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		.none
	}
}

extension DetailedCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {

	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.sections[section].rowData.count
	}

	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.sections.count
	}

	func collectionView(_ collectionView: UICollectionView,
						cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
																DetailedCollectionViewCell.reuseIdentifier, for: indexPath)
				as? DetailedCollectionViewCell else {
			return UICollectionViewCell()
		}

		if let item = self.sections[indexPath.section].rowData[indexPath.row] as? Section {
			let q = item.rowData as [General]
			if let infobox = q as? [InfoBoxElement] {
				for i in 0..<infobox.count {
					let infobox = infobox[i]
					cell.timeLabel.text = infobox.workTime!
					cell.placeLabel.text =  infobox.city
					cell.currancyLabel.text = infobox.currency
				}
			}
			if	let atm = q as? [AtmElement] {
				for i in 0..<atm.count {
					let atm = atm[i]
					cell.timeLabel.text = atm.availability.standardAvailability.day[0].openingTime
					+ " " + atm.availability.standardAvailability.day[0].closingTime
					cell.placeLabel.text =  atm.address.addressLine
					+ " " + atm.address.buildingNumber
					+ " " + atm.address.addressLine
					cell.currancyLabel.text = atm.currency.rawValue
				}
			}

			if let branch = q as? [BranchElement] {
				for i in 0..<branch.count {
					let branch = branch[i]
					cell.timeLabel.text = branch.information.availability.standardAvailability.day[0].openingTime
					+ "-" +
					branch.information.availability.standardAvailability.day[0].closingTime
					cell.placeLabel.text =  branch.address.streetName
					+ " " + branch.address.buildingNumber
					+ " " + branch.address.addressLine
					cell.currancyLabel.text = String( branch.services.currencyExchange.count)
				}
			}
		}
		return cell
	}

	func collectionView(_ collectionView: UICollectionView,
						viewForSupplementaryElementOfKind kind: String,
						at indexPath: IndexPath) -> UICollectionReusableView {
		guard let cell = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind,
																			  withReuseIdentifier: SectionHeaderView.reuseId,
																			  for: indexPath) as? SectionHeaderView
		else {
			return UICollectionReusableView()
		}

		cell.setTitle(title: self.sections[indexPath.section].sectionName)
		return cell
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						referenceSizeForHeaderInSection section: Int) -> CGSize {
		return CGSize(width: Constants.share.cellHeaderWidth, height: Constants.share.cellHeaderHeight)
	}

	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		navigationController?.popToRootViewController(animated: true)
		if let item = self.sections[indexPath.section].rowData[indexPath.row] as? Section {
			let q = item.rowData as [General]
			if let atm = q as? [AtmElement] {
				complitionATM?(atm[indexPath.item])
			} else if let infobox = q as? [InfoBoxElement] {
				complitionInfobox?(infobox[indexPath.item])
			} else if let branch = q as? [BranchElement] {
				complitionBranch?(branch[indexPath.item])
			}
		}
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: Constants.share.widthCell, height: Constants.share.heightCell)
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 1
	}
	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return Constants.share.cellOffset
	}

	func collectionView(_ collectionView: UICollectionView,
						layout collectionViewLayout: UICollectionViewLayout,
						insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: Constants.share.cellOffset, left: Constants.share.sideOffsetCell, bottom: Constants.share.cellOffset, right: Constants.share.sideOffsetCell)
	}
}
