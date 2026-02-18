//
//  MessageContentCell.swift
//  RxStudy
//
//  Created by dy on 2022/6/27.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

class MessageContentCell: UITableViewCell {

    var message: Message! {
        set {
            _message = newValue
            fromUserLabel.text = newValue.fromUser
            niceDateLabel.text = newValue.niceDate
            titleLabel.text = newValue.title
            contentLabel.text = newValue.message
            tagLabel.text = newValue.tag

        } get {
            return _message
        }
    }
    
    private var _message: Message!
    
    private lazy var fromUserLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .playAndroidTitle
        return label
    }()
    
    private lazy var niceDateLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .playAndroidTitle
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .playAndroidTitle
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .playAndroidTitle
        return label
    }()
    
    private lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        contentView.addSubview(fromUserLabel)
        fromUserLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(10)
        }
        
        contentView.addSubview(niceDateLabel)
        niceDateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalTo(fromUserLabel)
        }
        
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(fromUserLabel)
            make.trailing.equalTo(niceDateLabel)
            make.top.equalTo(fromUserLabel.snp.bottom).offset(10)
        }
 
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(fromUserLabel)
            make.trailing.equalTo(niceDateLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
        }
        
        contentView.addSubview(tagLabel)
        tagLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
