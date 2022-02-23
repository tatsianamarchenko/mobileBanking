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
    scrollView.backgroundColor = .systemPink
    return scrollView
  }()

  private lazy var routButton: UIButton = {
    var button = UIButton(type: .roundedRect)
    button.setTitle("create rout", for: .normal)
    button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    button.setTitle("", for: .highlighted )
    button.imageView?.contentMode = .scaleAspectFit
    button.addTarget(self, action: #selector(createRout), for: .touchUpInside)
    return button
  }()

  private lazy var fullInformationTextView: UITextView = {
    var text = UITextView()
    text.isSelectable = true
    return text
  }()
  var lng: Double = 0
  var lat: Double = 0
  init(fullInformationTextView: String, lat: Double, lng: Double) {
    super.init(nibName: nil, bundle: nil)
    self.fullInformationTextView.text = fullInformationTextView
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
    view.backgroundColor = .systemMint
    view.addSubview(scrollView)
    view.addSubview(routButton)
    view.addSubview(fullInformationTextView)
    scrollView.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview()
      make.top.equalToSuperview().inset(50)
      make.bottom.equalToSuperview().inset(50)
    }

    fullInformationTextView.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalTo(scrollView).inset(10)
      make.top.equalTo(scrollView.snp_topMargin).inset(10)
      make.bottom.equalTo(scrollView.snp_bottomMargin).inset(10)
    }

    routButton.snp.makeConstraints { (make) -> Void in
      make.leading.trailing.equalToSuperview().inset(30)
      make.bottom.equalToSuperview().inset(10)
    }
  }
}

extension MKMapItem {
  convenience init(coordinate: CLLocationCoordinate2D, name: String) {
    self.init(placemark: .init(coordinate: coordinate))
    self.name = name
  }
}
