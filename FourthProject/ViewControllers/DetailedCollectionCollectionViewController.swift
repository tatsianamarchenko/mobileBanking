//
//  DetailedCollectionCollectionViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit

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
    collectionView.register(SelectIconHeaderViewCell.self,
                            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                            withReuseIdentifier: SelectIconHeaderViewCell.reuseId)
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
      let sectionItems = Dictionary(grouping: atms.data.atm.sorted {$0.atmID < $1.atmID}, by: { String($0.address.townName) })
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
    cell.timeLabel.text = self.sections[indexPath.section].rowData[indexPath.row].atmID
    cell.placeLabel.text =  self.sections[indexPath.section].rowData[indexPath.row].address.townName
    cell.currancyLabel.text = self.sections[indexPath.section].rowData[indexPath.row].address.addressLine
    return cell
  }

  func collectionView(_ collectionView: UICollectionView,
                      viewForSupplementaryElementOfKind kind: String,
                      at indexPath: IndexPath) -> UICollectionReusableView {
    guard let cell = self.collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                          withReuseIdentifier: SelectIconHeaderViewCell.reuseId,
                                                                          for: indexPath) as? SelectIconHeaderViewCell
    else {
      return UICollectionReusableView()
    }
    cell.initializeUI()

    cell.setTitle(title: self.sections[indexPath.section].sectionName)
    return cell
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      referenceSizeForHeaderInSection section: Int) -> CGSize {
    let screenSize = UIScreen.main.bounds
    let screenWidth = screenSize.width-40
    return CGSize(width: screenWidth-80, height: 50)
  }

//  func collectionView(_ collectionView: UICollectionView,
//                      willDisplay cell: UICollectionViewCell,
//                      forItemAt indexPath: IndexPath) {
//    let lastElement = arrayOfATMs.count - 1
//    if indexPath.row == lastElement {
      // handle your logic here to get more items, add it to dataSource and reload tableview
//
//    }
//  }

  // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
  func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
    return false
  }

  func collectionView(_ collectionView: UICollectionView,
                      canPerformAction action: Selector,
                      forItemAt indexPath: IndexPath,
                      withSender sender: Any?) -> Bool {
    return true
  }

  func collectionView(_ collectionView: UICollectionView,
                      performAction action: Selector,
                      forItemAt indexPath: IndexPath, withSender sender: Any?) {

  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: 100, height: 100)
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 1
  }

  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 1, left: 1, bottom: 1, right: 1)
  }

}
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
  override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

class SelectIconHeaderViewCell: UICollectionViewCell {

  static var reuseId = "reuseId"

  var title: UILabel = {
    var lable = UILabel()
    lable.textColor = .systemPink
    lable.numberOfLines = 1
    return lable
  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  func initializeUI() {

    self.addSubview(title)
    backgroundColor = .systemMint

    title.snp.makeConstraints { (make) in
      make.leading.equalTo(contentView.snp_leadingMargin).inset(30)
      make.top.equalTo(contentView).offset(20)
    }
  }

  func setTitle(title: String) {
    self.title.text = title
  }
}

//  self.arrayOfATMs = atms.data.atm

//      let sectionsNameArray = (Array(NSOrderedSet(array: array)) as? [String])!
//      print(sectionsNameArray.count)
