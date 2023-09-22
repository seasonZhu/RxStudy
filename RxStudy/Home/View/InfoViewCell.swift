//
//  InfoViewCell.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

class InfoViewCell: UITableViewCell {

    var info: Info! {
        set {
            _info = newValue
            var title = newValue.title
            contentLabel.text = title?.filterHTML()
            authorLabel.text = newValue.author
            
            if let zan = newValue.zan, zan > 0 {
                praiseLabel.text = "赞: \(zan)"
            } else {
                praiseLabel.text = nil
            }
            
            if let imageString = info.envelopePic,
               let url = URL(string: imageString) {
                picView.isHidden = false
                picView.kf.setImage(with: url, placeholder: R.image.wan_android_placeholder())
                
                contentLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(picView.snp.trailing).offset(16)
                    make.trailing.equalToSuperview().offset(-16)
                    make.top.equalToSuperview().offset(10)
                }
                
                authorLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(contentLabel)
                    make.top.equalTo(contentLabel.snp.bottom).offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                }
                
            } else {
                picView.isHidden = true
                contentLabel.snp.remakeConstraints { make in
                    make.leading.equalToSuperview().offset(16)
                    make.trailing.equalToSuperview().offset(-16)
                    make.top.equalToSuperview().offset(10)
                }
                
                authorLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(contentLabel)
                    make.top.equalTo(contentLabel.snp.bottom).offset(10)
                    make.bottom.equalToSuperview().offset(-10)
                }
            }
        } get {
            return _info
        }
    }
    
    private var _info: Info!
    
    private lazy var picView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .playAndroidTitle
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .gray
        return label
    }()
    
    private lazy var praiseLabel: UILabel = {
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
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(picView)
        picView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(picView.snp.trailing).offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(10)
        }
        
        contentView.addSubview(praiseLabel)
        praiseLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel)
            make.top.bottom.equalTo(praiseLabel)
        }
    }
}
