//
//  DetailedCollectionCollectionViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit

class DetailedCollectionViewController: UIViewController, UICollectionViewDelegateFlowLayout {

var arrayOfATMs = [ATM]()

  private lazy var collectionView: UICollectionView = {
    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.register(DetailedCollectionViewCell.self,
                            forCellWithReuseIdentifier: DetailedCollectionViewCell.reuseIdentifier)
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
      apiService.getJSON { (atms: ATMResponse) in
        let atms = atms
        self.arrayOfATMs = atms.data.atm
        DispatchQueue.main.async {
          self.collectionView.reloadData()
        }
        print((self.arrayOfATMs.count))

    }
  }
}

extension DetailedCollectionViewController: UICollectionViewDelegate, UICollectionViewDataSource {
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    arrayOfATMs.count
  }

     func collectionView(_ collectionView: UICollectionView,
                         cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier:
                                                            DetailedCollectionViewCell.reuseIdentifier, for: indexPath)
              as? DetailedCollectionViewCell else {
        return UICollectionViewCell()
      }
       cell.timeLabel.text = arrayOfATMs[indexPath.row].availability.standardAvailability.day[0].closingTime.rawValue
       cell.placeLabel.text = arrayOfATMs[indexPath.row].address.addressLine
      cell.currancyLabel.text = arrayOfATMs[indexPath.row].currency.rawValue
      return cell
    }

    func collectionView(_ collectionView: UICollectionView,
                        willDisplay cell: UICollectionViewCell,
                        forItemAt indexPath: IndexPath) {
      let lastElement = arrayOfATMs.count - 1
      if indexPath.row == lastElement {
          // handle your logic here to get more items, add it to dataSource and reload tableview

          }
    }

    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
     func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

     func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

     func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return CGSize(width: 100, height: 100)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return 1
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
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



