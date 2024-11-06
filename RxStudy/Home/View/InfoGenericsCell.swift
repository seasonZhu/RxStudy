//
//  InfoGenericsCell.swift
//  RxStudy
//
//  Created by dy on 2024/11/6.
//  Copyright © 2024 season. All rights reserved.
//

import UIKit

import RxCocoa

class InfoGenericsCell: BaseGenericsCell<Info> {
    
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
    
    override func setupUI() {
        super.setupUI()
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(picView)
        picView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(44)
        }
        
        contentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(76)
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
    
    override func setModel(_ model: Info) {
        super.setModel(model)
        
        var title = model.title
        contentLabel.text = title?.filterHTML()
        authorLabel.text = model.author
        
        if let zan = model.zan, zan > 0 {
            praiseLabel.text = "赞: \(zan)"
        } else {
            praiseLabel.text = nil
        }
        
        if let imageString = model.envelopePic,
           let url = URL(string: imageString) {
            picView.isHidden = false
            picView.kf.setImage(with: url, placeholder: R.image.wan_android_placeholder())
            
            /// 这个地方显示了remake与update区别
            /// remake是重新定义该控件相对其他控件的依赖,其他控件是可以更换的
            /// update对于其他控件的依赖是不能变更,只能改变offset的数值
            /// 以上结论是掘金大佬给我的提示
            contentLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(76)
            }
            
        } else {
            picView.isHidden = true
            contentLabel.snp.updateConstraints { make in
                make.leading.equalToSuperview().offset(16)
            }
        }
    }
}
