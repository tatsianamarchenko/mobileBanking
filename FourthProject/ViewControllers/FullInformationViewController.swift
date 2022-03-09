//
//  FullInformationViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 23.02.22.
//

import UIKit
import MapKit

class FullInformationViewController: UIViewController {
	var atm: ATM?
	var branch: BranchElement?
	var infobox: InfoBox?
	private lazy var scrollView: UIScrollView = {
		let scrollView = UIScrollView()
		scrollView.alwaysBounceVertical = true
		return scrollView
	}()

	private lazy var routButton: UIButton = {
		var button = UIButton(type: .roundedRect)
		button.setTitle("create route", for: .normal)
		button.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
		button.setTitle("", for: .highlighted )
		button.imageView?.contentMode = .scaleAspectFit
		button.backgroundColor = .systemGray6
		button.clipsToBounds = true
		button.layer.cornerRadius = 10
		button.addTarget(self, action: #selector(createRoute), for: .touchUpInside)
		return button
	}()

	private lazy var atmStack: UIStackView = {
		if let atm = atm {
			let stack = createStack(contentLableText: atm.atmID, name: "ID")
			return stack
		}
		if let branch = branch {
			let stack = createStack(contentLableText: branch.branchID, name: "ID")
			return stack
		}
		if let infobox = infobox {
			let stack = createStack(contentLableText: String(infobox.infoID!), name: "ID")
			return stack
		}

		return UIStackView()
	}()

	private lazy var typeStack: UIStackView = {
		if let atm = atm {
		let stack = createStack(contentLableText: atm.type.rawValue, name: "Тип")
		return stack
		}
		if let branch = branch {
			let stack = createStack(contentLableText: branch.name, name: "Название")
		return stack
		}
		if let infobox = infobox {
			let stack = createStack(contentLableText: infobox.infType!.rawValue , name: "Тип")
		return stack
		}
		return UIStackView()
	}()

	private lazy var currencyStack: UIStackView = {
		if let atm = atm {
		let stack = createStack(contentLableText: atm.currency.rawValue, name: "Валюта")
		return stack
		}
		if let branch = branch {
			let stack = createStack(contentLableText: branch.information.segment, name: "Сегмент")
		return stack
		}
		if let infobox = infobox {
			let stack = createStack(contentLableText: infobox.currency!.rawValue, name: "Валюта")
		return stack
		}
		return UIStackView()
	}()

	private lazy var cardsStack: UIStackView = {
		if let atm = atm {
			let content = atm.cards.map { "\($0)" }
			let stack = createStack(contentLableText: content.formatted(), name: "Карты")
			return stack
		}
		if let branch = branch {
			let content = String( branch.wifi)
			let stack = createStack(contentLableText: content, name: "Wi-Fi")
			return stack
		}
		if let infobox = infobox {
			let content = infobox.infPrinter?.rawValue
			let stack = createStack(contentLableText: content!, name: "Чек")
			return stack
		}
		return UIStackView()
	}()

	private lazy var addessStack: UIStackView = {
		if let atm = atm {
			let stack = createStack(contentLableText: atm.address.addressLine, name: "Адрес")
			return stack
		}
		if let branch = branch {
			let stack = createStack(contentLableText: branch.address.addressLine, name: "Адрес")
			return stack
		}
		if let infobox = infobox {
			let stack = createStack(contentLableText: infobox.address!, name: "Адрес")
			return stack
		}
		return UIStackView()
	}()

	private lazy var serviceStack: UIStackView = {
		if let atm = atm {
			let content = atm.services.map { "\($0.serviceType.rawValue)" }
			let stack = createStack(contentLableText: content.formatted(), name: "Сервисы")
			return stack
		}
		if let branch = branch {
			let content = branch.services.service.currencyExchange[0].exchangeRate + " " + branch.services.service.currencyExchange[0].sourceCurrency
		let stack = createStack(contentLableText: content, name: "exchangeRate")
			return stack
		}
		if let infobox = infobox {
			let content = infobox.cashInExist?.rawValue
			let stack = createStack(contentLableText: content!, name: "Сервисы")
			return stack
		}
		return UIStackView()
	}()

	private lazy var availabilityStack: UIStackView = {
		var time: String
		if let atm = atm {
			if atm.availability.access24Hours {
				time = "Круглосуточно"
			} else {
				time = atm.availability.standardAvailability.day[0].openingTime.rawValue
				+ "-" + atm.availability.standardAvailability.day[0].closingTime.rawValue
			}
			let stack = createStack(contentLableText: time,
									name: "На данный момент")
			return stack
		}
		if let branch = branch {
			time = branch.information.availability.standardAvailability.day[0].openingTime
			+ "-" + branch.information.availability.standardAvailability.day[0].closingTime

			let stack = createStack(contentLableText: time,
									name: "На данный момент")
			return stack
		}
		if let infobox = infobox {

			time = infobox.timeLong!
			let stack = createStack(contentLableText: time,
									name: "На данный момент")
			return stack
		}
		return UIStackView()
	}()

	private lazy var contactDetailsStack: UIStackView = {
		let phone: String
		if let atm = atm {
			if atm.contactDetails.phoneNumber == "" {
				phone = "недоступно"
			} else {
				phone = atm.contactDetails.phoneNumber
			}
			let stack = createStack(contentLableText: phone, name: "Контактная информация")
			return stack
		}
		if let branch = branch {
			let stack = createStack(contentLableText: branch.information.contactDetails.phoneNumber , name: "Контактная информация")
			return stack
		}
		if let infobox = infobox {
			let stack = createStack(contentLableText: "нет информации", name: "Контактная информация")
			return stack
		}
		return UIStackView()
	}()

	private lazy var otherStack: UIStackView = {
		if let atm = atm {
		let stack = createStack(contentLableText: atm.baseCurrency.rawValue, name: "Базовая валюта")
			return stack
		}
		return UIStackView()
	}()

	init(atm: ATM?, branch: BranchElement?, infobox: InfoBox?) {
		super.init(nibName: nil, bundle: nil)
		if let atm = atm {
			self.atm = atm
			title = atm.address.townName
		}
		if let branch = branch {
			self.branch = branch
			title = branch.address.addressLine
		}
		if let infobox = infobox {
			self.infobox = infobox
			title = infobox.address
		}
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		view.addSubview(scrollView)
		view.addSubview(routButton)

		navigationItem.leftBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .close,
			target: self,
			action: #selector(done))

		scrollView.addSubview(atmStack)
		scrollView.addSubview(typeStack)
		scrollView.addSubview(cardsStack)
		scrollView.addSubview(addessStack)
		scrollView.addSubview(serviceStack)
		scrollView.addSubview(currencyStack)
		scrollView.addSubview(availabilityStack)
		scrollView.addSubview(otherStack)
		scrollView.addSubview(contactDetailsStack)
		addConstraints()
	}

	@objc func createRoute() {
		if let atm = atm {
			guard let lat = Double(atm.address.geolocation.geographicCoordinates.latitude) else {
				return
			}
			guard  let lng = Double(atm.address.geolocation.geographicCoordinates.longitude) else {
				return
			}
			let source = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Source")
			let destination = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Destination")

			MKMapItem.openMaps(
				with: [source, destination],
				launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
			)
		}
		if let branch = branch {
			guard let lat = Double(branch.address.geoLocation.geographicCoordinates.latitude) else {
				return
			}
			guard  let lng = Double(branch.address.geoLocation.geographicCoordinates.latitude) else {
				return
			}
			let source = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Source")
			let destination = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Destination")

			MKMapItem.openMaps(
				with: [source, destination],
				launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
			)
		}

		if let infobox = infobox {
			guard let lat = Double(infobox.gpsX! ) else {return}
			guard  let lng = Double(infobox.gpsY! ) else {return}
			let source = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Source")
			let destination = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Destination")

			MKMapItem.openMaps(
				with: [source, destination],
				launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
			)
		}
	}

	@objc func done () {
		dismiss(animated: true)
	}

	private func addConstraints () {
		scrollView.snp.makeConstraints { (make) -> Void in
			make.leading.trailing.equalToSuperview()
			make.top.equalToSuperview().inset(50)
			make.bottom.equalToSuperview().inset(70)
		}

		atmStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(scrollView).inset(sideOffset)
		}

		typeStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(atmStack.snp_bottomMargin).inset(-sideOffset)
		}

		cardsStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(typeStack.snp_bottomMargin).inset(-sideOffset)
		}

		addessStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(cardsStack.snp_bottomMargin).inset(-sideOffset)
		}

		serviceStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(addessStack.snp_bottomMargin).inset(-sideOffset)
		}

		currencyStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(serviceStack.snp_bottomMargin).inset(-sideOffset)
		}

		availabilityStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(currencyStack.snp_bottomMargin).inset(-sideOffset)
		}

		otherStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(availabilityStack.snp_bottomMargin).inset(-sideOffset)
		}

		contactDetailsStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(otherStack.snp_bottomMargin).inset(-sideOffset)
		}

		routButton.snp.makeConstraints { (make) -> Void in
			make.leading.trailing.equalToSuperview().inset(30)
			make.bottom.equalToSuperview().inset(30)
		}
	}

	private func createStack(contentLableText: String, name: String) -> UIStackView {
		let lableName = UILabel()
		lableName.text = name
		lableName.font = UIFont.systemFont(ofSize: 10)
		lableName.textColor = .label
		let contentLable = UILabel()
		contentLable.text = contentLableText
		contentLable.font = UIFont.systemFont(ofSize: 20)
		contentLable.lineBreakMode = .byWordWrapping
		contentLable.lineBreakStrategy = .pushOut
		contentLable.textAlignment = .center
		contentLable.numberOfLines = 0

		let stack = UIStackView(arrangedSubviews: [lableName, contentLable])
		stack.translatesAutoresizingMaskIntoConstraints = false
		stack.axis = .vertical
		stack.alignment = .center
		stack.addSubview(contentLable)
		stack.addSubview(lableName)

		lableName.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalToSuperview()
		}
		contentLable.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(lableName.snp_topMargin).inset(3)
		}
		return stack
	}
}

extension MKMapItem {
  convenience init(coordinate: CLLocationCoordinate2D, name: String) {
    self.init(placemark: .init(coordinate: coordinate))
    self.name = name
  }
}
