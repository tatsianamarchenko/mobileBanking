//
//  ButtomPresentationViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 23.02.22.
//

import UIKit

class ButtomPresentationViewController: UIViewController {

  public var complition : (([ATM]) -> Void)?

  private lazy var infoButton: UIButton = {
    var button = UIButton(type: .roundedRect)
    button.setTitle("open full  info", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    button.setTitle("bdvbc", for: .highlighted )
    button.imageView?.contentMode = .scaleAspectFit
    button.addTarget(self, action: #selector(openFullInfoVC), for: .touchUpInside)
    return button
  }()
  @objc func openFullInfoVC() {
  //  complition.map { _ in
    let detailNavController = FullInformationViewController(fullInformationTextView: "fgdsvdfs",
                                                            lat: 33.453,
                                                            lng: 435.32)
    present(detailNavController, animated: true, completion: nil)
    }

  private lazy var adressOfATMLable: UILabel = {
    var text = UILabel()
    text.numberOfLines = 0
    text.text = "adressOfATMLable"
    return text
  }()

  private lazy var timeOfWorkLable: UILabel = {
    var text = UILabel()
    text.text = "timeOfWorkLable"
    return text
  }()

  private lazy var currancyLable: UILabel = {
    var text = UILabel()
    text.text = "fvbdghfhdng"
    return text
  }()

  private lazy var cashInLable: UILabel = {
    var text = UILabel()
    text.text = "fvbdghfhdng"
    return text
  }()

  init(adressOfATM: String, timeOfWork: String, currancy: String, cashIn: String) {
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
    view.addSubview(adressOfATMLable)
    view.addSubview(timeOfWorkLable)
    view.addSubview(currancyLable)
    view.addSubview(cashInLable)
    view.addSubview(infoButton)

    adressOfATMLable.snp.makeConstraints { (make) -> Void in
      make.centerX.equalToSuperview()
      make.top.equalToSuperview().inset(30)
    }

    timeOfWorkLable.snp.makeConstraints { (make) -> Void in
      make.centerX.equalToSuperview()
      make.top.equalTo(adressOfATMLable.snp_topMargin).inset(30)
    }

    currancyLable.snp.makeConstraints { (make) -> Void in
      make.centerX.equalToSuperview()
      make.top.equalTo(timeOfWorkLable.snp_topMargin).inset(30)
    }

    cashInLable.snp.makeConstraints { (make) -> Void in
      make.centerX.equalToSuperview()
      make.top.equalTo(currancyLable.snp_topMargin).inset(30)
    }

    infoButton.snp.makeConstraints { (make) -> Void in
      make.centerX.equalToSuperview()
      make.top.equalTo(cashInLable.snp_topMargin).inset(20)
    }
  }
}
