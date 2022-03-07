//
//  ButtomPresentationBranchViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 7.03.22.
//

import UIKit

class ButtomPresentationBranchViewController: UIViewController {

	public var complition: (([BranchElement]) -> Void)?
	private var branch: BranchElement
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

	init(adressOfATM: String, branch: BranchElement, timeOfWork: String, currancy: String, cashIn: String) {
		self.branch = branch
		super.init(nibName: nil, bundle: nil)
		title = branch.address.townName
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

		navigationItem.rightBarButtonItem = UIBarButtonItem(
			barButtonSystemItem: .close,
			target: self,
			action: #selector(cancel))

		view.backgroundColor = .systemBackground

		view.addSubview(placeStack)
		view.addSubview(timeStack)
		view.addSubview(currenceStack)
		view.addSubview(cashInStack)
		view.addSubview(infoButton)

		createConstraints()
	}

	@objc func cancel() {
		dismiss(animated: true)
	}

	private func createConstraints() {
		placeStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(view.snp_topMargin)
		}
		timeStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(placeStack.snp_bottomMargin).inset(-3)
		}
		currenceStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(timeStack.snp_bottomMargin).inset(-3)
		}
		cashInStack.snp.makeConstraints { (make) -> Void in
			make.centerX.equalToSuperview()
			make.top.equalTo(currenceStack.snp_bottomMargin).inset(-3)
		}
		infoButton.snp.makeConstraints { (make) -> Void in
			make.leading.trailing.equalToSuperview().inset(screenSize.width*0.05)
			make.bottom.equalToSuperview().inset(80)
		}
	}

	@objc func done () {
		dismiss(animated: true)
	}

	private func createStack(contentLable: UILabel, name: String) -> UIStackView {
		let lableName = UILabel()
		lableName.text = name
		lableName.font = UIFont.systemFont(ofSize: 10)
		lableName.textColor = .label

		contentLable.numberOfLines = 0

		let stack = UIStackView(arrangedSubviews: [lableName, contentLable])
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
			make.top.equalTo(lableName.snp_topMargin).inset(sideOffset)
		}
		return stack
	}

	@objc func openFullInfoVC() {
		let detailNavController = FullInformationViewController(atm: nil, branch: branch, infobox: nil)
		let navController = UINavigationController(rootViewController: detailNavController)
		present(navController, animated: true, completion: nil)
	}
}
