//
//  ViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import SnapKit
import MapKit

class MainViewController: UIViewController {

  let locationManager = CLLocationManager()

  var mapView: MKMapView = {
    var map = MKMapView()
    var annotation =  MKPointAnnotation()
    let loc = CLLocationCoordinate2DMake(53.716, 27.9776)
    annotation.coordinate = loc
    map.addAnnotation(annotation)
    let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
    let region = MKCoordinateRegion(center: loc, span: span)
    map.setRegion(region, animated: true)
    annotation.title = "Minsk"
    return map
  }()

 private lazy var mapOrListsegmentedControl: UISegmentedControl = {
    let segmentTextContent = [
        NSLocalizedString("Map", comment: ""),
        NSLocalizedString("List", comment: "")
    ]
    let segmentedControl = UISegmentedControl(items: segmentTextContent)
    segmentedControl.selectedSegmentIndex = 0
    segmentedControl.autoresizingMask = .flexibleWidth
    segmentedControl.addTarget(self, action: #selector(action), for: .valueChanged)
    return segmentedControl
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(mapOrListsegmentedControl)
    view.addSubview(mapView)

    mapOrListsegmentedControl.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview().inset(30)
      make.top.equalTo(view.safeAreaLayoutGuide)
    }
    mapView.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview()
      make.top.equalTo(mapOrListsegmentedControl).inset(50)
      make.bottom.equalToSuperview()
    }
    reciveInfo()
  }

  @objc func action (_ sender: UISegmentedControl) {
    let main = MainViewController()
    let detailed = DetailedCollectionViewController()
    if sender.selectedSegmentIndex == 0 {
    } else {
      sender.selectedSegmentIndex = 0
      navigationController?.pushViewController(detailed, animated: true)
      }
    }

  func reciveInfo() {
    let apiService = APIService(urlString: "https://belarusbank.by/open-banking/v1.0/atms")
    apiService.getJSON { (atms: ATMResponse) in
        let atms = atms
     print(atms.data.atm.count)
    }
  }
}
