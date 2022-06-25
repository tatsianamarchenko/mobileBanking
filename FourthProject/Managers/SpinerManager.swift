//
//  SpinerManager.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 25.06.22.
//

import Foundation
import UIKit

class SpinerManager {
	var spiner: UIActivityIndicatorView = {
		var spiner = UIActivityIndicatorView(style: .large)
		return spiner
	}()

	func addSpinner(view: UIView) {
		view.addSubview(spiner)
		DispatchQueue.main.async {
			self.spiner.startAnimating()
			self.spiner.snp.makeConstraints { (make) -> Void in
				make.centerY.equalToSuperview()
				make.centerX.equalToSuperview()
			}
		}
	}

	func removeSpiner(spiner: UIActivityIndicatorView) {
		spiner.stopAnimating()
		spiner.removeFromSuperview()
	}
}
