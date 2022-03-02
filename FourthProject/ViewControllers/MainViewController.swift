//
//  ViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import SnapKit
import MapKit
import CoreLocation
import Network

class MainViewController: UIViewController {
  let monitor = NWPathMonitor()
  let locationManager = CLLocationManager()
  var array = [ATM]()
  var atmRecived: ATM?

  private lazy var internetAccessAlert: UIAlertController = {
	let alert = UIAlertController(title: "No access to internet connection",
								  message: "приложение не работает без доступа к интернету.",
								  preferredStyle: .alert)
	alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
	return alert
  }()

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

  private lazy var mapView: MKMapView = {
	var map = MKMapView()
	let minskCenter = CLLocation(latitude: 53.716, longitude: 27.9776)
	map.centerToLocation(minskCenter)
	let region = MKCoordinateRegion(
	  center: minskCenter.coordinate,
	  latitudinalMeters: 10000,
	  longitudinalMeters: 10000)
	// map.register(MKMarkerAnnotationView.self,
		//		 forAnnotationViewWithReuseIdentifier: NSStringFromClass(ATMsPinAnnotation.self))
	return map
  }()

  private func registerMapAnnotationViews() {
  mapView.register(MKMarkerAnnotationView.self,
				   forAnnotationViewWithReuseIdentifier: NSStringFromClass(ATMsPinAnnotation.self))
  mapView.register(MKAnnotationView.self,
				   forAnnotationViewWithReuseIdentifier: NSStringFromClass(InfoboxsPinAnnotation.self))
  mapView.register(MKAnnotationView.self,
				   forAnnotationViewWithReuseIdentifier: NSStringFromClass(BranchesPinAnnotation.self))
  }

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

	registerMapAnnotationViews()

	view.backgroundColor = .systemBackground
	view.addSubview(mapOrListsegmentedControl)
	view.addSubview(mapView)

	let saveImage = UIImage(systemName: "arrow.counterclockwise")
	guard let saveImage = saveImage else {
	  return
	}

	let imageButton = UIBarButtonItem(image: saveImage,
									  style: .plain,
									  target: self,
									  action: #selector(actionButton))
	navigationItem.rightBarButtonItem = imageButton

	mapView.delegate = self

	if atmRecived == nil {
	  DispatchQueue.main.async {
		self.checkAccessToLocation()
	  }
	}

	monitor.pathUpdateHandler = { [self] path in
	  switch path.status {
	  case .satisfied :
		if atmRecived == nil {
		  DispatchQueue.main.async {
			checkAccessToLocation()
		  }
		}

	  case .unsatisfied :
		DispatchQueue.main.async {
		  present(internetAccessAlert, animated: true)
		}
	  case .requiresConnection :
		DispatchQueue.main.async {
		  present(internetAccessAlert, animated: true)
		}
	  default : break
	  }
	}

	let queue = DispatchQueue(label: "Monitor")
	monitor.start(queue: queue)
	self.createPins()
	monitor.cancel()

	makeConstraints()
  }

