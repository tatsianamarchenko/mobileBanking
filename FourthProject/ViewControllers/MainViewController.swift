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
	var atmRecived: ATM?
	var branchRecived: BranchElement?
	var infoboxRecived: InfoBox?
	var atmAnnotatiom = [ATMsPinAnnotation]()
	var branchAnnotatiom = [BranchesPinAnnotation]()
	var infoboxAnnotatiom = [InfoboxsPinAnnotation]()

	var displayedAnnotations: [MKAnnotation]? {
		didSet {
			if let newAnnotations = displayedAnnotations {
				mapView.addAnnotations(newAnnotations)
			}
		}
	}

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

	private lazy var spiner: UIActivityIndicatorView = {
		var spiner = UIActivityIndicatorView(style: .large)
		return spiner
	}()

	var mapView: MKMapView = {
		var map = MKMapView()
		let minskCenter = CLLocation(latitude: 53.716, longitude: 27.9776)
		map.centerToLocation(minskCenter)
		return map
	}()

	private lazy var mapOrListsegmentedControl: UISegmentedControl = {
		let segmentTextContent = ["Map", "List"]
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
		mapView.delegate = self
		registerMapAnnotationViews()

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

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		ATMPresentation()
		branchPresentation()
		infoboxPresentation()
	}

	@objc func presentFilterList(_ sender: UIBarButtonItem) {
		let filterVC = FilterViewController()
		filterVC.modalPresentationStyle = .popover
		let popOverVc = filterVC.popoverPresentationController
		popOverVc?.delegate = self
		popOverVc?.sourceView = self.mapView
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
				displayedAnnotations = atmAnnotatiom
				return
			} else if index == 1 {
				displayedAnnotations = infoboxAnnotatiom
				return
			} else if index == 2 {
				displayedAnnotations = branchAnnotatiom
				return
			}
		} else if filteredArray[index].isChecked == false {
			if index == 0 {
				self.mapView.removeAnnotations(atmAnnotatiom)
			} else if index == 1 {
				self.mapView.removeAnnotations(infoboxAnnotatiom)
			} else if index == 2 {
				self.mapView.removeAnnotations(branchAnnotatiom)
			}
		}
	}

	@objc func reloadDataAction(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		//	let serialQueue = DispatchQueue(label: "serial.queue")
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

	private	func reloadData() {
		DispatchQueue.main.async {
			let annotations = self.mapView.annotations
			self.mapView.removeAnnotations(annotations)
			let apiService = APIService()
			var atmItems = [ATM]()
			let group = DispatchGroup()
			self.view.isUserInteractionEnabled = false
			self.addSpiner()
			group.enter()
			apiService.getJSON(urlString: urlATMsString,
							   runQueue: .global(),
							   complitionQueue: .main) { (result: Result<ATMResponse, CustomError>) in
				switch result {
				case .success(let atms) :
					atmItems = atms.data.atm
					self.atmAnnotatiom.removeAll()
					group.leave()
				case .failure(let error) :
					self.mapView.addAnnotations(self.atmAnnotatiom)
				}
			}
			group.notify(queue: .main) {
				for atm in 0..<atmItems.count {
					let item =  atmItems[atm]
					let loc = self.findCoordinate(item: item)
					self.setATMsPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber,
													 atm: item,
													 location: loc)
				}
				self.view.isUserInteractionEnabled = true
				self.removeSpiner()
			}

			DispatchQueue.global(qos: .userInteractive).async {

				apiService.getJSON(urlString: urlInfoboxString,
								   runQueue: .global(),
								   complitionQueue: .main) { (result: Result<[InfoBox], CustomError>) in
					switch result {
					case .success(let infobox) :
						self.infoboxAnnotatiom.removeAll()
						let infoboxItems = infobox
						for singleBox in 0..<infoboxItems.count {
							let item = infoboxItems[singleBox]
							let loc = self.findCoordinate(item: item)
							self.setInfoBoxPinUsingMKAnnotation(title: item.city!, infobox: item, location: loc)
						}
					case .failure(let error) :
						self.mapView.addAnnotations(self.infoboxAnnotatiom)
					}
				}

				apiService.getJSON(urlString: urlbBranchesString,
								   runQueue: .global(),
								   complitionQueue: .main) {  (result: Result<Branch, CustomError>) in
					switch result {
					case .success(let branch) :
						let branchItems = branch.data.branch
						self.branchAnnotatiom.removeAll()
						for bra in 0..<branchItems.count {
							let item =  branchItems[bra]
							let loc = self.findCoordinate(item: item)
							self.setBranchPinUsingMKAnnotation(title: item.name, branch: item, location: loc)
						}
					case .failure(let error):
						self.mapView.addAnnotations(self.branchAnnotatiom)
					}
				}
			}

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

	func findCoordinate(item: Any) -> CLLocationCoordinate2D {
		if let item = item as? ATM {
			guard let latitude = Double(item.address.geolocation.geographicCoordinates.latitude) else {
				return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
			guard let longitude = Double(item.address.geolocation.geographicCoordinates.longitude) else {
				return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
			return CLLocationCoordinate2D(latitude: latitude,
										  longitude: longitude)
		}
		else if let item = item as? BranchElement {
			guard let latitude = Double(item.address.geoLocation.geographicCoordinates.latitude) else {
				return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
			guard let longitude = Double(item.address.geoLocation.geographicCoordinates.longitude) else {
				return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
			return CLLocationCoordinate2D(latitude: latitude,
										  longitude: longitude)
		}
		else if let item = item as? InfoBox {
			guard let latitude = Double(item.gpsX!) else {
				return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
			guard let longitude = Double(item.gpsY!) else {
				return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
			return CLLocationCoordinate2D(latitude: latitude,
										  longitude: longitude)
		}
		return CLLocationCoordinate2D(latitude: 0, longitude: 0)
	}

	@objc func action (_ sender: UISegmentedControl) {
		let detailed = DetailedCollectionViewController()
		detailed.complitionATM = { atm in
			DispatchQueue.main.async {
				self.atmRecived = atm
			}
		}
		detailed.complitionBranch = { branch in
			DispatchQueue.main.async {
				self.branchRecived = branch
			}
		}
		detailed.complitionInfobox = { infobox in
			DispatchQueue.main.async {
				self.infoboxRecived = infobox
			}
		}
		if sender.selectedSegmentIndex != 0 {
			sender.selectedSegmentIndex = 0
			self.navigationController?.pushViewController(detailed, animated: true)
		}
	}

	private func createPins() {
		let apiService = APIService()
		var branchItems = [BranchElement]()
		var atmItems = [ATM]()
		var infoboxItems = [InfoBox]()
		let group = DispatchGroup()
		var errorString: String?
		view.isUserInteractionEnabled = false
		addSpiner()

		group.enter()
		apiService.getJSON(urlString: urlATMsString,
						   runQueue: .global(),
						   complitionQueue: .main) { [self] (result: Result<ATMResponse, CustomError>) in
			switch result {
			case .success(let atms) :
				atmItems = atms.data.atm
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
					present(internetErrorAlert, animated: true)
					group.leave()
				}
			}
		}

		group.enter()
		apiService.getJSON(urlString: urlInfoboxString,
						   runQueue: .global(),
						   complitionQueue: .main) { [self] (result: Result<[InfoBox], CustomError>) in
			switch result {
			case .success(let infobox) :
				infoboxItems = infobox
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
		apiService.getJSON(urlString: urlbBranchesString,
						   runQueue: .global(),
						   complitionQueue: .main) { [self] (result: Result<Branch, CustomError>) in
			switch result {
			case .success(let branch) :
				branchItems = branch.data.branch
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

			for bra in 0..<branchItems.count {
				let item =  branchItems[bra]
				let loc = self.findCoordinate(item: item)
				self.setBranchPinUsingMKAnnotation(title: item.name, branch: item, location: loc)
			}

			for singleBox in 0..<infoboxItems.count {
				let item = infoboxItems[singleBox]
				let loc = self.findCoordinate(item: item)
				self.setInfoBoxPinUsingMKAnnotation(title: item.city!, infobox: item, location: loc)
			}

			for atm in 0..<atmItems.count {
				let item =  atmItems[atm]
				let loc = self.findCoordinate(item: item)
				self.setATMsPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber,
												 atm: item,
												 location: loc)
			}
			self.view.isUserInteractionEnabled = true
			self.removeSpiner()
		}
	}
}

extension MainViewController {
	
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
	
	private func addSpiner() {
		view.addSubview(spiner)
		DispatchQueue.main.async {
			self.spiner.startAnimating()
			self.spiner.snp.makeConstraints { (make) -> Void in
				make.centerY.equalToSuperview()
				make.centerX.equalToSuperview()
			}
		}
	}
	
	private func removeSpiner() {
		self.spiner.stopAnimating()
		self.spiner.removeFromSuperview()
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
}

extension MainViewController {

	func ATMPresentation() {
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

		let sheetViewController = ButtomPresentationATMViewController(adressOfATM: atmRecived.address.streetName + " "
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
		self.atmRecived = nil
	}

	func branchPresentation() {
		guard let branchRecived = branchRecived else {
			return
		}
		guard let lat = Double(branchRecived.address.geoLocation.geographicCoordinates.latitude) else {return}
		guard let lng = Double(branchRecived.address.geoLocation.geographicCoordinates.longitude) else {return}

		mapView.centerToLocation(CLLocation(latitude: lat, longitude: lng), regionRadius: regionRadius)

		var breake = ""
		if  branchRecived.information.availability.standardAvailability.day[0].dayBreak.breakFromTime != "00:00" {
			breake = branchRecived.information.availability.standardAvailability.day[0].dayBreak.breakFromTime + "-" +
			branchRecived.information.availability.standardAvailability.day[0].dayBreak.breakToTime}
		var abc = ""
		for service in 0..<branchRecived.services.service.currencyExchange.count {
			abc = branchRecived.services.service.currencyExchange[service].direction
		}

		let sheetViewController = ButtomPresentationBranchViewController(adressOfATM: branchRecived.address.streetName + " "
																		 + branchRecived.address.buildingNumber,
																		 branch: branchRecived,
																		 timeOfWork:
																			branchRecived.information.availability.standardAvailability.day[0].openingTime
																		 + "-" +
																		 branchRecived.information.availability.standardAvailability.day[0].openingTime
																		 + " " + breake,
																		 currancy: branchRecived.information.contactDetails.phoneNumber,
																		 cashIn: abc)

		let nav = UINavigationController(rootViewController: sheetViewController)
		nav.modalPresentationStyle = .automatic
		if let sheet = nav.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
		}
		present(nav, animated: true, completion: nil)
		self.branchRecived = nil
	}

	func infoboxPresentation() {
		guard let infoboxRecived = infoboxRecived else {
			return
		}
		guard let lat = Double((infoboxRecived.gpsX)!) else {return}
		guard let lng = Double((infoboxRecived.gpsY)!) else {return}

		mapView.centerToLocation(CLLocation(latitude: lat, longitude: lng), regionRadius: regionRadius)

		let sheetViewController = ButtomPresentationInfoboxViewController(adressOfATM: infoboxRecived.addressType!.rawValue + " " + infoboxRecived.address!,
																		  infobox: infoboxRecived,
																		  timeOfWork:
																			infoboxRecived.workTime!,
																		  currancy: infoboxRecived.currency!.rawValue,
																		  cashIn: infoboxRecived.cashIn!.rawValue)

		let nav = UINavigationController(rootViewController: sheetViewController)
		nav.modalPresentationStyle = .automatic
		if let sheet = nav.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
		}
		present(nav, animated: true, completion: nil)
		self.infoboxRecived = nil
	}
}

extension MainViewController {
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

extension MainViewController {

	private func registerMapAnnotationViews() {
		mapView.register(MKMarkerAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: NSStringFromClass(ATMsPinAnnotation.self))
		mapView.register(MKMarkerAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: NSStringFromClass(InfoboxsPinAnnotation.self))
		mapView.register(MKMarkerAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: NSStringFromClass(BranchesPinAnnotation.self))
	}

	private	func setATMsPinUsingMKAnnotation(title: String, atm: ATM, location: CLLocationCoordinate2D) {
		DispatchQueue.main.async {
			let pinAnnotation = (ATMsPinAnnotation(title: title,
												   atm: atm,
												   coordinate: location))
			self.atmAnnotatiom.append(pinAnnotation)
			self.mapView.addAnnotations(self.atmAnnotatiom)
		}
	}

	private	func setInfoBoxPinUsingMKAnnotation(title: String, infobox: InfoBox, location: CLLocationCoordinate2D) {
		DispatchQueue.main.async {
			let pinAnnotation = (InfoboxsPinAnnotation(title: title,
													   infoBox: infobox,
													   coordinate: location))
			self.infoboxAnnotatiom.append(pinAnnotation)
			self.mapView.addAnnotations(self.infoboxAnnotatiom)
		}
	}

	private	func setBranchPinUsingMKAnnotation(title: String, branch: BranchElement, location: CLLocationCoordinate2D) {
		DispatchQueue.main.async {
			let pinAnnotation = (BranchesPinAnnotation(title: title,
													   branch: branch,
													   coordinate: location))
			self.branchAnnotatiom.append(pinAnnotation)
			self.mapView.addAnnotations(self.branchAnnotatiom)
		}
	}
}

extension MainViewController: UIPopoverPresentationControllerDelegate {
	func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
		.none
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
		view.canShowCallout = true
		let image = UIImage(named: "atm")
		view.clusteringIdentifier = "PinCluster"
		if let markerAnnotationView = view as? MKMarkerAnnotationView {
			markerAnnotationView.animatesWhenAdded = true
			markerAnnotationView.canShowCallout = true
			markerAnnotationView.markerTintColor = .orange
			markerAnnotationView.glyphImage = image
		}
		return view
	}

	private func setupInfoBoxAnnotationView(for annotation: InfoboxsPinAnnotation,
											on mapView: MKMapView) -> MKAnnotationView {
		let identifier = NSStringFromClass(InfoboxsPinAnnotation.self)
		let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
		view.canShowCallout = true
		let image = UIImage(named: "info")
		view.clusteringIdentifier = "PinCluster"
		if let markerAnnotationView = view as? MKMarkerAnnotationView {
			markerAnnotationView.animatesWhenAdded = true
			markerAnnotationView.canShowCallout = true
			markerAnnotationView.markerTintColor = .systemPink
			markerAnnotationView.glyphImage = image
		}
		return view
	}

	private func setupBranchAnnotationView(for annotation: BranchesPinAnnotation,
										   on mapView: MKMapView) -> MKAnnotationView {
		let identifier = NSStringFromClass(BranchesPinAnnotation.self)
		let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
		view.canShowCallout = false
		let image = UIImage(named: "bank")
		view.clusteringIdentifier = "PinCluster"
		if let markerAnnotationView = view as? MKMarkerAnnotationView {
			markerAnnotationView.animatesWhenAdded = true
			markerAnnotationView.canShowCallout = true
			markerAnnotationView.markerTintColor = .systemMint
			markerAnnotationView.glyphImage = image
		}
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

			let sheetViewController = ButtomPresentationATMViewController(adressOfATM: atm.address.streetName + " "
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
