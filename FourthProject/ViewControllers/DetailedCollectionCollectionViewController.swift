//
//  DetailedCollectionCollectionViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import MapKit

protocol General {
}

class DetailedCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {

  public var complition: ((ATM?) -> Void)?

  struct Section: General {
    var sectionName: String
	var rowData: [General]
  }

  var sections = [Section]()

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

	view.addSubview(collectionView)
	makeConstraints()
	infoLoading()
  }

  func infoLoading() {
	let apiService = APIService()
	let group = DispatchGroup()
	view.isUserInteractionEnabled = false
	view.addSubview(spiner)
	self.spiner.startAnimating()
	self.spiner.snp.makeConstraints { (make) -> Void in
	  make.centerY.equalToSuperview()
	  make.centerX.equalToSuperview()
	}

	group.enter()
	apiService.getJSON(urlString: urlATMsString,
					   runQueue: .global(),
					   complitionQueue: .main) {(atms: ATMResponse) in
	  let sectionItems = Dictionary(grouping: atms.data.atm.sorted {$0.atmID < $1.atmID},
									by: { String($0.address.townName) })
	  for index in 0..<sectionItems.count {
		self.section.append(Section(sectionName: Array(sectionItems.keys)[index],
									rowData: Array(sectionItems.values)[index]))
	  }

	  group.leave()
	}
	group.enter()
	apiService.getJSON(urlString: urlInfoboxString,
					   runQueue: .global(),
					   complitionQueue: .main) { (infobox: [InfoBox]) in
	  let sectionItems = Dictionary(grouping: infobox.sorted {$0.infoID! < $1.infoID!},
									by: {$0.city!})
	  for index in 0..<sectionItems.count {
		self.section.append(Section(sectionName: Array(sectionItems.keys)[index],
									rowData: Array(sectionItems.values)[index]))
	  }

	  group.leave()
	}
	group.enter()
	apiService.getJSON(urlString: urlbBranchesString,
					   runQueue: .global(),
					   complitionQueue: .main) { (branch: Branch) in
	  let sectionItems = Dictionary(grouping: branch.data.branch.sorted {$0.branchID < $1.branchID },
									by: { String($0.address.townName) })

	  for index in 0..<sectionItems.count {
		self.section.append(Section(sectionName: Array(sectionItems.keys)[index],
									rowData: Array(sectionItems.values)[index]))
	  }

	  group.leave()
	}

	group.notify(queue: .main) {
	  self.view.isUserInteractionEnabled = true
	  let a = Dictionary(grouping: self.section,
						 by: {String($0.sectionName) })
	  for i in 0..<a.keys.count {
		self.sections.append(Section(sectionName: Array(a.keys)[i], rowData: Array(a.values)[i]))
	  }
	  self.spiner.stopAnimating()
	  self.spiner.removeFromSuperview()
	  self.collectionView.reloadData()
	}
  }

  var section = [Section]()

func	makeConstraints() {
		collectionView.snp.makeConstraints { (make) -> Void in
			make.leading.trailing.equalToSuperview()
			make.top.equalToSuperview()
			make.bottom.equalToSuperview()
		}
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

	  if let infobox = q as? [InfoBox] {
		for i in 0..<infobox.count {
		  let infobox = infobox[i]
		  cell.timeLabel.text = "infobox" + infobox.workTime!
		  cell.placeLabel.text =  infobox.city
		  cell.currancyLabel.text = infobox.currency?.rawValue
		}
	  }
	  if	let atm = q as? [ATM] {
		for i in 0..<atm.count {
		  let atm = atm[i]
		  cell.timeLabel.text = "atm"
		  cell.placeLabel.text =  atm.address.addressLine
		  + " " + atm.address.buildingNumber
		  + " " + atm.address.addressLine
		  cell.currancyLabel.text = atm.currency.rawValue
		}
	  }

	  if let branch = q as? [BranchElement] {
		for i in 0..<branch.count {
		  let branch = branch[i]
		  cell.timeLabel.text = "branch" + branch.information.availability.standardAvailability.day[0].openingTime
		  + "-" +
		  branch.information.availability.standardAvailability.day[0].closingTime
		  cell.placeLabel.text =  branch.address.streetName
		  + " " + branch.address.buildingNumber
		  + " " + branch.address.addressLine
		  cell.currancyLabel.text = String( branch.services.service.currencyExchange.count)
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

    return CGSize(width: cellHeaderWidth, height: cellHeaderHeight)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
	navigationController?.popToRootViewController(animated: true)
	// let item = sections[indexPath.section].rowData[indexPath.row]

	if let item = self.sections[indexPath.section].rowData[indexPath.row] as? Section {
	  let q = item.rowData as [General]
	  if let atm = q as? [ATM] {
		complition?(atm[indexPath.row])
	  }
	}
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: widthCell, height: heightCell)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return cellOffset
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: cellOffset, left: sideOffsetCell, bottom: cellOffset, right: sideOffsetCell)
  }
}