  private func makeConstraints() {
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

  override func viewWillAppear(_ animated: Bool) {
	super.viewWillAppear(animated)
	guard let atmRecived = atmRecived else {
	  return
	}
	guard let lat = Double(atmRecived.address.geolocation.geographicCoordinates.latitude) else {return}
	guard let lng = Double(atmRecived.address.geolocation.geographicCoordinates.longitude) else {return}

	mapView.centerToLocation(CLLocation(latitude: lat, longitude: lng), regionRadius: regionRadius)

	var breake = ""
	if  atmRecived.availability.standardAvailability.day[0].dayBreak.breakFromTime.rawValue != "00:00" {
	  breake = atmRecived.availability.standardAvailability.day[0].dayBreak.breakFromTime.rawValue + "-" +
	  atmRecived.availability.standardAvailability.day[0].dayBreak.breakToTime.rawValue}

	var abc = atmRecived.services[0].serviceType.rawValue
	for index in 0..<atmRecived.services.count {
	  if atmRecived.services[index].serviceType.rawValue == "CashIn" {
		abc = "Cash In доступен"
		break
	  } else {
		abc = "нет Сash in"}
	}

	let sheetViewController = ButtomPresentationViewController(adressOfATM: atmRecived.address.streetName + " "
															   + atmRecived.address.buildingNumber,
															   atm: atmRecived,
															   timeOfWork:
																atmRecived.availability.standardAvailability.day[0]
																.openingTime.rawValue
															   + "-" +
															   atmRecived.availability.standardAvailability.day[0]
																.closingTime.rawValue
															   + " " + breake,
															   currancy: atmRecived.currency.rawValue,
															   cashIn: abc)

	let nav = UINavigationController(rootViewController: sheetViewController)
	nav.modalPresentationStyle = .automatic
	if let sheet = nav.sheetPresentationController {
	  sheet.detents = [.medium(), .large()]
	}
	present(nav, animated: true, completion: nil)
  }

  @objc func actionButton(_ sender: UIBarButtonItem) {

	let serialQueue = DispatchQueue(label: "swiftlee.serial.queue")

	serialQueue.async {
	  sender.isEnabled.toggle()
	  serialQueue.async(flags: .barrier) {
		self.reloadData()
		sender.isEnabled.toggle()
	  }
	}
  }

  private	func reloadData () {
	DispatchQueue.main.async {
	  let annotations = self.mapView.annotations
	  self.mapView.removeAnnotations(annotations)
	  self.createPins()
	  self.locationManager.startUpdatingLocation()
	  guard let locValue: CLLocationCoordinate2D = self.locationManager.location?.coordinate else {
		return
	  }
	  self.locationManager.stopUpdatingLocation()
	  self.mapView.centerToLocation(CLLocation(latitude: locValue.latitude,
											   longitude: locValue.longitude),
									regionRadius: regionRadius)
	}
  }

  @objc func action (_ sender: UISegmentedControl) {
	let detailed = DetailedCollectionViewController()
	detailed.complition = { atm in
	  DispatchQueue.main.async {
		self.atmRecived = atm
	  }
	}
	if sender.selectedSegmentIndex == 0 {
	} else {
	  sender.selectedSegmentIndex = 0
	  self.navigationController?.pushViewController(detailed, animated: true)
	}
  }

  private	func checkAccessToLocation () {
	if CLLocationManager.locationServicesEnabled() {
	  locationManager.delegate = self
	  locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
	  locationManager.startUpdatingLocation()
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

  private	func createPins () {
	let apiService = APIService()
	let group = DispatchGroup()
	group.enter()
	apiService.getJSON(urlString: urlATMsString, runQueue: .global(), complitionQueue: .main) { (atms: ATMResponse) in

	  let atms = atms
	  for atm in 0..<atms.data.atm.count {
		let item =  atms.data.atm[atm]
		guard let latitude = Double(item.address.geolocation.geographicCoordinates.latitude) else {
		  return
		}
		guard let longitude = Double(item.address.geolocation.geographicCoordinates.longitude) else {
		  return
		}
		let loc = CLLocationCoordinate2D(latitude: latitude,
										 longitude: longitude)
		self.setATMsPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber,
										 atm: item,
										 location: loc)
	  }
	}
	group.leave()


	group.enter()
	apiService.getJSON(urlString: urlInfoboxString, runQueue: .global(), complitionQueue: .main) { (infobox: [InfoBox]) in

	  let infobox = infobox
	  for singleBox in 0..<infobox.count {
		let item = infobox[singleBox]

		guard let latitude = Double(item.gpsX!) else {
		  return
		}
		guard let longitude = Double(item.gpsY!) else {
		  return
		}
		let loc = CLLocationCoordinate2D(latitude: latitude,
										 longitude: longitude)
		self.setInfoBoxPinUsingMKAnnotation(title: item.city!, infobox: item, location: loc)
	  }
	}
	group.leave()


	group.enter()
	apiService.getJSON(urlString: urlbBranchesString, runQueue: .global(), complitionQueue: .main) { (branch: Branch) in

	  let branch = branch
	  for bra in 0..<branch.data.branch.count {
		let item =  branch.data.branch[bra]
		guard let latitude = Double(item.address.geoLocation.geographicCoordinates.latitude) else {
		  return
		}
		guard let longitude = Double(item.address.geoLocation.geographicCoordinates.longitude) else {
		  return
		}
		let loc = CLLocationCoordinate2D(latitude: latitude,
										 longitude: longitude)
		self.setBranchPinUsingMKAnnotation(title: item.name, branch: item, location: loc)
	  }

	}
	group.leave()
  }

  private	func setATMsPinUsingMKAnnotation(title: String, atm: ATM, location: CLLocationCoordinate2D) {
	DispatchQueue.main.async {
	  let pinAnnotation = (ATMsPinAnnotation(title: title,
											 atm: atm,
											 coordinate: location))
	  self.mapView.addAnnotations([pinAnnotation])
	}
  }

  private	func setInfoBoxPinUsingMKAnnotation(title: String, infobox: InfoBox, location: CLLocationCoordinate2D) {
	DispatchQueue.main.async {
	  let pinAnnotation = (InfoboxsPinAnnotation(title: title,
												 infoBox: infobox,
												 coordinate: location))
	  self.mapView.addAnnotations([pinAnnotation])
	}
  }

  private	func setBranchPinUsingMKAnnotation(title: String, branch: BranchElement, location: CLLocationCoordinate2D) {
	DispatchQueue.main.async {
	  let pinAnnotation = (BranchesPinAnnotation(title: title,
												 branch: branch,
												 coordinate: location))
	  self.mapView.addAnnotations([pinAnnotation])
	}
  }

  private	func checkAuthorizationStatus() {
	switch locationManager.authorizationStatus {
	case .notDetermined :   locationManager.requestAlwaysAuthorization()
	  fallthrough
	case .authorizedWhenInUse, .authorizedAlways :
	  locationManager.startUpdatingLocation()
	  mapView.showsUserLocation = true
	case .restricted, .denied :
	  let alert = UIAlertController(title: "у приложения нет доступа к локации", message: "", preferredStyle: .alert)
	  alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
	  alert.addAction(UIAlertAction(title: NSLocalizedString("access", comment: ""), style: .default, handler: { _ in
		if let appSettings = URL(string: UIApplication.openSettingsURLString),
		   UIApplication.shared.canOpenURL(appSettings) {
		  UIApplication.shared.open(appSettings)
		}
	  }))
	  present(alert, animated: true)
	@unknown default:
	  break
	}
  }
}

extension MainViewController: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
			return }
		manager.stopUpdatingLocation()
		mapView.centerToLocation(CLLocation(latitude: locValue.latitude,
											longitude: locValue.longitude),
								 regionRadius: regionRadius)
	}
}

