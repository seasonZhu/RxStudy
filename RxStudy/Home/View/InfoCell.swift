//
//  InfoCell.swift
//  RxStudy
//
//  Created by dy on 2021/9/18.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

class InfoCell: UITableViewCell {

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
                picView.kf.setImage(with: url, placeholder: R.image.saber())
                
                /// 这个地方显示了remake与update区别
                /// remake是重新定义该控件相对其他控件的依赖,其他控件是可以更换的
                /// update对于其他控件的依赖是不能变更,只能改变offset的数值
                /// 以上结论是掘金大佬给我的提示
                contentLabel.snp.updateConstraints { make in
                    make.leading.equalTo(contentView).offset(76)
                }
                
            } else {
                picView.isHidden = true
                contentLabel.snp.updateConstraints { make in
                    make.leading.equalTo(contentView).offset(16)
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(picView)
        picView.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(16)
            make.centerY.equalTo(contentView)
            make.width.height.equalTo(44)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentView).offset(76)
            make.trailing.equalTo(contentView).offset(-16)
            make.top.equalTo(contentView).offset(10)
        }
        
        contentView.addSubview(praiseLabel)
        praiseLabel.snp.makeConstraints { make in
            make.trailing.equalTo(contentLabel)
            make.top.equalTo(contentLabel.snp.bottom).offset(10)
            make.bottom.equalTo(contentView).offset(-10)
        }
        
        contentView.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { make in
            make.leading.equalTo(contentLabel)
            make.top.bottom.equalTo(praiseLabel)
        }
    }
}

