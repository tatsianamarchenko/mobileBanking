//
//  DetailedCollectionCollectionViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import MapKit

class DetailedCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {

  public var complition: ((ATM?) -> Void)?

  struct Section {
    var sectionName: String
    var rowData: [ATM]
  }
  var sections = [Section]()

  private lazy var spiner: UIActivityIndicatorView = {
    var spiner = UIActivityIndicatorView(style: .large)
    spiner.translatesAutoresizingMaskIntoConstraints = false
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
    view.addSubview(spiner)

makeConstraints()

    DispatchQueue.main.async {
      self.spiner.startAnimating()
			self.spiner.snp.makeConstraints { (make) -> Void in
        make.centerY.equalToSuperview()
        make.centerX.equalToSuperview()
      }
    }
    let apiService = APIService(urlString: urlString)
    apiService.getJSON { [weak self] result in
      switch result {
      case .success(let atms) :
        let sectionItems = Dictionary(grouping: atms.data.atm.sorted {$0.atmID < $1.atmID},
                                      by: { String($0.address.townName) })
        for index in 0..<sectionItems.count {
          self?.sections.append(Section(sectionName: Array(sectionItems.keys)[index],
                                        rowData: Array(sectionItems.values)[index]))
        }
        DispatchQueue.main.async {
          self?.spiner.stopAnimating()
          self?.spiner.removeFromSuperview()
          self?.collectionView.reloadData()
        }
      case .failure(let error) :
        print(error)
      }
    }
  }
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
    cell.timeLabel.text = self.sections[indexPath.section]
      .rowData[indexPath.row].availability.standardAvailability.day[0]
      .openingTime.rawValue
    + "-" +
    self.sections[indexPath.section].rowData[indexPath.row].availability.standardAvailability.day[0]
      .closingTime.rawValue
    cell.placeLabel.text =  self.sections[indexPath.section].rowData[indexPath.row].address.streetName
    + " " + self.sections[indexPath.section].rowData[indexPath.row].address.buildingNumber
    + " " + self.sections[indexPath.section].rowData[indexPath.row].address.addressLine
    cell.currancyLabel.text = self.sections[indexPath.section].rowData[indexPath.row].currency.rawValue
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

    return CGSize(width:cellHeaderWidth, height: cellHeaderHeight)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    navigationController?.popToRootViewController(animated: true)
    let item = sections[indexPath.section].rowData[indexPath.row]
    complition?(item)
    
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
