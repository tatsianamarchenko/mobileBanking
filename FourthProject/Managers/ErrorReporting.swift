//
//  ErrorReporting.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 25.06.22.
//

import UIKit

class ErrorReporting {
	static let share = ErrorReporting()
	func showGeneralMessage(title: String, msg: String, on controller: UIViewController) {
		let alert = UIAlertController(title: title, message: msg, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
		controller.present(alert, animated: true, completion: nil)
	}

	func showNoAccessToInternetConnectionandReloadMessage(on controller: UIViewController, complition: @escaping () -> Void) {
		let alert = UIAlertController(title: "No access to internet connection",
									  message: "приложение не работает без доступа к интернету.",
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Повторить ещё раз", style: .default, handler: { _ in
			complition()
		}))
		controller.present(alert, animated: true, completion: nil)
	}

	func showNoAccessTointernetConnectionMessage(on controller: UIViewController) {
		let alert = UIAlertController(title: "No access to internet connection",
									  message: "приложение не работает без доступа к интернету.",
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
		controller.present(alert, animated: true, completion: nil)
	}

	func showNoAccessToLocationMessage(on controller: UIViewController, complition: @escaping () -> Void) {
		let alert = UIAlertController(title: "у приложения нет доступа к локации", message: "", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: NSLocalizedString("access", comment: ""), style: .default, handler: { _ in
			complition()
		}))
		controller.present(alert, animated: true, completion: nil)
	}

	func createErrorAlert (errorString: String, on controller: UIViewController, complition: @escaping () -> Void) {
		let alert = UIAlertController(title: "No access to internet connection",
									  message: "не удалось загрузить  \(errorString)",
									  preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "Закрыть", style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: "Повторить ещё раз", style: .default, handler: { _ in
			complition()
		}))
		controller.present(alert, animated: true, completion: nil)
	}
}
