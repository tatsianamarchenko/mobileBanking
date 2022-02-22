//
//  DetailedCollectionViewCell.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 22.02.22.
//

import UIKit

class DetailedCollectionViewCell: UICollectionViewCell {
  static let reuseIdentifier = "DetailedCollectionViewCell"

  var placeLabel: UILabel = {
    var lable = UILabel()
    lable.textColor = .label
    return lable
  }()

  var timeLabel: UILabel = {
    var lable = UILabel()
    lable.textColor = .label
    return lable
  }()

  var currancyLabel: UILabel = {
    var lable = UILabel()
    lable.textColor = .label
    return lable
  }()

//  var stackView: UIStackView = {
//    let sv = UIStackView()
//    sv.axis  = NSLayoutConstraint.Axis.vertical
//    sv.alignment = UIStackView.Alignment.center
//    sv.backgroundColor = .green
//    sv.frame = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
//    sv.distribution = UIStackView.Distribution.fillEqually
//    return sv
//  }()

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = .systemMint

    addSubview(placeLabel)
    addSubview(timeLabel)
   addSubview(currancyLabel)


  }

  override func layoutSubviews() {
    super.layoutSubviews()
    timeLabel.snp.makeConstraints { (make) -> Void in
      make.leading.equalTo(contentView.snp_leadingMargin).inset(10)
      make.top.equalTo(contentView.snp_topMargin).inset(20)
    }

    placeLabel.snp.makeConstraints { (make) -> Void in
      make.leading.equalTo(contentView.snp_leadingMargin).inset(10)
      make.top.equalTo(timeLabel.snp_topMargin).inset(10)
    }

    currancyLabel.snp.makeConstraints { (make) -> Void in
      make.leading.equalTo(contentView.snp_leadingMargin).inset(10)
      make.top.equalTo(placeLabel.snp_topMargin).inset(10)
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func prepareForReuse() {
    super.prepareForReuse()
    placeLabel.text = nil
    timeLabel.text = nil
    currancyLabel.text = nil
  }
}
