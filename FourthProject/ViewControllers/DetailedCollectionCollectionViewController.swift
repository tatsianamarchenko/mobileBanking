//
//  DetailedCollectionCollectionViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import MapKit

class DetailedCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {

  struct Section {
    var sectionName: String
    var rowData: [ATM]
  }
  var sections = [Section]()

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

    collectionView.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview()
      make.bottom.equalToSuperview()
    }

    let apiService = APIService(urlString: "https://belarusbank.by/open-banking/v1.0/atms")
    apiService.getJSON { [self] (atms: ATMResponse) in
      let sectionItems = Dictionary(grouping: atms.data.atm.sorted {$0.atmID < $1.atmID},
                                    by: { String($0.address.townName) })
      for index in 0..<sectionItems.count {
        sections.append(Section(sectionName: Array(sectionItems.keys)[index],
                                rowData: Array(sectionItems.values)[index]))
      }
      DispatchQueue.main.async {
        self.collectionView.reloadData()
      }
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
    cell.timeLabel.text = self.sections[indexPath.section].rowData[indexPath.row].availability.standardAvailability.day[0]
      .openingTime.rawValue
    + "-" +
    self.sections[indexPath.section].rowData[indexPath.row].availability.standardAvailability.day[0]
      .closingTime.rawValue
    cell.placeLabel.text =  self.sections[indexPath.section].rowData[indexPath.row].address.streetName + ", " + self.sections[indexPath.section].rowData[indexPath.row].address.buildingNumber
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
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width-40
    return CGSize(width: screenWidth-80, height: 100)
  }

  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    dismiss(animated: true)
    let item = sections[indexPath.section].rowData[indexPath.row]
    let coor = CLLocation(latitude:
                            Double(item.address.geolocation.geographicCoordinates.latitude)!,
                          longitude: Double(item.address.geolocation.geographicCoordinates.longitude)!)
    let atmVc = MainViewController(coor: coor, atm: item)
  //  atmVc.modalPresentationStyle = .fullScreen
   atmVc.title = "Банкоматы"
  //  navigationController?.present(atmVc, animated: true)
   navigationController?.pushViewController(atmVc, animated: true)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: (screenSize.width/3)-15, height: 150)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
  }
}
