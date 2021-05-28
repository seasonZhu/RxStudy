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
            
            if let imageString = info.envelopePic, let url = URL(string: imageString) {
                picView.isHidden = false
                picView.kf.setImage(with: url, placeholder: R.image.saber())
                
                contentLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(picView.snp.trailing).offset(16)
                    make.trailing.equalTo(contentView).offset(-16)
                    make.top.equalTo(bgView).offset(10)
                }
                
                authorLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(contentLabel)
                    make.top.equalTo(contentLabel.snp.bottom).offset(10)
                    make.bottom.equalTo(bgView.snp.bottom).offset(-10)
                }
                
            }else {
                picView.isHidden = true
                contentLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(bgView).offset(16)
                    make.trailing.equalTo(contentView).offset(-16)
                    make.top.equalTo(bgView).offset(10)
                }
                
                authorLabel.snp.remakeConstraints { make in
                    make.leading.equalTo(contentLabel)
                    make.top.equalTo(contentLabel.snp.bottom).offset(10)
                    make.bottom.equalTo(bgView.snp.bottom).offset(-10)
                }
            }
        } get {
            return _info
        }
    }
    
    private var _info: Info!
    
    private lazy var bgView = UIView()
    
    private lazy var picView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    private lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .gray
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        textLabel?.numberOfLines = 0
        textLabel?.font = UIFont.systemFont(ofSize: 15)
        
        detailTextLabel?.font = UIFont.systemFont(ofSize: 11)
        detailTextLabel?.textColor = .gray
        
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        bgView.addSubview(picView)
        picView.snp.makeConstraints { make in
            make.leading.equalTo(bgView).offset(16)
            make.centerY.equalTo(bgView)
            make.width.height.equalTo(44)
        }
        
        bgView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(picView.snp.trailing).offset(16)
            make.trailing.equalTo(contentView).offset(-16)
            make.top.equalTo(bgView).offset(10)
        }
        
        bgView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.bottom.equalTo(bgView.snp.bottom).offset(-10)
        }
    }
}
