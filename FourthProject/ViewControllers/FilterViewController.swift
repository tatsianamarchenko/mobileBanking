//
//  FilterViewController.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 5.03.22.
//

import UIKit
import MapKit

struct FilterModel {
  var isChecked: Bool
  var name: String
}

var filteredArray = [FilterModel(isChecked: true, name: "ATMs"),
					 FilterModel(isChecked: true, name: "INFOBOXes"),
					 FilterModel(isChecked: true, name: "BRANCHes")]

class FilterViewController: UIViewController {
  var identifier = "FilteredCell"
  public var complition: ((Int?) -> Void)?

  private lazy var table: UITableView = {
	let table = UITableView()
	table.register(UITableViewCell.self, forCellReuseIdentifier: identifier)
	table.translatesAutoresizingMaskIntoConstraints = false
	return table
  }()

  override func viewDidLoad() {
	super.viewDidLoad()
	view.backgroundColor = .systemBackground
	view.addSubview(table)

	table.dataSource = self
	table.delegate = self

	table.snp.makeConstraints { (make) -> Void in
	  make.leading.trailing.equalToSuperview()
	  make.top.equalToSuperview()
	  make.bottom.equalToSuperview()
	}
  }
}

extension  FilterViewController: UITableViewDelegate, UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
	return filteredArray.count
  }

  func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
	30
  }

  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
	let cell = table.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as UITableViewCell
	cell.textLabel?.text = filteredArray[indexPath.row].name
	cell.accessoryType = filteredArray[indexPath.row].isChecked ? .checkmark : .none
	return cell
  }

  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
	tableView.deselectRow(at: indexPath, animated: true)
	if tableView.cellForRow(at: indexPath)?.accessoryType == .checkmark {
	  filteredArray[indexPath.row].isChecked = false
	  tableView.cellForRow(at: indexPath)?.accessoryType = .none
	  complition?(indexPath.row)
	} else {
	  filteredArray[indexPath.row].isChecked = true
	  tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
	  complition?(indexPath.row)
	}
  }
}
