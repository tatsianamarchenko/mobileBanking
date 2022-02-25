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
  var arrayq = [ATM]()
  var array = [String]()
  var array1 = [String]()

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
      self.createPins()
    }))
    return alert
  }()

  var mapView: MKMapView = {
    var map = MKMapView()
    let minskCenter = CLLocation(latitude: 53.716, longitude: 27.9776)
    map.centerToLocation(minskCenter, regionRadius: 650000)
    let region = MKCoordinateRegion(
      center: minskCenter.coordinate,
      latitudinalMeters: 10000,
      longitudinalMeters: 10000)
    map.register(MKMarkerAnnotationView.self,
                 forAnnotationViewWithReuseIdentifier: NSStringFromClass(MapPinAnnotation.self))
    //    map.setCameraBoundary(
    //         MKMapView.CameraBoundary(coordinateRegion: region),
    //         animated: true)
    //
    //       let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
    //    map.setCameraZoomRange(zoomRange, animated: true)

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

    mapView.delegate = self

    monitor.pathUpdateHandler = { [self] path in
      switch path.status {
      case .satisfied :
        DispatchQueue.main.async {
          checkAccessToLocation()
        }
      case .unsatisfied :
        DispatchQueue.main.async {
          present(internetAccessAlert, animated: true)
        }
      case .requiresConnection :
        DispatchQueue.main.async {
          present(internetErrorAlert, animated: true)
        }
      default : break
      }
    }

    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
      self.createPins()
    monitor.cancel()

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

  func createPins () {
    let apiService = APIService(urlString: "https://belarusbank.by/open-banking/v1.0/atms")
    apiService.getJSON { [self] (atms: ATMResponse) in
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
        setPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber,
                                locationName: item.address.addressLine,
                                location: loc,
                                workTime: "item.availability.standardAvailability.day[0].",
                                currency: item.currency.rawValue,
                                isCash: item.currentStatus.rawValue)
        array.append(item.address.townName)
      }
    }
  }

  func setPinUsingMKAnnotation(title: String,
                               locationName: String,
                               location: CLLocationCoordinate2D,
                               workTime: String,
                               currency: String,
                               isCash: String) {
    DispatchQueue.main.async { [self] in
      let pinAnnotation = MapPinAnnotation(title: title,
                                 locationName: locationName,
                                 workTime: workTime,
                                 currency: currency,
                                 isCash: isCash,
                                 coordinate: location)
       mapView.addAnnotations([pinAnnotation])
    }
  }

func checkAuthorizationStatus() {
  switch locationManager.authorizationStatus {
  case .notDetermined :   locationManager.requestAlwaysAuthorization()
    fallthrough
  case .authorizedWhenInUse, .authorizedAlways :
    locationManager.startUpdatingLocation()
    mapView.showsUserLocation = true
    locationManager.stopUpdatingLocation()
  case .restricted, .denied :
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

}

extension MainViewController: CLLocationManagerDelegate {
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
  }
  func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      print(error.localizedDescription)
  }

  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
    let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
    let center = CLLocationCoordinate2D(latitude: locValue.latitude, longitude: locValue.longitude)
    manager.stopUpdatingHeading()
    DispatchQueue.main.async {
      self.mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
    }
  }
}

extension MainViewController: MKMapViewDelegate {

  func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    var annotationView: MKAnnotationView?
    if let annotation = annotation as? MapPinAnnotation {
      annotationView = setupAnnotationView(for: annotation, on: mapView)
    }
    return annotationView
  }

  private func setupAnnotationView(for annotation: MapPinAnnotation, on mapView: MKMapView) -> MKAnnotationView {
    let identifier = NSStringFromClass(MapPinAnnotation.self)
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

  func mapView(_ mapView: MKMapView,
               didSelect view: MKAnnotationView) {

    if let annotation = view.annotation as? MapPinAnnotation {
      let sheetViewController = ButtomPresentationViewController(adressOfATM: annotation.locationName,
                                                                 timeOfWork: annotation.workTime,
                                                                 currancy: annotation.currency,
                                                                 cashIn: annotation.isCash)
      if let sheet = sheetViewController.sheetPresentationController {
        sheet.prefersGrabberVisible = true
        sheet.preferredCornerRadius = 32
        sheet.prefersScrollingExpandsWhenScrolledToEdge = true
        sheet.prefersGrabberVisible = true
        sheet.detents = [.medium(), .large()]
      }
      present(sheetViewController, animated: true)
    }
  }
}

private extension MKMapView {
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

// При нажатии на точку показать всплывающее окно на карте с информацией о:
//
// место установки банкомата
// режим работы
// выдаваемая валюта
// есть ли cash in
// кнопка “Подробнее”
// Окно закрывается по нажатию вне области окна / по тапу на крестик в верхнем правом углу модального окна.
//
// Кнопка “Подробнее”
//
// При нажатию на это кнопку показать новый контроллер, на котором вывести всю доступную информацию о банкомате.
// 2) Список банкоматов
//
// При переходе на данный экран отображать банкоматы в виде списка-коллекции (UICollectionView) по 3 банкомата в ряд.
//
// Каждый банкомат представлен прямоугольной карточкой, на которой есть информация о:
//
// место установки банкомата
// режим работы
// выдаваемая валюта
// Нажатие на карточку банкомата возвращает пользователя на экран с картой,
// на которой нужно показать всплывающее окно с информацией о выбранном банкомате (окно идентичное тому,
// когда пользователь сам выбирает банкомат из точки на карте)
// 3) Кнопка обновить
//
// При нажатии на кнопку приложение запрашивает данные о банкоматах. Кнопка неактивна, пока выполняется запрос
// (по желанию можно поменять кнопку на крутящийся индикатор)
//
// Логика работы приложения
//
// При первом запуске приложение запрашивает доступ к геолокации пользователя. Если пользователь не разрешил доступ,
// то при последующих запусках уведомляем его об этом и предлагаем перейти в настройки,
// чтобы включить геолокацию (реализацию можно подсмотреть в Яндекс.Картах при выключенном доступе к геолокации)
//
// При каждом запуске приложения центрируем карту относительно текущего местоположения пользователя.
// Если она недоступна, то делаем так, чтобы была видна вся Беларусь на карте.
// До выполнения запроса проверить включен ли интернет.
// Если интернет-соединение отсутствует,
// то вывести алерт пользователю с информацией о том, что приложение не работает без доступа к интернету.
//
// При любой сетевой ошибке во время выполнения запроса показывать алерт с сообщением и кнопками “Повторить ещё раз”
// (выполняет повторно запрос) и “Закрыть” (закрывает алерт).
//
