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
import CoreData

class MainViewController: UIViewController {

	let monitor = NWPathMonitor()
	let locationManager = CLLocationManager()

	var atmRecived: AtmElement?
	var branchRecived: BranchElement?
	var infoboxRecived: InfoBoxElement?

	var atmAnnotation = [PinAnnotation<AtmElement>]()
	var branchAnnotation = [PinAnnotation<BranchElement>]()
	var infoboxAnnotation = [PinAnnotation<InfoBoxElement>]()

	var ATMinfofromCoreData = [ATMData]()
	var branchInfofromCoreData = [BranchData]()
	var infoboxInfofromCoreData = [InfoboxData]()

	let context = CoreDataStack.sharedInstance.persistentContainer.viewContext

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
		makeRightBarButtonItems()
		makeConstraints()
		checkAccessToLocation()

		monitor.pathUpdateHandler = { path in
			switch path.status {
			case .unsatisfied :
				DispatchQueue.main.async { [self] in
					present(internetAccessAlert, animated: true)
				}
			case .requiresConnection :
				DispatchQueue.main.async { [self] in
					present(internetAccessAlert, animated: true)
				}
			default : break
			}
		}

		let queue = DispatchQueue(label: "Monitor")
		monitor.start(queue: queue)
		self.createPins()
		monitor.cancel()
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		if atmRecived != nil {
			ATMPresentation(ATM: atmRecived!)
		}
		if branchRecived != nil {
			branchPresentation(branch: branchRecived!)
		}
		if infoboxRecived != nil {
			infoboxPresentation(infobox: infoboxRecived!)
		}
	}

	private func makeRightBarButtonItems() {
		guard let saveImage = UIImage(systemName: "arrow.counterclockwise") else {
			return
		}
		guard let filterImage = UIImage(systemName: "square.3.stack.3d") else {
			return
		}

		let imageButton = UIBarButtonItem(image: saveImage, style: .plain,
										  target: self, action: #selector(reloadDataAction))

		let filterButton = UIBarButtonItem(image: filterImage, style: .plain,
										   target: self, action: #selector(presentFilterList))

		navigationItem.rightBarButtonItems = [imageButton, filterButton]
	}

	private func filter(index: Int) {
		if 	filteredArray[index].isChecked == true {
			if index == 0 {
				displayedAnnotations = atmAnnotation
				return
			} else if index == 1 {
				displayedAnnotations = infoboxAnnotation
				return
			} else if index == 2 {
				displayedAnnotations = branchAnnotation
				return
			}
		} else if filteredArray[index].isChecked == false {
			if index == 0 {
				self.mapView.removeAnnotations(atmAnnotation)
			} else if index == 1 {
				self.mapView.removeAnnotations(infoboxAnnotation)
			} else if index == 2 {
				self.mapView.removeAnnotations(branchAnnotation)
			}
		}
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

	@objc func reloadDataAction(_ sender: UIBarButtonItem) {
		sender.isEnabled = false
		self.reloadData()
		DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
			sender.isEnabled = true
		}
	}

	private func reloadData() {
		DispatchQueue.main.async {
			let annotations = self.mapView.annotations
			self.mapView.removeAnnotations(annotations)
			var atmItems = [AtmElement]()
			let group = DispatchGroup()
			self.view.isUserInteractionEnabled = false
			self.addSpiner()
			group.enter()
			DataFetcherService().fetchATMs { (result: Result<ATMResponse, CustomError>) in
				switch result {
				case .success(let atms) :
					atmItems = atms.data.atm
					self.atmAnnotation.removeAll()
					group.leave()
				case .failure(let error) :
					self.mapView.addAnnotations(self.atmAnnotation)
				}
			}


			group.notify(queue: .main) {
				for atm in 0..<atmItems.count {
					let item =  atmItems[atm]
					let loc = self.findCoordinate(latitude: item.address.geolocation.geographicCoordinates.latitude, longitude: item.address.geolocation.geographicCoordinates.longitude)
					self.setATMsPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber,
													 atm: item,
													 location: loc)
				}
				self.view.isUserInteractionEnabled = true
				self.removeSpiner()
			}

			DispatchQueue.global(qos: .userInteractive).async {
				DataFetcherService().fetchInfoboxes { (result: Result<[InfoBoxElement], CustomError>) in
					switch result {
					case .success(let infobox) :
						self.infoboxAnnotation.removeAll()
						let infoboxItems = infobox
						for singleBox in 0..<infoboxItems.count {
							let item = infoboxItems[singleBox]
							let loc = self.findCoordinate(latitude: item.gpsX!, longitude: item.gpsY!)
							self.setInfoBoxPinUsingMKAnnotation(title: item.city!, infobox: item, location: loc)
						}
					case .failure(let error) :
						self.mapView.addAnnotations(self.infoboxAnnotation)
					}
				}

				DataFetcherService().fetchBranches { (result: Result<Branch, CustomError>) in
					switch result {
					case .success(let branch) :
						let branchItems = branch.data.branch
						self.branchAnnotation.removeAll()
						for bra in 0..<branchItems.count {
							let item =  branchItems[bra]
							let loc = self.findCoordinate(latitude: item.address.geolocation.geographicCoordinates.latitude, longitude: item.address.geolocation.geographicCoordinates.longitude)
							self.setBranchPinUsingMKAnnotation(title: item.type, branch: item, location: loc)
						}
					case .failure(let error):
						self.mapView.addAnnotations(self.branchAnnotation)
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
										  regionRadius: Constants.share.regionRadius)
		}
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
		var branchItems = [BranchElement]()
		var atmItems = [AtmElement]()
		var infoboxItems = [InfoBoxElement]()

		let group = DispatchGroup()
		var errorString: String?

		let dataFetcherService = DataFetcherService()

		view.isUserInteractionEnabled = false
		addSpiner()
		let queue = DispatchQueue(label: "queue", attributes: .concurrent)
		group.enter()
		queue.async(group: group) {
			dataFetcherService.fetchATMs { [self] (result: Result<ATMResponse, CustomError>) in
				switch result {
				case .success(let atms) :
					atmItems = atms.data.atm
					CoreDataStack.sharedInstance.clearData(type: ATMData.self, context: context)
					CoreDataStack.sharedInstance.saveATMInCoreDataWith(atms: atms, context: context)
					group.leave()
				case .failure(let error) :
					fetchInformationATM()
					if	error == .errorGeneral {
						if errorString != nil {
							errorString?.append(" Банкоматы ")} else {
								errorString = ""
								errorString?.append(" Банкоматы ")}
						group.leave()
					} else {
						present(internetErrorAlert, animated: true)
						// group.leave()
					}
				}
			}
		}

		group.enter()
		queue.async(group: group) {
			dataFetcherService.fetchInfoboxes { [self] (result: Result<[InfoBoxElement], CustomError>) in
				switch result {
				case .success(let infobox) : infoboxItems = infobox
					CoreDataStack.sharedInstance.clearData(type: InfoboxData.self, context: context)
					CoreDataStack.sharedInstance.saveInfoBoxInCoreDataWith(infoboxes: infobox, context: context)
					group.leave()
				case .failure(let error) :
					fetchInformationInfobox()
					if	error == .errorGeneral {
						if errorString != nil { errorString?.append(" Инфокиоски ")} else {
							errorString = ""
							errorString?.append(" Инфокиоски ")}
						group.leave()
					} else {
						present(internetErrorAlert, animated: true)
						//	group.leave()
					}
				}
			}
		}

		group.enter()
		queue.async(group: group) {
			dataFetcherService.fetchBranches { [self] (result: Result<Branch, CustomError>) in
				switch result {
				case .success(let branch) :	branchItems = branch.data.branch
					CoreDataStack.sharedInstance.clearData(type: BranchData.self, context: context)
					CoreDataStack.sharedInstance.saveBranchInCoreDataWith(branches: branch, context: context)
					group.leave()
				case .failure(let error) :
					fetchInformationBranch()
					if	error == .errorGeneral {
						if errorString != nil {
							errorString?.append(" Отделения банка ")}
						else { errorString = ""
							errorString?.append(" Отделения банка ")}
						group.leave()
					} else {
						present(internetErrorAlert, animated: true)
						//		group.leave()
					}
				}
			}
		}

		group.notify(queue: .main) {
			if let errorString = errorString {
				DispatchQueue.main.async { [self] in
					let alert = createErrorAlert(errorString: errorString)
					present(alert, animated: true)
				}
				self.view.isUserInteractionEnabled = true
				self.removeSpiner()
				return
			}
			for bra in 0..<branchItems.count {
				let item =  branchItems[bra]
				let loc = self.findCoordinate(latitude: item.address.geolocation.geographicCoordinates.latitude, longitude: item.address.geolocation.geographicCoordinates.longitude)
				self.setBranchPinUsingMKAnnotation(title: item.type, branch: item, location: loc)
			}
			for singleBox in 0..<infoboxItems.count {
				let item = infoboxItems[singleBox]
				let loc = self.findCoordinate(latitude: item.gpsX!, longitude: item.gpsY!)
				self.setInfoBoxPinUsingMKAnnotation(title: item.city!, infobox: item, location: loc)
			}
			for atm in 0..<atmItems.count {
				let item =  atmItems[atm]
				let loc = self.findCoordinate(latitude: item.address.geolocation.geographicCoordinates.latitude, longitude: item.address.geolocation.geographicCoordinates.longitude)
				self.setATMsPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber, atm: item, location: loc)
			}
			self.view.isUserInteractionEnabled = true
			self.removeSpiner()
		}
	}
}
extension MainViewController {

	func fetchInformationATM() {
		do {
			let request: NSFetchRequest<ATMData> = ATMData.fetchRequest()
			self.ATMinfofromCoreData = try context.fetch(request)
			print(self.ATMinfofromCoreData.count)

			DispatchQueue.main.async {
				guard let a = self.ATMinfofromCoreData.first?.atmData else {return}
				self.coreDataATMpins(data: a)
			}
		} catch {
			print(error)
		}
	}

	func fetchInformationBranch() {
		do {
			let request: NSFetchRequest<BranchData> = BranchData.fetchRequest()
			self.branchInfofromCoreData = try context.fetch(request)
			print(self.branchInfofromCoreData.count)

			DispatchQueue.main.async {
				guard let a = self.branchInfofromCoreData.first?.branchData else {return}
				self.coreDataBranchpins(data: a)
			}
		} catch {
			print(error)
		}
	}

	func fetchInformationInfobox() {
		do {
			let request: NSFetchRequest<InfoboxData> = InfoboxData.fetchRequest()
			self.infoboxInfofromCoreData = try context.fetch(request)
			print(self.infoboxInfofromCoreData.count)

			DispatchQueue.main.async {
				guard let a = self.infoboxInfofromCoreData.first?.infoboxData else {return}
				self.coreDataInfoboxpins(data: a)
			}
		} catch {
			print(error)
		}
	}

	func coreDataATMpins(data: Data) {
		let decoder = JSONDecoder()
		do {
			let decodedData = try decoder.decode(ATMResponse.self, from: data)
			for atm in 0..<decodedData.data.atm.count {
				let item =  decodedData.data.atm[atm]
				let loc = self.findCoordinate(latitude: item.address.geolocation.geographicCoordinates.latitude, longitude: item.address.geolocation.geographicCoordinates.longitude)
				self.setATMsPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber, atm: item, location: loc)
			}
		} catch {
			print("Error: \(error.localizedDescription)")
		}
	}

	func coreDataBranchpins(data: Data) {
		let decoder = JSONDecoder()
		do {
			let decodedData = try decoder.decode(Branch.self, from: data)
			for branch in 0..<decodedData.data.branch.count {
				let item =  decodedData.data.branch[branch]
				let loc = self.findCoordinate(latitude: item.address.geolocation.geographicCoordinates.latitude, longitude: item.address.geolocation.geographicCoordinates.longitude)
				self.setBranchPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber,
												   branch: item, location: loc)
			}
		} catch {
			print("Error: \(error.localizedDescription)")
		}
	}

	func coreDataInfoboxpins(data: Data) {
		let decoder = JSONDecoder()
		do {
			let decodedData = try decoder.decode([InfoBoxElement].self, from: data)
			for infobox in 0..<decodedData.count {
				let item =  decodedData[infobox]
				let loc = self.findCoordinate(latitude: item.gpsX!, longitude: item.gpsY!)
				self.setInfoBoxPinUsingMKAnnotation(title: item.address! + " " + item.house!, infobox: item, location: loc)
			}
		} catch {
			print("Error: \(error.localizedDescription)")
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

	func ATMPresentation(ATM: AtmElement) {

		let adressOfItem = ATM.address.streetName + " "
		+ ATM.address.buildingNumber
		let timeOfWork =
		ATM.availability.standardAvailability.day[0].openingTime + "-" +
		ATM.availability.standardAvailability.day[0].closingTime
		var currancy = ATM.currency.rawValue
		var cashIn = ATM.services[0].serviceType.rawValue
		let title = ATM.address.addressLine
		let itemLng = ATM.address.geolocation.geographicCoordinates.longitude
		let itemLat = ATM.address.geolocation.geographicCoordinates.latitude

		guard let lat = Double(itemLat) else {return}
		guard let lng = Double(itemLng) else {return}

		mapView.centerToLocation(CLLocation(latitude: lat, longitude: lng), regionRadius: Constants.share.regionRadius)

		var breake = ""
		if  ATM.availability.standardAvailability.day[0].dayBreak.breakFromTime != "00:00" {
			breake = ATM.availability.standardAvailability.day[0].dayBreak.breakFromTime + "-" +
			ATM.availability.standardAvailability.day[0].dayBreak.breakToTime}

		for index in 0..<ATM.services.count {
			if ATM.services[index].serviceType.rawValue == "CashIn" {
				cashIn = "Cash In доступен"
				break
			} else {
				cashIn = "нет Сash in"}
		}

		let sheetViewController = ButtomPresentationViewController(adressOfItem: adressOfItem,
																   item: ATM,
																   timeOfWork: timeOfWork,
																   currancy: currancy,
																   cashIn: cashIn,
																   title: title,
																   itemLng: itemLng,
																   itemLat: itemLat)

		let nav = UINavigationController(rootViewController: sheetViewController)
		nav.modalPresentationStyle = .automatic
		if let sheet = nav.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
		}
		present(nav, animated: true, completion: nil)
		self.atmRecived = nil
	}

	func branchPresentation(branch: BranchElement) {
		let adressOfItem = branch.address.addressLine
		let timeOfWork = branch.information.availability.standardAvailability.day[0].openingTime + "-" +
		branch.information.availability.standardAvailability.day[0].closingTime
		var currancy = branch.services.currencyExchange[0].exchangeRate
		for service in 0..<branch.services.currencyExchange.count {
			currancy = branch.services.currencyExchange[service].direction
		}
		let cashIn = branch.information.contactDetails.mobileNumber
		let title = branch.address.streetName + " "
		+ branch.address.buildingNumber
		let itemLng = branch.address.geolocation.geographicCoordinates.longitude
		let itemLat = branch.address.geolocation.geographicCoordinates.latitude

		guard let lat = Double(itemLat) else {return}
		guard let lng = Double(itemLng) else {return}

		mapView.centerToLocation(CLLocation(latitude: lat, longitude: lng), regionRadius: Constants.share.regionRadius)

		let sheetViewController = ButtomPresentationViewController(adressOfItem: adressOfItem,
																   item: branch, timeOfWork: timeOfWork,
																   currancy: currancy,
																   cashIn: cashIn,
																   title: title,
																   itemLng: itemLng,
																   itemLat: itemLat)

		let nav = UINavigationController(rootViewController: sheetViewController)
		nav.modalPresentationStyle = .automatic
		if let sheet = nav.sheetPresentationController {
			sheet.detents = [.medium(), .large()]
		}
		present(nav, animated: true, completion: nil)
		self.branchRecived = nil
	}

	func infoboxPresentation(infobox: InfoBoxElement) {
		guard let adressOfItem = infobox.address else {return}
		guard let timeOfWork = infobox.workTime else {return}
		guard let currancy = infobox.currency else {return}
		guard let cashIn = infobox.cashIn else {return}
		guard let title = infobox.address else {return}
		guard let itemLng = infobox.gpsY else {return}
		guard let itemLat = infobox.gpsX else {return}

		guard let lat = Double(itemLat) else {return}
		guard let lng = Double(itemLng) else {return}

		mapView.centerToLocation(CLLocation(latitude: lat, longitude: lng), regionRadius: Constants.share.regionRadius)
		let sheetViewController = ButtomPresentationViewController(adressOfItem: adressOfItem,
																   item: infobox,
																   timeOfWork: timeOfWork,
																   currancy: currancy,
																   cashIn: cashIn,
																   title: title,
																   itemLng: itemLng,
																   itemLat: itemLat)

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

	func findCoordinate(latitude: String, longitude: String) -> CLLocationCoordinate2D {
		guard let latitude = Double(latitude) else {
			return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
		guard let longitude = Double(longitude) else {
			return CLLocationCoordinate2D(latitude: 0, longitude: 0) }
		return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
	}
}

extension MainViewController {

	private func registerMapAnnotationViews() {
		mapView.register(MKMarkerAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: NSStringFromClass(PinAnnotation<AtmElement>.self))
		mapView.register(MKMarkerAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: NSStringFromClass(PinAnnotation<InfoBoxElement>.self))
		mapView.register(MKMarkerAnnotationView.self,
						 forAnnotationViewWithReuseIdentifier: NSStringFromClass(PinAnnotation<BranchElement>.self))
	}

	private	func setATMsPinUsingMKAnnotation(title: String, atm: AtmElement, location: CLLocationCoordinate2D) {
		DispatchQueue.main.async {
			let pinAnnotation = (PinAnnotation<AtmElement>(title: title,
														   item: atm,
														   coordinate: location))
			self.atmAnnotation.append(pinAnnotation)
			self.mapView.addAnnotations(self.atmAnnotation)
		}
	}

	private func setInfoBoxPinUsingMKAnnotation(title: String, infobox: InfoBoxElement, location: CLLocationCoordinate2D) {
		DispatchQueue.main.async {
			let pinAnnotation = (PinAnnotation<InfoBoxElement>(title: title,
															   item: infobox,
															   coordinate: location))
			self.infoboxAnnotation.append(pinAnnotation)
			self.mapView.addAnnotations(self.infoboxAnnotation)
		}
	}

	private func setBranchPinUsingMKAnnotation(title: String, branch: BranchElement, location: CLLocationCoordinate2D) {
		DispatchQueue.main.async {
			let pinAnnotation = (PinAnnotation<BranchElement>(title: title,
															  item: branch,
															  coordinate: location))
			self.branchAnnotation.append(pinAnnotation)
			self.mapView.addAnnotations(self.branchAnnotation)
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
								 regionRadius: Constants.share.regionRadius)
	}
}

extension MainViewController: MKMapViewDelegate {
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		var annotationView: MKAnnotationView?
		if let annotation = annotation as? PinAnnotation<AtmElement> {
			annotationView = setupAnnotationView(for: annotation, on: mapView, imageOfPin: "atm", color: .orange)
		} else if let annotation = annotation as? PinAnnotation<InfoBoxElement> {
			annotationView = setupAnnotationView(for: annotation, on: mapView, imageOfPin: "info", color: .systemPink)
		} else if let annotation = annotation as? PinAnnotation<BranchElement> {
			annotationView = setupAnnotationView(for: annotation, on: mapView, imageOfPin: "bank", color: .systemMint)
		}
		return annotationView
	}

	private func setupAnnotationView<T: Decodable>(for annotation: PinAnnotation<T>,
											on mapView: MKMapView,
											imageOfPin: String,
											color: UIColor?) -> MKAnnotationView {
		let identifier = NSStringFromClass(PinAnnotation<T>.self)
		let view = mapView.dequeueReusableAnnotationView(withIdentifier: identifier, for: annotation)
		view.canShowCallout = false
		let image = UIImage(named: imageOfPin)
		view.clusteringIdentifier = "PinCluster"
		if let markerAnnotationView = view as? MKMarkerAnnotationView {
			markerAnnotationView.animatesWhenAdded = true
			markerAnnotationView.canShowCallout = true
			markerAnnotationView.markerTintColor = color
			markerAnnotationView.glyphImage = image
		}
		return view
	}

	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		if let annotation = view.annotation as? PinAnnotation<AtmElement> {
			ATMPresentation(ATM: annotation.item)
		}

		if let annotation = view.annotation as? PinAnnotation<BranchElement> {
			branchPresentation(branch: annotation.item)
		}

		if let annotation = view.annotation as? PinAnnotation<InfoBoxElement> {
			infoboxPresentation(infobox: annotation.item)
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
