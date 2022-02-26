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
    lable.lineBreakMode = .byWordWrapping
    lable.lineBreakStrategy = .standard
    lable.numberOfLines = 0
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
      make.width.equalTo(contentView)
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
