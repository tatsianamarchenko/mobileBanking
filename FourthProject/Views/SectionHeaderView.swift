//
//  SectionHeaderView.swift
//  FourthProject
//
//  Created by Tatsiana Marchanka on 25.02.22.
//

import UIKit

class SectionHeaderView: UICollectionViewCell {

    static var reuseId = "reuseId"

    var title: UILabel = {
      var lable = UILabel()
      lable.textColor = .label
      lable.font = .systemFont(ofSize: 30, weight: .bold)

      lable.font.withSize(30)
      lable.lineBreakMode = .byWordWrapping
      lable.lineBreakStrategy = .pushOut
      lable.numberOfLines = 0
      return lable
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

  override func layoutSubviews() {
    super.layoutSubviews()
    self.addSubview(title)
    backgroundColor = .systemBackground

    title.snp.makeConstraints { (make) -> Void in
      make.centerX.equalTo(contentView).inset(30)
      make.width.equalToSuperview()
      make.top.equalTo(contentView.snp_topMargin).inset(10)
    }
  }

    func setTitle(title: String) {
      self.title.text = title
    }
  }
