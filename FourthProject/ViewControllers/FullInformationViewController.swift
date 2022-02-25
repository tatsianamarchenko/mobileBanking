//
//  FullInformationViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 23.02.22.
//

import UIKit
import MapKit

class FullInformationViewController: UIViewController {

  private lazy var scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.alwaysBounceVertical = true
    return scrollView
  }()

  private lazy var routButton: UIButton = {
    var button = UIButton(type: .roundedRect)
    button.setTitle("create rout", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 30, weight: .bold)
    button.setTitle("", for: .highlighted )
    button.imageView?.contentMode = .scaleAspectFit
    button.backgroundColor = .systemGray6
    button.clipsToBounds = true
    button.layer.cornerRadius = 10
    button.addTarget(self, action: #selector(createRout), for: .touchUpInside)
    return button
  }()

private lazy var atmlable = UILabel()
  private lazy var typelable = UILabel()
  private lazy var currencylable = UILabel()
  private lazy var cardslable = UILabel()
  private lazy var currentStatuslable = UILabel()
  private lazy var addesslable = UILabel()
  private lazy var servicelable = UILabel()
  private lazy var availabilitylable = UILabel()
  private lazy var contactDetailslable = UILabel()
  private lazy var accessibilitylable = UILabel()

  private lazy var atmStack: UIStackView = {
    let stack = createStack(contentLable: atmlable, name: "ID")
    return stack
  }()

  private lazy var typeStack: UIStackView = {
    let stack = createStack(contentLable: typelable, name: "Тип")
    return stack
  }()

  private lazy var currencyStack: UIStackView = {
    let stack = createStack(contentLable: currencylable, name: "Валюта")
    return stack
  }()

  private lazy var cardsStack: UIStackView = {
    let stack = createStack(contentLable: cardslable, name: "Карты")
    return stack
  }()

  private lazy var addessStack: UIStackView = {
    let stack = createStack(contentLable: addesslable, name: "Адрес")
    return stack
  }()

  private lazy var serviceStack: UIStackView = {
    let stack = createStack(contentLable: servicelable, name: "Сервисы")
    return stack
  }()

  private lazy var availabilityStack: UIStackView = {
    let stack = createStack(contentLable: availabilitylable, name: "На данный момент")
    return stack
  }()

  private lazy var contactDetailsStack: UIStackView = {
    let stack = createStack(contentLable: contactDetailslable, name: "Контактная информация")
    return stack
  }()

  private lazy var accessibilityStack: UIStackView = {
    let stack = createStack(contentLable: accessibilitylable, name: "Доступность")
    return stack
  }()

  var lng: Double = 0
  var lat: Double = 0
  init(id: String,
       type: String,
       card: String,
       adress: String,
       accessebility: String,
       availability: String,
       contact: String,
       service: String,
       currency: String,
       lat: Double,
       lng: Double) {
    super.init(nibName: nil, bundle: nil)
    self.atmlable.text = id
    self.typelable.text = type
    self.cardslable.text = card
    self.addesslable.text = adress
    self.accessibilitylable.text = accessebility
    self.availabilitylable.text = availability
    self.contactDetailslable.text = contact
    self.servicelable.text = service
    self.currencylable.text = currency
    self.lat = lat
    self.lng = lng
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  @objc func createRout() {
    let source = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Source")
    let destination = MKMapItem(coordinate: .init(latitude: lat, longitude: lng), name: "Destination")

    MKMapItem.openMaps(
      with: [source, destination],
      launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    )
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground

    view.addSubview(scrollView)
    view.addSubview(routButton)

    scrollView.addSubview(atmStack)
    scrollView.addSubview(typeStack)
    scrollView.addSubview(cardsStack)
    scrollView.addSubview(addessStack)
    scrollView.addSubview(serviceStack)
    scrollView.addSubview(currencyStack)
    scrollView.addSubview(availabilityStack)
    scrollView.addSubview(accessibilityStack)
    scrollView.addSubview(contactDetailsStack)

    scrollView.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().inset(50)
      make.bottom.equalToSuperview().inset(70)
    }

    atmStack.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalTo(scrollView).inset(10)
      make.top.equalTo(scrollView).inset(10)
    }

  typeStack.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalTo(scrollView).inset(10)
    make.top.equalTo(atmlable.snp_bottomMargin).inset(-10)
    }

    cardsStack.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalTo(scrollView).inset(10)
        make.top.equalTo(typeStack.snp_bottomMargin).inset(-10)
      }

    addessStack.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalTo(scrollView).inset(10)
        make.top.equalTo(cardsStack.snp_bottomMargin).inset(-10)
      }

    serviceStack.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalTo(scrollView).inset(10)
        make.top.equalTo(addessStack.snp_bottomMargin).inset(-10)
      }

    currencyStack.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalTo(scrollView).inset(10)
        make.top.equalTo(serviceStack.snp_bottomMargin).inset(-10)
      }

    availabilityStack.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalTo(scrollView).inset(10)
        make.top.equalTo(currencylable.snp_bottomMargin).inset(-10)
      }

    accessibilityStack.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalTo(scrollView).inset(10)
        make.top.equalTo(availabilityStack.snp_bottomMargin).inset(-10)
      }

    contactDetailsStack.snp.makeConstraints { (make) -> Void in
        make.leading.trailing.equalTo(scrollView).inset(10)
        make.top.equalTo(accessibilityStack.snp_bottomMargin).inset(-10)
      }

    routButton.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview().inset(30)
      make.bottom.equalToSuperview().inset(30)
    }
  }

  private func createStack(contentLable: UILabel, name: String) -> UIStackView {
    let lableName = UILabel()
    lableName.text = name
    lableName.font = UIFont.systemFont(ofSize: 10)
    lableName.textColor = .label

    contentLable.font = UIFont.systemFont(ofSize: 20)
    contentLable.numberOfLines = 0

    let stack = UIStackView(arrangedSubviews: [lableName, contentLable])
    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.alignment = .leading
    stack.addSubview(contentLable)
    stack.addSubview(lableName)

    lableName.snp.makeConstraints { (make) -> Void in
      make.leading.equalToSuperview()
      make.top.equalToSuperview()
    }
    contentLable.snp.makeConstraints { (make) -> Void in
      make.leading.equalToSuperview()
      make.top.equalTo(lableName.snp_topMargin)
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