extension MainViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
	var annotationView: MKAnnotationView?
	if let annotation = annotation as? ATMsPinAnnotation {
	  annotationView = setupATMsAnnotationView(for: annotation, on: mapView)
	} else if let annotation = annotation as? InfoboxsPinAnnotation {
	  annotationView = setupInfoBoxAnnotationView(for: annotation, on: mapView)
	} else if let annotation = annotation as? BranchesPinAnnotation {
	  annotationView = setupBranchAnnotationView(for: annotation, on: mapView)
	}
	return annotationView
  }

  private func setupATMsAnnotationView(for annotation: ATMsPinAnnotation, on mapView: MKMapView) -> MKAnnotationView {
	let identifier = NSStringFromClass(ATMsPinAnnotation.self)
	let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
	view.canShowCallout = false
	if let markerAnnotationView = view as? MKMarkerAnnotationView {
	  markerAnnotationView.animatesWhenAdded = true
	  markerAnnotationView.clusteringIdentifier = "PinCluster"
	  markerAnnotationView.markerTintColor = .systemMint
	  markerAnnotationView.titleVisibility = .visible
	}
	return view
  }

  private func setupInfoBoxAnnotationView(for annotation: InfoboxsPinAnnotation,
										  on mapView: MKMapView) -> MKAnnotationView {
	let identifier = NSStringFromClass(InfoboxsPinAnnotation.self)
	let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
	view.canShowCallout = true
	view.clusteringIdentifier = "PinCluster"
	let image = UIImage(systemName: "drop")
	view.image = image
	let offset = CGPoint(x: image!.size.width / 2, y: -(image!.size.height / 2) )
	view.centerOffset = offset
	return view
  }

  private func setupBranchAnnotationView(for annotation: BranchesPinAnnotation,
										 on mapView: MKMapView) -> MKAnnotationView {
	let identifier = NSStringFromClass(BranchesPinAnnotation.self)
	let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
	view.canShowCallout = false
	let image = UIImage(systemName: "lock")
	view.clusteringIdentifier = "PinCluster"
	view.image = image
	let offset = CGPoint(x: image!.size.width / 2, y: -(image!.size.height / 2) )
	view.centerOffset = offset
	return view
  }

  func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
	if let annotation = view.annotation as? ATMsPinAnnotation {
	  var breake = " "
	  if  annotation.atm.availability.standardAvailability.day[0].dayBreak.breakFromTime.rawValue != "00:00" {
		breake = annotation.atm.availability.standardAvailability.day[0].dayBreak.breakFromTime.rawValue + "-" +
		annotation.atm.availability.standardAvailability.day[0].dayBreak.breakToTime.rawValue}

	  let atm = annotation.atm
	  var abc = atm.services[0].serviceType.rawValue
	  for index in 0..<atm.services.count {
		if atm.services[index].serviceType.rawValue == "CashIn" {
		  abc = "Cash In доступен"
		  break
		} else {
		  abc = "нет Сash in"}
	  }

	  let sheetViewController = ButtomPresentationViewController(adressOfATM: atm.address.streetName + " "
																 + atm.address.buildingNumber,
																 atm: atm, timeOfWork: atm.availability.standardAvailability.day[0].openingTime.rawValue
																 + "-" + atm.availability.standardAvailability.day[0].closingTime.rawValue
																 + " " + breake,
																 currancy: atm.currency.rawValue, cashIn: abc)
	  mapView.centerToLocation(CLLocation(latitude: annotation.coordinate.latitude,
										  longitude: annotation.coordinate.longitude),
							   regionRadius: regionRadius)

	  let nav = UINavigationController(rootViewController: sheetViewController)
	  nav.modalPresentationStyle = .automatic
	  if let sheet = nav.sheetPresentationController {
		sheet.detents = [.medium(), .large()]
	  }
	  present(nav, animated: true, completion: nil)
	}
  }
}

extension MKMapView {
  func centerToLocation(
	_ location: CLLocation,
	regionRadius: CLLocationDistance = 650000
  ) {
	let coordinateRegion = MKCoordinateRegion(
	  center: location.coordinate,
	  latitudinalMeters: regionRadius,
	  longitudinalMeters: regionRadius)
	setRegion(coordinateRegion, animated: true)
  }
}
