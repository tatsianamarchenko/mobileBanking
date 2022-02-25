//
//  ButtomPresentationViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 23.02.22.
//

import UIKit

class ButtomPresentationViewController: UIViewController {

  public var complition: (([ATM]) -> Void)?
  var atm: ATM
  private lazy var infoButton: UIButton = {
    var button = UIButton(type: .roundedRect)
    button.setTitle("open full  info", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
    button.imageView?.contentMode = .scaleAspectFit
    button.backgroundColor = .systemGray6
    button.clipsToBounds = true
    button.layer.cornerRadius = 10
    button.addTarget(self, action: #selector(openFullInfoVC), for: .touchUpInside)
    return button
  }()

  private lazy var adressOfATMLable = UILabel()
  private lazy var timeOfWorkLable = UILabel()
  private lazy var currancyLable = UILabel()
  private lazy var cashInLable = UILabel()

  private lazy var placeStack: UIStackView = {
    let stack = createStack(contentLable: adressOfATMLable, name: "Место установки банкомата")
    return stack
  }()

  private lazy var timeStack: UIStackView = {
    let stack = createStack(contentLable: timeOfWorkLable, name: "Режим работы")
    return stack
  }()

  private lazy var currenceStack: UIStackView = {
    let stack = createStack(contentLable: currancyLable, name: "Выдаваемая валюта")
    return stack
  }()

  private lazy var cashInStack: UIStackView = {
    let stack = createStack(contentLable: cashInLable, name: "Cash in")
    return stack
  }()

  init(adressOfATM: String, atm: ATM, timeOfWork: String, currancy: String, cashIn: String) {
    self.atm = atm
    super.init(nibName: nil, bundle: nil)
    self.adressOfATMLable.text = adressOfATM
    self.timeOfWorkLable.text = timeOfWork
    self.currancyLable.text = currancy
    self.cashInLable.text = cashIn

  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = .systemBackground

    view.addSubview(placeStack)
    view.addSubview(timeStack)
    view.addSubview(currenceStack)
    view.addSubview(cashInStack)
    view.addSubview(infoButton)
    placeStack.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview().inset(10)
      make.top.equalToSuperview().inset(30)
    }
    timeStack.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalTo(placeStack)
      make.top.equalTo(placeStack.snp_bottomMargin).inset(-3)
    }
    currenceStack.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalTo(placeStack)
      make.top.equalTo(timeStack.snp_bottomMargin).inset(-3)
    }
    cashInStack.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalTo(placeStack)
      make.top.equalTo(currenceStack.snp_bottomMargin).inset(-3)
    }
    infoButton.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview().inset(10)
      make.bottom.equalToSuperview().inset(80)
    }
  }

  @objc func didTapClose() {
    dismiss(animated: true)
  }

  private func createStack(contentLable: UILabel, name: String) -> UIStackView {
    let lableName = UILabel()
    lableName.text = name
    lableName.font = UIFont.systemFont(ofSize: 10)
    lableName.textColor = .label

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

  @objc func openFullInfoVC() {
    let detailNavController = FullInformationViewController(id: atm.atmID,
                                                            type: atm.type.rawValue,
                                                            card: atm.cards[0].rawValue,
                                                            adress: atm.address.addressLine,
                                                            accessebility: atm.accessibilities.debugDescription,
                                                            availability: atm.availability.access24Hours.description,
                                                            contact: atm.contactDetails.phoneNumber,
                                                            service: atm.services[0].serviceType.rawValue,
                                                            currency: atm.currency.rawValue,
                                                            lat:   Double(atm.address.geolocation.geographicCoordinates.latitude)!,
                                                            lng: Double(atm.address.geolocation.geographicCoordinates.longitude)!)
    present(detailNavController, animated: true, completion: nil)
  }
}
