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
		lable.lineBreakStrategy = .pushOut
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
		contentView.backgroundColor = .systemGray6
		
		contentView.clipsToBounds = true
		contentView.layer.cornerRadius = 10
		addSubview(placeLabel)
		addSubview(timeLabel)
		addSubview(currancyLabel)
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		makeConstraints()
	}
	
	private func makeConstraints() {
		placeLabel.snp.makeConstraints { (make) -> Void in
			make.centerX.equalTo(contentView)
			make.width.equalToSuperview()
			make.top.equalTo(contentView.snp_topMargin).inset(10)
		}
		timeLabel.snp.makeConstraints { (make) -> Void in
			make.centerX.equalTo(contentView)
			make.width.equalToSuperview()
			make.top.equalTo(placeLabel.snp_bottomMargin).inset(-10)
			
		}
		currancyLabel.snp.makeConstraints { (make) -> Void in
			make.centerX.equalTo(contentView)
			make.width.equalToSuperview()
			make.top.equalTo(timeLabel.snp_bottomMargin).inset(-10)
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
