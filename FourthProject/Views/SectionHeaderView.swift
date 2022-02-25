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
      lable.textColor = .systemPink
      lable.numberOfLines = 1
      return lable
    }()

    override init(frame: CGRect) {
      super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
    }

    func initializeUI() {

      self.addSubview(title)
      backgroundColor = .systemMint

      title.snp.makeConstraints { (make) in
        make.leading.equalTo(contentView.snp_leadingMargin).inset(30)
        make.top.equalTo(contentView).offset(20)
      }
    }

    func setTitle(title: String) {
      self.title.text = title
    }
  }
