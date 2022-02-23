//
//  ViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit
import SnapKit
import MapKit
import Network

class MainViewController: UIViewController {
  let monitor = NWPathMonitor()
  let locationManager = CLLocationManager()
  var arrayq = [ATM]()
  var array = [String]()
  var array1 = [String]()

   var alert: UIAlertController = {
    let alert = UIAlertController(title: "интернет на телефоне отключен", message: "", preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
    return alert
  }()

  private var displayedAnnotations: [MKAnnotation]? {
      willSet {
          if let currentAnnotations = displayedAnnotations {
              mapView.removeAnnotations(currentAnnotations)
          }
      }
      didSet {
          if let newAnnotations = displayedAnnotations {
              mapView.addAnnotations(newAnnotations)
          }
        centerMapOnMinsk()
      }
  }

  private func centerMapOnMinsk() {
      let span = MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
      let center = CLLocationCoordinate2D(latitude: 53.716, longitude: 27.9776)
      mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
  }

  var mapView: MKMapView = {
    var map = MKMapView()
    let minskCenter = CLLocation(latitude: 53.716, longitude: 27.9776)
    map.centerToLocation(minskCenter)
    let region = MKCoordinateRegion(
      center: minskCenter.coordinate,
      latitudinalMeters: 10000,
      longitudinalMeters: 10000)
    map.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(MapPinAnnotation.self))
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

    monitor.pathUpdateHandler = { [self] path in
      switch path.status {
      case .satisfied :
        DispatchQueue.main.async {
          checkAccessToLocation()
        }
      case .unsatisfied :
        DispatchQueue.main.async {
          present(alert, animated: true)
        }
      default : break
      }
    }

    let queue = DispatchQueue(label: "Monitor")
    monitor.start(queue: queue)
    mapView.delegate = self
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
      setUpManager()
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
        let latitude = NumberFormatter().number(from:
                                                  item.address.geolocation.geographicCoordinates.latitude)!.doubleValue

        let longitude = NumberFormatter().number(from:
                                                  item.address.geolocation.geographicCoordinates.longitude)!.doubleValue

        let loc = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        setPinUsingMKAnnotation(title: item.address.streetName+" "+item.address.buildingNumber,
                                locationName: item.address.addressLine,
                                location: loc, workTime: "item.availability.standardAvailability.day[0].", currency: item.currency.rawValue, isCash: item.currentStatus.rawValue)



        array.append(item.address.townName)

      }

      let filteredArray = Array(NSOrderedSet(array: array)) as? [String]
   print(filteredArray!)
    }
  }

  func setPinUsingMKAnnotation(title: String, locationName: String, location: CLLocationCoordinate2D, workTime: String, currency: String, isCash: String) {
    DispatchQueue.main.async { [self] in
      let pinAnnotation = MapPinAnnotation(title: title,
                                 locationName: locationName,
                                 workTime: workTime,
                                 currency: currency,
                                 isCash: isCash,
                                 coordinate: location)
       let coordinateRegion = MKCoordinateRegion(center: pinAnnotation.coordinate,
                                                 latitudinalMeters: 5000,
                                                 longitudinalMeters: 5000)
     //  mapView.setRegion(coordinateRegion, animated: true)
       mapView.addAnnotations([pinAnnotation])
    }
  }

func checkAuthorizationStatus() {
  switch locationManager.authorizationStatus {
  case .notDetermined :   locationManager.requestAlwaysAuthorization()
  case .authorizedWhenInUse, .authorizedAlways :
    mapView.showsUserLocation = true
    locationManager.startUpdatingLocation()

  case   .restricted, .denied :
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

  func setUpManager () {
    locationManager.delegate = self
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
  }
}

extension MainViewController: CLLocationManagerDelegate, MKMapViewDelegate {

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
      let sheetViewController = ButtomPresentationViewController(adressOfATM: annotation.locationName, timeOfWork: annotation.workTime, currancy: annotation.currency, cashIn: annotation.isCash)
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
    
  //{
  //          let detailNavController = FullInformationViewController(fullInformationTextView: annotation.title!!,
  //                                                                  lat: annotation.coordinate.latitude,
  //                                                                  lng: annotation.coordinate.longitude)
  //          detailNavController.modalPresentationStyle = .popover
  //          let presentationController = detailNavController.popoverPresentationController
  //          presentationController?.permittedArrowDirections = .any
  //          present(detailNavController, animated: true, completion: nil)
  //        }
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

// На главном экране отображается нав. бар с заголовком и кнопкой обновить в правом верхнем углу.
//
// Под нав. баром добавить UISegmentedControl, который переключается между картой и списком. По умолчанию выбрана карта.
//
// 1) Карта с банкоматами
//
// Можно использовать Apple Maps / Google Maps / Yandex Maps.
//
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
//
// Если информация не помещается на экран, то она должна скроллиться.
//
// В самом низу экрана расположить кнопку “Построить маршрут”,
// которая перебрасывает пользователя в карты, установленные на его телефоне,
// с построенным маршрутом от текущего местоположения пользователя до банкомата.
// Кнопка “Построить маршрут” видна внизу экрана всегда.
// Контент, который не влазит, скроллится выше кнопки.
//
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
//
// Банкоматы в коллекции сгруппированы по городу (в заголовке каждой секции вывести название города).
// Внутри секции банкоматы сортируются по atmId по возрастанию.
//
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
//
// Приложение запрашивает банкоматы у API и отображает их на карте в виде точек и в виде списка-коллекции.
//
// До выполнения запроса проверить включен ли интернет.
// Если интернет-соединение отсутствует,
// то вывести алерт пользователю с информацией о том, что приложение не работает без доступа к интернету.
//
// При любой сетевой ошибке во время выполнения запроса показывать алерт с сообщением и кнопками “Повторить ещё раз”
// (выполняет повторно запрос) и “Закрыть” (закрывает алерт).
//

//можешь сделать список городов, если их немного (эт не обязательно, просто ответ должен быть больше 20 символов)
//enum Cities: String { case moscow = “Москва”}
//
//и просто используешь фильтр
//
//ports.filter{$0.city == Cities.moscow}
//
//И это не сортировка, а фильтрация. Сортировка - это, когда ты упорядочиваешь элементы массива согласно определенной логике



//      for index in 0..<self.arrayOfATMs.count {
//        array.append(self.arrayOfATMs[index].address.townName)
//      }
//
//      sectionsNameArray = (Array(NSOrderedSet(array: array)) as? [String])!
//      print(sectionsNameArray.count)



//var sectionItems: [String:[Person]] = [:]
//пример результата закомментированы справой стороны переменных(в самом начале)
//пониже так-же отписал что никак не выведу:
//
//self.sectionItems = ...
//["2019":[соответствующий массив где года равны 2019]]
//["2018":[соответствующий массив где года равны 2018]]
//let sectionItems = Dictionary(grouping: peopleArray, by: { String($0.date.prefix(4)) })
