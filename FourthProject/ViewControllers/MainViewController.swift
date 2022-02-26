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
  var coor: CLLocation?
  init (coor: CLLocation?) {
    super.init(nibName: nil, bundle: nil)
    self.coor = coor
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
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
      self.createPins()
    }))
    return alert
  }()

  var mapView: MKMapView = {
    var map = MKMapView()
    let minskCenter = CLLocation(latitude: 53.716, longitude: 27.9776)
    map.centerToLocation(minskCenter)
    let region = MKCoordinateRegion(
      center: minskCenter.coordinate,
      latitudinalMeters: 10000,
      longitudinalMeters: 10000)
    map.register(MKMarkerAnnotationView.self,
                 forAnnotationViewWithReuseIdentifier: NSStringFromClass(MapPinAnnotation.self))
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

    if coor != nil {
      mapView.centerToLocation(coor!, regionRadius: 3000)
    }
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

        var openingTime = [String]()
        var closingTime = [String]()
        for index in 0..<item.availability.standardAvailability.day.count {
          openingTime.append(item.availability.standardAvailability.day[index].openingTime.rawValue)
          closingTime.append(item.availability.standardAvailability.day[index].closingTime.rawValue)
        }

        let loc = CLLocationCoordinate2D(latitude: latitude,
                                         longitude: longitude)
        setPinUsingMKAnnotation(title: item.address.streetName + " " + item.address.buildingNumber, atm: item,
                                location: loc)

      }
    }
  }

  func setPinUsingMKAnnotation(title: String,
                               atm: ATM,
                               location: CLLocationCoordinate2D) {
    DispatchQueue.main.async { [self] in
      let pinAnnotation = MapPinAnnotation(title: title,
                                           atm: atm,
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
    break
  }
}

}

extension MainViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else {
      return }
    manager.stopUpdatingLocation()
    mapView.centerToLocation(CLLocation(latitude: locValue.latitude, longitude: locValue.longitude), regionRadius: 3000)
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
                                                                 atm: atm,
                                                                 timeOfWork:
                                                                  atm.availability.standardAvailability.day[0]
                                                                  .openingTime.rawValue
                                                                 + "-" +
                                                                 atm.availability.standardAvailability.day[0]
                                                                  .closingTime.rawValue
                                                                 + " " + breake,
                                                                 currancy: atm.currency.rawValue,
                                                                 cashIn: abc)
      mapView.centerToLocation(CLLocation(latitude: annotation.coordinate.latitude,
                                          longitude: annotation.coordinate.longitude),
                               regionRadius: 3000)

      let nav = UINavigationController(rootViewController: sheetViewController)
      nav.modalPresentationStyle = .automatic
      if let sheet = nav.sheetPresentationController {
          sheet.detents = [.medium(), .large()]
      }
      present(nav, animated: true, completion: nil)
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

//При нажатии на точку показать всплывающее окно на карте с информацией о:
//
//место установки банкомата
//режим работы
//выдаваемая валюта
//есть ли cash in
//кнопка “Подробнее”
//Окно закрывается по нажатию вне области окна / по тапу на крестик в верхнем правом углу модального окна.
//
//Кнопка “Подробнее”
//
//При нажатию на это кнопку показать новый контроллер, на котором вывести всю доступную информацию о банкомате.
//
//Если информация не помещается на экран, то она должна скроллиться.
//
//В самом низу экрана расположить кнопку “Построить маршрут”, которая перебрасывает пользователя в карты, установленные на его телефоне,
// с построенным маршрутом от текущего местоположения пользователя до банкомата.
// Кнопка “Построить маршрут” видна внизу экрана всегда. Контент, который не влазит, скроллится выше кнопки.
//
//2) Список банкоматов
//
//При переходе на данный экран отображать банкоматы в виде списка-коллекции (UICollectionView) по 3 банкомата в ряд.
//
//Каждый банкомат представлен прямоугольной карточкой, на которой есть информация о:
//
//место установки банкомата
//режим работы
//выдаваемая валюта
//Нажатие на карточку банкомата возвращает пользователя на экран с картой,
// на которой нужно показать всплывающее окно с информацией о выбранном банкомате (окно идентичное тому, когда пользователь сам выбирает банкомат из точки на карте)
//
//Банкоматы в коллекции сгруппированы по городу (в заголовке каждой секции вывести название города). Внутри секции банкоматы сортируются по atmId по возрастанию.
//
//3) Кнопка обновить
//
//При нажатии на кнопку приложение запрашивает данные о банкоматах. Кнопка неактивна, пока выполняется запрос (по желанию можно поменять кнопку на крутящийся индикатор)
//
//Логика работы приложения
//
//При первом запуске приложение запрашивает доступ к геолокации пользователя. Если пользователь не разрешил доступ, то при последующих запусках уведомляем его об этом и предлагаем перейти в настройки,
// чтобы включить геолокацию (реализацию можно подсмотреть в Яндекс.Картах при выключенном доступе к геолокации)
//
//При каждом запуске приложения центрируем карту относительно текущего местоположения пользователя. Если она недоступна, то делаем так, чтобы была видна вся Беларусь на карте.
//
//Приложение запрашивает банкоматы у API и отображает их на карте в виде точек и в виде списка-коллекции.
//
//До выполнения запроса проверить включен ли интернет. Если интернет-соединение отсутствует, то вывести алерт пользователю с информацией о том, что приложение не работает без доступа к интернету.
//
//При любой сетевой ошибке во время выполнения запроса показывать алерт с сообщением и кнопками “Повторить ещё раз” (выполняет повторно запрос) и “Закрыть” (закрывает алерт).
