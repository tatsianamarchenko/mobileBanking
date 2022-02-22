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
//    let loc = CLLocationCoordinate2DMake(53.716, 27.9776)
//    annotation.coordinate = loc
//    map.addAnnotation(annotation)
//    let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
//    let region = MKCoordinateRegion(center: loc, span: span)
//    map.setRegion(region, animated: true)
//    annotation.title = "Minsk"
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
    checkAccessToLocation()

    mapView.delegate = self

      self.createPins()

      mapOrListsegmentedControl.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalToSuperview().inset(30)
        make.top.equalTo(view.safeAreaLayoutGuide)
      }
      mapView.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalToSuperview()
        make.top.equalTo(mapOrListsegmentedControl).inset(50)
        make.bottom.equalToSuperview()

    }
  }

  func setPinUsingMKAnnotation(title: String, locationName: String, location: CLLocationCoordinate2D) {
    DispatchQueue.main.async { [self] in
      let pin1 = MapPin(title: title, locationName: locationName, coordinate: location)
       let coordinateRegion = MKCoordinateRegion(center: pin1.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
       mapView.setRegion(coordinateRegion, animated: true)
       mapView.addAnnotations([pin1])
    }
  }

  @objc func action (_ sender: UISegmentedControl) {
    let detailed = DetailedCollectionViewController()
    if sender.selectedSegmentIndex == 0 {
    } else {
      sender.selectedSegmentIndex = 0
      navigationController?.pushViewController(detailed, animated: true)
      }
    }

  func checkAccessToLocation () {
    if CLLocationManager.locationServicesEnabled() {
      setUpManager()
      checkAuthorizationStatus()
    } else {
      let alert = UIAlertController(title: "локация телефона отключена", message: "", preferredStyle: .alert)
      alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
      alert.addAction(UIAlertAction(title: "on", style: .default, handler: { _ in
        if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
          UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
      }))
      present(alert, animated: true)
    }
  }

  func createPins () {
    let apiService = APIService(urlString: "https://belarusbank.by/open-banking/v1.0/atms")
    apiService.getJSON { [self] (atms: ATMResponse) in
      let atms = atms

      for atm in 0..<atms.data.atm.count {
        let item =  atms.data.atm[atm]
        let latitude = NumberFormatter().number(from:
                                                  item.address.geolocation.geographicCoordinates.latitude)!.doubleValue

        let longitude = NumberFormatter().number(from:
                                                  item.address.geolocation.geographicCoordinates.longitude)!.doubleValue

        let loc = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        setPinUsingMKAnnotation(title: item.address.townName, locationName: item.address.streetName, location: loc)
      }
    }
  }

static let locationBelarus = CLLocation(latitude: 53.7169, longitude: 27.9776)

func checkAuthorizationStatus() {
  switch locationManager.authorizationStatus {
  case .notDetermined :   locationManager.requestAlwaysAuthorization()
  case .authorizedWhenInUse, .authorizedAlways :
    mapView.showsUserLocation = true
    locationManager.startUpdatingLocation()

  case   .restricted, .denied :
    let alert = UIAlertController(title: "у приложения нет доступа к локации", message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "on", style: .default, handler: { _ in
      if let url = URL(string: "App-Prefs:root=LOCATION_SERVICES") {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
      }
    }))
    present(alert, animated: true)
  @unknown default:
    fatalError()
  }
}




  func setUpManager () {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
}

extension MainViewController: CLLocationManagerDelegate, MKMapViewDelegate {
  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

    let identifier = "Pin"
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ?? MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)

    annotationView.canShowCallout = true

    annotationView.clusteringIdentifier = "PinCluster"

    if annotation is MKUserLocation {
      return nil
    } else if annotation is MapPin {
      annotationView.image =  UIImage(systemName: "mappin.circle.fill")?.withTintColor(.systemPink, renderingMode: .automatic)
      return annotationView
    } else {
      return nil
    }
  }
}
